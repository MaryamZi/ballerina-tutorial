# 1. Client — call an HTTP backend

Fetch data from an HTTP backend and print it. The response binds directly to typed records — no manual JSON parsing.

This sample makes two calls:

- `GET /orders/1001` — a single order.
- `GET /orders` — the full list, iterated and printed.

## Endpoints

```
GET http://localhost:9090/orders/1001
GET http://localhost:9090/orders
```

## Sample response (single order)

```json
{
  "id": 1001,
  "date": "2026-07-29",
  "customerId": "CUST-42",
  "customerName": "Alice Perera",
  "status": "COMPLETED",
  "items": [
    { "productId": "SKU-1", "name": "Widget", "quantity": 2, "unitPrice": 19.99 }
  ],
  "total": 39.98
}
```

## Set up

```
bal new automation
```

Use the sample response above with the VS Code Ballerina extension's **Paste JSON as Record** command, with a `.bal` file open to generate the record types. Rename the outer record to `Order`. Then implement the logic in a `main` function that fetches the order by order ID `1001`.

Then use the graphical view to retrieve all orders, specify **`/orders`** as the path.

![Use client flow](gifs/use_client_flow.gif)

## Run

```
cd backends/orders && bal run       # terminal 1
cd 01-client && bal run             # terminal 2
```

## Expected output

```
Order 1001 for Customer Alice Perera of Total value $39.98
Order 1001 for Customer Alice Perera of Total value $39.98
Order 1002 for Customer Bob Silva of Total value $149.99
...
```

The first line is the single-order fetch; the rest come from iterating the list.

## Next

- Sample 2 — same job, but the response typed as raw `json`, and a second variant using XML from the customers backend.
- Sample 3 — same job again, but the client and record types are generated from an OpenAPI spec (no hand-written records at all).
