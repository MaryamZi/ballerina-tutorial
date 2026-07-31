# 4. Resilience — retries

An HTTP client that survives transient failures. The client is configured with `retryConfig` on the specific status codes we consider retryable, so a call that would otherwise fail once succeeds after a couple of retries.

## Steps

### 1. Start the flaky backend

```
cd backends/flaky && bal run
```

`GET /flaky/orders` returns `503 Service Unavailable` for the first two calls, then `200` on the third. The counter resets after each success, so every fresh demo run shows retries.

### 2. Create the Ballerina package

```
bal new resilience
cd resilience
```

### 3. Configure retry on the client

Pass `retryConfig` on the client constructor:

```ballerina
final http:Client flakyClient = check new (flakyEP,
    retryConfig = {
        count: 3,
        interval: 1,
        backOffFactor: 2.0,
        statusCodes: [503, 502, 504]
    }
);
```

- `count` — max retry attempts.
- `interval` — initial wait between attempts (seconds).
- `backOffFactor` — multiplier applied to the interval each retry (1 → 2 → 4 seconds).
- `statusCodes` — which HTTP codes trigger a retry. Empty means retry on network errors only, not on HTTP failures.

### 4. Call the endpoint from `main`

Nothing special at the call site — the client handles the retry transparently:

```ballerina
json response = check flakyClient->/flaky/orders;
```

### 5. Run

```
bal run
```

Flaky backend log:

```
Flaky backend hit  attempt=1
Flaky backend hit  attempt=2
Flaky backend hit  attempt=3
```

Client output:

```
Response: {"message":"Success after retries","ordersCount":3}
```

## Failover

For failing over to an alternate service, use `http:FailoverClient` instead of `http:Client`. Same `retryConfig`, plus a list of target URLs — the client tries each in order until one succeeds:

```ballerina
http:FailoverClient client = check new ({
    targets: [
        {url: "http://primary.example.com"},
        {url: "http://secondary.example.com"}
    ],
    failoverCodes: [500, 501, 502, 503]
});
```

See [HTTP Client Resiliency Examples](https://ballerina.io/learn/by-example/#http-client-resiliency) for more.
