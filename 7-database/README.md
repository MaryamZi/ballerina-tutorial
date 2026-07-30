# 7. Database — persist products in Postgres

Same shape as sample 6, but products live in a Postgres database instead of an in-memory map. Uses the `ballerinax/postgresql` client with `sql:ParameterizedQuery` for safe SQL.

## Endpoints

```
GET  http://localhost:9094/products
GET  http://localhost:9094/products?category=<TOOLS|ELECTRONICS|HARDWARE>
GET  http://localhost:9094/products/{productId}
POST http://localhost:9094/products
```

Behavior matches sample 6 — 404 for missing id, 409 for duplicate on POST, 400 for invalid `category` values.

## Schema

`init.sql` creates a single table and seeds three rows on first container start:

```sql
CREATE TABLE products (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    category VARCHAR(32) NOT NULL
);
```

## Set up

```
bal new products_db_service
```

Import the postgresql client and its driver (the driver import must be present for the JDBC driver to be on the classpath):

```ballerina
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;
```

Copy `Config.toml.example` to `Config.toml` (or supply the values another way):

```toml
dbHost = "localhost"
dbPort = 5432
dbName = "products"
dbUser = "tutorial"
dbPassword = "tutorial"
port = 9094
```

## Run

Start Postgres with docker-compose (mounts `init.sql` on first boot):

```
cd 7-database
docker compose up -d
```

Then run the service:

```
bal run
```

## Query patterns

All three shapes of `sql:` calls appear:

- `query` — returns a `stream<Product, sql:Error?>` for the list endpoint. Consumed with a query expression: `from Product p in resultStream select p`.
- `queryRow` — returns a single row or `sql:NoRowsError`, used for get-by-id.
- `execute` — for the INSERT on POST.

Parameter interpolation uses backticks — Ballerina builds a parameterized query, no string concatenation:

```ballerina
dbClient->query(`SELECT ... WHERE category = ${category}`);
```

## Exercise the API

`api.hurl` mirrors the one from sample 6 (same endpoints and expectations, different port):

```
hurl --test api.hurl
```

## Tear down

```
docker compose down
```

Add `-v` to also drop the volume — otherwise `init.sql` won't re-run on the next `up`.
