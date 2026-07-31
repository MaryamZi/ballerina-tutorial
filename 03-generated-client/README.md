# 3. Generated client — from an OpenAPI spec

Same job as sample 1, but the HTTP client and every record type come from an OpenAPI spec — no hand-written records, no hand-written HTTP calls. 

## Endpoint

```
GET http://localhost:9090/orders?date=2026-07-29
```

## Set up

Start from an empty package:

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

Produce the OpenAPI spec from the orders backend (once, then commit):

```
cd ../backends/orders
bal openapi -i service.bal --json
mv orders_openapi.json ../../03-generated-client/
```

Generate the client into the submodule:

```
cd ../../03-generated-client
bal openapi -i orders_openapi.json --mode client -o modules/orders_client
```

## Using the generated client

`orders:Client`, `orders:Order` — all types come from the generated `modules/orders_client/`. When the spec changes, regenerate; the compiler flags any code that no longer matches.

## Run

```
cd backends/orders && bal run       # terminal 1
cd 03-generated-client && bal run   # terminal 2
```

## Expected output

```
Order 1001 for Customer Alice Perera of Total value $39.98
```
