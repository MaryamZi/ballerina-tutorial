# 3. Generated client — read orders with an OAS-generated client

Same as sample 1, but the orders HTTP client is generated from the orders backend's OpenAPI spec instead of hand-written. All record types (`Order`, `LineItem`, `OrderStatus`) come from the generated code.

## Endpoint

```
GET http://localhost:9090/orders?date=2026-07-29
```

## Set up

```
bal new automation
cd automation
bal add orders_client
```

`bal add` scaffolds `modules/orders_client/orders_client.bal` and `modules/orders_client/tests/`. Remove them — the OpenAPI tool will fill the module in:

```
rm modules/orders_client/orders_client.bal
rm -rf modules/orders_client/tests
```

Generate the orders OpenAPI spec from the backend and drop it into this package:

```
cd ../backends/orders
bal openapi -i service.bal --json
mv orders_openapi.json ../../3-generated-client/
```

Generate the client into the submodule:

```
cd ../../3-generated-client
bal openapi -i orders_openapi.json --mode client -o modules/orders_client
```

Then write `main.bal` using the generated `orders_client:Client` and its `Order` type.

## Run

Start the orders backend:

```
cd backends/orders
bal run
```

Then run:

```
cd 3-generated-client
bal run
```

## Expected output

```
Pending orders on 2026-07-29:
Order 1001 for Customer 'Alice Perera' of Total value $39.98 is COMPLETED
Order 1002 for Customer 'Bob Silva' of Total value $149.99 is COMPLETED
...
```
