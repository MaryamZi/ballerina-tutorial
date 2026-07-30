# 1. Client — read orders

Fetches orders for a given date from the mock orders backend and prints one line per order. The response is bound to a typed `Order[]`.

## Endpoint

```
GET http://localhost:9090/orders?date=2026-07-29
```

## Sample response

```json
[
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
]
```

## Set up

```
bal new automation
```

Use the sample response above into using the VS Code Ballerina command **Paste JSON as Record** to generate the record types. Rename the outer record to `Order`, then implement the logic in the `main` function.

## Run

Start the backend:

```
cd backends/orders
bal run
```

Then in another terminal:

```
cd 1-client
bal run
```

## Expected output

```
Pending orders on 2026-07-29:
Order 1001 for Customer 'Alice Perera' of Total value $39.98 is COMPLETED
Order 1002 for Customer 'Bob Silva' of Total value $149.99 is COMPLETED
...
```

## Alternative: raw JSON access

The same behavior without records — response typed as `json[]`, each field pulled out with `check`:

```ballerina
import ballerina/http;
import ballerina/io;

public function main() returns error? {
    http:Client ordersClient = check new ("http://localhost:9090");

    json[] orders = check ordersClient->/orders(date = "2026-07-29");

    io:println("Pending orders on 2026-07-29:");
    foreach json orderJson in orders {
        int id = check orderJson.id;
        string customerName = check orderJson.customerName;
        decimal total = check orderJson.total;
        string status = check orderJson.status;
        io:println(string `Order ${id} for Customer '${
            customerName}' of Total value $${total} is ${status}`);
    }
}
```
