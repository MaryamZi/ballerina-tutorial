# 7. Database — talk to Postgres

Read a row from a Postgres table using the `ballerinax/postgresql` client. `main.bal` shows the minimum: initialize the client, run one `queryRow`, print the result. The extended example at the end wraps the same client in an HTTP service with GET / POST endpoints — the shape sample 10 has, backed by real storage.

## Steps

### 1. Start Postgres

```
cd 07-database
docker compose up -d
```

`init.sql` runs on first boot and seeds three rows into a `products` table:

```sql
CREATE TABLE products (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    category VARCHAR(32) NOT NULL
);
```

### 2. Create the Ballerina package

```
bal new products_db
```

Import the postgresql client and its driver (the driver import must be present for the JDBC driver to be on the classpath):

```ballerina
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
```

### 3. Configure the connection

Copy `Config.toml.example` to `Config.toml`:

```toml
dbHost = "localhost"
dbPort = 5432
dbName = "products"
dbUser = "tutorial"
dbPassword = "tutorial"
```

### 4. Initialize the client

Module-level, before `main`:

```ballerina
final postgresql:Client dbClient = check new (
    host = dbHost, port = dbPort, database = dbName,
    username = dbUser, password = dbPassword
);
```

### 5. Run one `queryRow` from `main`

```ballerina
Product product = check dbClient->queryRow(
    `SELECT id, name, price, stock, category FROM products WHERE id = 'SKU-1'`
);
io:println("Fetched: ", product);
```

### 6. Run

```
bal run
```

Output:

```
Fetched: {"id":"SKU-1","name":"Widget","price":19.99,"stock":120,"category":"TOOLS"}
```

## Query patterns

Three shapes of `sql:` calls:

- `queryRow` — returns a single row, or `sql:NoRowsError` if there's nothing to return. Used above.
- `query` — returns a `stream<Product, sql:Error?>` for lists. Consume with a query expression: `from Product p in resultStream select p`.
- `execute` — for `INSERT` / `UPDATE` / `DELETE`, returns an `sql:ExecutionResult`.

Ballerina builds a parameterized query — no string concatenation:

```ballerina
dbClient->query(`SELECT ... WHERE category = ${category}`);
```

## Extended example — a full CRUD service

The same client wrapped in an HTTP service with list/filter/get-by-id/create endpoints. Essentially sample 10 with Postgres behind it.

```ballerina
import ballerina/http;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

public enum ProductCategory {
    TOOLS,
    ELECTRONICS,
    HARDWARE
}

public type Product record {|
    string id;
    string name;
    decimal price;
    int stock;
    ProductCategory category;
|};

configurable string dbHost = ?;
configurable int dbPort = ?;
configurable string dbName = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable int port = ?;

final postgresql:Client dbClient = check new (
    host = dbHost, port = dbPort, database = dbName,
    username = dbUser, password = dbPassword
);

service /products on new http:Listener(port) {

    resource function get .(ProductCategory? category = ()) returns Product[]|error {
        sql:ParameterizedQuery query = category is ()
            ? `SELECT id, name, price, stock, category FROM products`
            : `SELECT id, name, price, stock, category FROM products WHERE category = ${category}`;
        stream<Product, sql:Error?> resultStream = dbClient->query(query);
        return from Product p in resultStream select p;
    }

    resource function get [string productId]() returns Product|http:NotFound|error {
        Product|sql:Error result = dbClient->queryRow(
            `SELECT id, name, price, stock, category FROM products WHERE id = ${productId}`
        );
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function post .(Product product) returns http:Created|http:Conflict|error {
        Product|sql:Error existing = dbClient->queryRow(
            `SELECT id, name, price, stock, category FROM products WHERE id = ${product.id}`
        );
        if existing is Product {
            return http:CONFLICT;
        }
        _ = check dbClient->execute(`
            INSERT INTO products (id, name, price, stock, category)
            VALUES (${product.id}, ${product.name}, ${product.price}, ${product.stock}, ${product.category})
        `);
        return http:CREATED;
    }
}
```

With `port = 9094` in `Config.toml`, `api.hurl` in this directory drives each endpoint.

## Tear down

```
docker compose down
```

Add `-v` to also drop the volume — otherwise `init.sql` won't re-run on the next `up`.
