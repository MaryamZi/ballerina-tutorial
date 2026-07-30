# Ballerina tutorial

## Samples

| # | Sample | What it shows |
|---|---|---|
| 1 | [`1-client`](1-client) | HTTP client basics — fetch orders, bind response to typed records. Also shows the raw-JSON alternative. |
| 2 | [`2-automation`](2-automation) | Read → transform → POST. |
| 3 | [`3-generated-client`](3-generated-client) | Same as sample 1, but the HTTP client and record types are generated from an OpenAPI spec. |
| 4 | [`4-tests`](4-tests) | Sample 2 refactored for testability — unit-test the transform, mock the client for the fetch step. |

## Mock backends

`backends/` holds two mock services that the samples talk to:

- `backends/orders` — serves orders (port 9090). `GET /orders?date=YYYY-MM-DD` returns a list, `GET /orders/{orderId}` returns one.
- `backends/reports` — accepts summaries (port 9091). `POST /reports/summaries` logs each summary it receives.

Start each with `bal run` from its directory.

## Prerequisites

- Ballerina 2201.13 or later — check with `bal version`.
- VS Code with the Ballerina extension.

## Running a sample

Each sample's `README.md` has its own endpoint list, sample payload, and run steps. The general pattern:

```
# terminal 1 — start the mock(s) the sample needs
cd backends/orders
bal run

# terminal 2 — run the sample
cd <sample-dir>
bal run
```
