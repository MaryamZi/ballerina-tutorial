# 3. Generated client — from an OpenAPI spec

The same fetch as sample 1, with the HTTP client and every record type generated from an OpenAPI spec. No hand-written records, no hand-written HTTP calls — change the spec, regenerate, and the compiler flags any code that no longer matches.

## Steps

### 1. Start the orders backend

```
cd backends/orders && bal run
```

### 2. Create the package and the client submodule

```
bal new automation
cd automation
bal add orders_client
```

`bal add` scaffolds `modules/orders_client/orders_client.bal` and `modules/orders_client/tests/`. Remove them — `bal openapi` will fill the module in:

```
rm modules/orders_client/orders_client.bal
rm -rf modules/orders_client/tests
```

### 3. Generate the client

`orders_openapi.json` is already committed in this directory. Feed it to the client generator:

```
bal openapi -i orders_openapi.json --mode client -o modules/orders_client
```

`modules/orders_client/` now contains the typed `Client` and record definitions.

### 4. Write `main` using the generated client

Import the submodule and fetch orders — no local records needed:

```ballerina
import automation.orders_client as orders;
```

Use `orders:Client` and `orders:Order[]`.

### 5. Run

```
bal run
```

Expected output:

```
Order 1001 for Customer Alice Perera of Total value $39.98
```
