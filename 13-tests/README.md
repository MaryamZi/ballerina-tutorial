# 13. Tests — unit-test a mapper, mock a client, exercise a service

A small service (`GET /summaries?date=…`) that fetches orders from a backend, maps them to a leaner shape, and returns the list. Three tests exercise it at three layers:

1. **Pure** — `testTransformToSummary` exercises `toSummary(Order)` directly. No HTTP, no mocking.
2. **With a mocked client** — `testFetchAndTransform` swaps out the HTTP client, feeds canned orders in, checks the mapping output.
3. **Through the service** — `testSummariesService` hits the running listener with a plain `http:Client`. The internal `ordersClient` is still mocked, so no orders backend is needed.

## What makes it testable

- Fetch + map lives in one function — `fetchAndTransform(string date) returns OrderSummary[]|error` — that can be called directly or from the service resource.
- The HTTP client is built by `initializeOrdersClient()`. The test framework replaces this function with one that returns a mock.
- The service resource is a thin wrapper over `fetchAndTransform` — nothing to test in the resource itself beyond the dispatch path, which the third test covers.

## Test data

Module-level values in `tests/tests.bal`:

```ballerina
final readonly & Order[] mockOrders = [
    {id: 1234, date: "2026-07-29", customerId: "C001", customerName: "John Doe", status: "Shipped",
     items: [
         {productId: "P001", name: "Product 1", quantity: 2, unitPrice: 10.0},
         {productId: "P002", name: "Product 2", quantity: 1, unitPrice: 20.0}
     ], total: 40.0},
    {id: 2212, date: "2026-07-29", customerId: "C002", customerName: "Jane Smith", status: "Pending",
     items: [{productId: "P003", name: "Product 3", quantity: 3, unitPrice: 15.0}], total: 45.0}
];

final readonly & OrderSummary[] expectedSummaries = [
    {orderRef: "1234", customer: "John Doe", amount: 40.0, lineCount: 2, status: "Shipped"},
    {orderRef: "2212", customer: "Jane Smith", amount: 45.0, lineCount: 1, status: "Pending"}
];
```

## Mocking the client

Replace `initializeOrdersClient()` with a function that returns a mock:

```ballerina
@test:Mock { functionName: "initializeOrdersClient" }
function getMockClient() returns http:Client|error => test:mock(http:Client);
```

Per-test, stub the resource call:

```ballerina
test:prepare(ordersClient)
    .whenResource("::orders")
    .onMethod("get")
    .thenReturn(mockOrders);
```

## Exercising the service

`bal test` starts the service's listener on `servicePort`, so a test can create an `http:Client` and drive the endpoint directly:

```ballerina
@test:Config
public function testSummariesService() returns error? {
    test:prepare(ordersClient).whenResource("::orders").onMethod("get").thenReturn(mockOrders);

    http:Client serviceClient = check new (string `http://localhost:${servicePort}`);
    OrderSummary[] actual = check serviceClient->/summaries(date = date);
    test:assertEquals(actual, expectedSummaries);
}
```

The `ordersClient` mock is still in effect inside the service, so this exercises the full dispatch + resource + fetch + map path without a real orders backend.

## Alternatives to `test:mock`

**Test double.** Instead of stubbing per test, implement a concrete client object with the same resource shape and pass it as the template:

```ballerina
public isolated client class OrdersClientDouble {
    isolated resource function get [http:PathParamType ...path](map<string|string[]>? headers = (),
            http:TargetType targetType = anydata, *http:QueryParams params)
            returns http:Response|anydata|stream<http:SseEvent, error?>|http:ClientError {
        return mockOrders;
    }
}

@test:Mock { functionName: "initializeOrdersClient" }
function getMockClient() returns http:Client|error {
    return test:mock(http:Client, new OrdersClientDouble());
}
```

Trade-off: no per-test stubbing, but the double covers all tests uniformly. See the [Ballerina test-double docs](https://ballerina.io/learn/test-ballerina-code/mocking/#create-a-test-double).

**Mock service.** Run a real HTTP service inside the test module on a different port and point the client at it via `tests/Config.toml`:

```ballerina
// tests/tests.bal
service /orders on new http:Listener(9096) {
    resource function get .(string date) returns Order[] => mockOrders;
}
```

```toml
# tests/Config.toml
ordersEP = "http://localhost:9096"
```

Trade-off: exercises the full HTTP stack (serialization, network hop), but slower and adds a listener to the test process.

## Run

```
bal test
```

For an HTML report + code coverage:

```
bal test --test-report --code-coverage
```

Report opens at `target/report/index.html`.
