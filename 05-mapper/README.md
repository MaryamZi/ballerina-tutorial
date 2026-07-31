# 5. Mapper — data mapping

Two data-mapper transformations, no HTTP. Sample records are hardcoded so the focus stays on the mapping. Each transformation is an expression-bodied function — buildable in VS Code with the Ballerina **data mapper**.

Use the following definitions and values.

```bal
type LineItem record {|
    string productId;
    string name;
    int quantity;
    decimal unitPrice;
|};

type Order record {|
    int id;
    string date;
    string customerId;
    string customerName;
    string status;
    LineItem[] items;
    decimal total;
|};

type Customer record {|
    string id;
    string firstName;
    string lastName;
    string email;
|};

type NotificationTarget record {|
    string recipientId;
    string name;
    string email;
|};

type OrderItem record {|
    string name;
    int quantity;
|};

type EnrichedOrder record {|
    string orderRef;
    string customer;
    string email;
    decimal amount;
    OrderItem[] items;
    string status;
|};

final Order sampleOrder = {
    id: 1001,
    date: "2026-07-29",
    customerId: "CUST-42",
    customerName: "Alice Perera",
    status: "COMPLETED",
    items: [
        {productId: "SKU-1", name: "Widget", quantity: 2, unitPrice: 19.99}
    ],
    total: 39.98
};

final Customer sampleCustomer = {
    id: "CUST-42",
    firstName: "Alice",
    lastName: "Perera",
    email: "alice@example.com"
};
```

## Mapping A — `Customer → NotificationTarget`

Single input. Combines `firstName` and `lastName` into a single display name, and passes the id and email through.

```
Customer                                     NotificationTarget
id                       ── direct ───────►  recipientId
firstName + lastName     ── concat ───────►  name
email                    ── direct ───────►  email
```

## Mapping B — `(Order, Customer) → EnrichedOrder`

Two inputs joined into one output. The caller supplies both — the join by `customerId` is implicit at the call site.

```
Order + Customer                              EnrichedOrder
Order.id (int)               ── .toString() ─►  orderRef (string)
Customer.firstName + lastName ── template ───►  customer
Customer.email               ── direct ──────►  email
Order.total                  ── direct ──────►  amount
Order.items                  ── map ─────────►  items[] projected to {name, quantity}
Order.status                 ── direct ──────►  status
```

## Run

```
cd 05-mapper
bal run
```

Output:

```
NotificationTarget:
  {"recipientId":"CUST-42","name":"Alice Perera","email":"alice@example.com"}

EnrichedOrder:
  {"orderRef":"1001","customer":"Alice Perera","email":"alice@example.com","amount":39.98,"items":[{"name":"Widget","quantity":2}],"status":"COMPLETED"}
```
