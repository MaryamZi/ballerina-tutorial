# 4. Resilience — retries

An HTTP client that survives transient failures. The client is configured with `retryConfig` on the specific status codes we consider retryable, so a call that would otherwise fail once succeeds after a couple of retries.

## Backend

`backends/flaky` returns `503 Service Unavailable` for the first N calls, then `200` on the (N+1)th. `N` is configurable (default 2). The counter resets after each successful response — every fresh demo run shows retries.

## Client config

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
- `statusCodes` — which HTTP codes trigger a retry. Empty means retry on any network error but not on HTTP failures.

## Run

```
cd backends/flaky && bal run     # terminal 1
cd 04-resilience && bal run      # terminal 2
```

Flaky backend log (each demo run):

```
time=2026-07-31T16:12:37.531+05:30 level=INFO module=tutorial/flaky_backend message="Flaky backend hit" attempt=1
time=2026-07-31T16:12:38.590+05:30 level=INFO module=tutorial/flaky_backend message="Flaky backend hit" attempt=2
time=2026-07-31T16:12:40.605+05:30 level=INFO module=tutorial/flaky_backend message="Flaky backend hit" attempt=3
```

Client output:

```
Response: {"message":"Success after retries","ordersCount":3}
```

## Failover — the next layer up

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

Also see [HTTP Client Resiliency Examples](https://ballerina.io/learn/by-example/#http-client-resiliency)
