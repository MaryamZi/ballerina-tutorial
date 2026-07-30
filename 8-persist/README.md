# 8. Persist — code-generated data access

Same endpoints and behavior as sample 7, but the data access layer is **generated** by `bal persist` from a record definition. No hand-written SQL, no `sql:ParameterizedQuery` — just resource-style calls against a typed client (`dbClient->/products`, `dbClient->/products/[id]`, `dbClient->/products.post([...])`).

## Why persist vs raw `sql:`

Sample 7 works fine — the trade-off is what you write and maintain:

- **Typed CRUD, no query strings.** The generated client exposes `->/products`, `->/products/[id]`, `->/products.post(...)`, `.put(...)`, `.delete()` — no SQL to write, no interpolation to get right.
- **Swap datastores from the same model.** `--datastore postgresql` today, `--datastore mysql` (or `mssql`, `redis`, `inmemory` for tests, ...) tomorrow — regenerate, no code changes.
- **Schema evolution stays honest.** Change the model, rebuild, and both the client and `script.sql` update together.

## Endpoints

```
GET  http://localhost:9095/products
GET  http://localhost:9095/products?category=<TOOLS|ELECTRONICS|HARDWARE>
GET  http://localhost:9095/products/{productId}
POST http://localhost:9095/products
```

Behavior matches samples 6 and 7 — 404 for missing id, 409 for duplicate on POST, 400 for invalid `category`.

## Data model

Defined once in `persist/model.bal`:

```ballerina
import ballerina/persist as _;
import ballerinax/persist.sql;

type Product record {|
    readonly string id;
    string name;
    @sql:Decimal {precision: [10, 2]}
    decimal price;
    int stock;
    string category;
|};
```

- `readonly` marks the primary key.
- `@sql:Decimal {precision: [10, 2]}` pins the SQL column type so prices render as `19.99`, not `19.990000000000000000000000000000` (the default is `DECIMAL(65,30)`).

## Set up

```
bal new products_persist
cd products_persist
bal persist add --datastore postgresql --module products
```

`bal persist add` writes a `[[tool.persist]]` block into `Ballerina.toml` and creates an empty `persist/model.bal`. Fill in the model above, then `bal build` — the tool integration generates the client on every build.

Generated code lives under `generated/products/`:

- `persist_client.bal` — the typed CRUD client
- `persist_types.bal` — `Product`, `ProductInsert`, `ProductUpdate` records
- `persist_db_config.bal` — `configurable` variables the client uses (`host`, `port`, `user`, `database`, `password`)
- `script.sql` — the SQL schema for reference (mirrored in `init.sql`)

## Config.toml

The generated `configurable` values live in the `products_persist.products` module — hence the section header:

```toml
servicePort = 9095

[products_persist.products]
host = "localhost"
port = 5432
user = "tutorial"
database = "products"
password = "tutorial"
```

Copy `Config.toml.example` to `Config.toml`.

## Run

Start Postgres (schema + seed baked into `init.sql`):

```
cd 8-persist
docker compose up -d
```

Then:

```
bal run
```

## Client method surface

```ballerina
// list — returns a stream, consumed with a query expression
stream<Product, persist:Error?> s = dbClient->/products(whereClause = `category = ${category}`);

// get by id
Product|persist:Error one = dbClient->/products/[productId];

// insert (takes an array, returns the ids)
string[]|persist:Error ids = dbClient->/products.post([product]);

// update / delete also exist:
//   dbClient->/products/[id].put({name: "..."})
//   dbClient->/products/[id].delete()
```

Errors carry specific subtypes — `persist:NotFoundError` and `persist:AlreadyExistsError` — used here to map to 404 and 409.

## Exercise the API

```
hurl --test api.hurl
```

## Tear down

```
docker compose down
```
