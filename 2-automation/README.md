# 2. Automation — transform and forward

Reads orders for a given date, transforms each into a lean `OrderSummary` (data mapping), and POSTs the list to the reports backend.

## Endpoints

```
GET  http://localhost:9090/orders?date=2026-07-29
POST http://localhost:9091/reports/summaries
```

## Data mapping

```
Order                        OrderSummary
─────                        ────────────
id (int)      ── toString ─► orderRef (string)
customerName  ── direct ───► customer (string)
total         ── direct ───► amount (decimal)
items         ── map ──────► items (Item[])   — project each LineItem to {name, quantity}
status        ── direct ───► status (string)
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

## Set up

```
bal new automation
```

Define `Order` (input) and `OrderSummary` (output) records (using the **Paste JSON as Record** command) and build the integration.

## Run

Start both backends:

```
cd backends/orders && bal run     # terminal 1
cd backends/reports && bal run    # terminal 2
```

Then run the automation with a date argument:

```
cd 2-automation
bal run -- 2026-07-29
```

## Expected output

```
Posted 7 order summaries for 2026-07-29.
```

The reports backend logs the summary.
