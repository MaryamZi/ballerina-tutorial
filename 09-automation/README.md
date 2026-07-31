# 9. Automation — fetch, map, forward

Fetch data from one service, transform it, forward it to another. Two HTTP clients, one orchestrating function that can run on a schedule or manual trigger.

- **Fetch**: `http:Client` against the orders backend (sample 1).
- **Map**: `toSummary(Order)` expression-bodied function (data mapper — sample 5).
- **Forward**: `http:Client` POST to the reports backend.

## Endpoints

```
GET  http://localhost:9090/orders?date=YYYY-MM-DD    (orders backend)
POST http://localhost:9091/reports/summaries         (reports backend)
```

## Sample POST body

```json
[
  {
    "orderRef": "1001",
    "customer": "Alice Perera",
    "amount": 39.98,
    "items": [
      { "name": "Widget", "quantity": 2 }
    ],
    "status": "COMPLETED"
  }
]
```

## Config.toml

```toml
ordersEP = "http://localhost:9090"
reportsEP = "http://localhost:9091"
```

## Run

Start both backends:

```
cd backends/orders && bal run     # terminal 1
cd backends/reports && bal run    # terminal 2
```

Then run the automation with a date argument:

```
cd 09-automation
bal run -- 2026-07-29
```

## Expected output

```
Posted 7 order summaries for 2026-07-29.
```

The reports backend logs each incoming summary.

## Where to go from here

- To persist to a database instead of forwarding to a service, swap the reports `http:Client` for a `postgresql:Client` (sample 7) or a `bal persist` client (sample 8) and replace the POST with an INSERT / a `.post([summary])`.
- To send a notification instead, use the Gmail connector from sample 6 in place of the reports client.
