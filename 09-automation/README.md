# 9. Automation — fetch, map, forward

Fetch data from one service, transform it, forward it to another. Two HTTP clients, one orchestrating function that can run on a schedule or manual trigger.

- **Fetch** — sample 1 (`http:Client`)
- **Map** — sample 5 (data mapper)
- **Forward** — a second `http:Client`

## Steps

### 1. Start both backends

```
cd backends/orders && bal run     # terminal 1 — port 9090
cd backends/reports && bal run    # terminal 2 — port 9091
```

### 2. Create the Ballerina package

```
bal new automation
cd automation
```

### 3. Configure the endpoints

Copy `Config.toml.example` to `Config.toml`:

```toml
ordersEP = "http://localhost:9090"
reportsEP = "http://localhost:9091"
```

### 4. Define the input and output records

`Order` (input) matches the orders backend response — use **Paste JSON as Record** on sample 1's payload if starting from scratch.

`OrderSummary` (output) — the shape POSTed to the reports backend:

```ballerina
type OrderItem record {|
    string name;
    int quantity;
|};

type OrderSummary record {|
    string orderRef;
    string customer;
    decimal amount;
    OrderItem[] items;
    string status;
|};
```

Corresponding JSON on the wire:

```json
[
  {
    "orderRef": "1001",
    "customer": "Alice Perera",
    "amount": 39.98,
    "items": [ { "name": "Widget", "quantity": 2 } ],
    "status": "COMPLETED"
  }
]
```

### 5. Write the mapping

`toSummary(Order) returns OrderSummary` — an expression-bodied function that projects each order into the leaner summary shape. See sample 5 for the data-mapper walk-through.

### 6. Wire the flow in `main(string date)`

```
Order[]         ← ordersClient->/orders(date = date)
OrderSummary[]  ← query expression calling toSummary
                → reportsClient->/reports/summaries.post(summaries)
```

### 7. Run

```
bal run -- 2026-07-29
```

Expected output:

```
Posted 7 order summaries for 2026-07-29.
```

The reports backend logs each incoming summary.

## Where to go from here

- To persist to a database instead of forwarding to a service, swap the reports `http:Client` for a `postgresql:Client` (sample 7) or a `bal persist` client (sample 8) and replace the POST with an INSERT / a `.post([summary])`.
- To send a notification instead, use the Gmail connector from sample 6 in place of the reports client.
