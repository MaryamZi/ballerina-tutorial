# 4. Tests — unit test the transform, mock the client

Adds tests to sample 2. Two tests: one for the pure `toSummary` function, one for `fetchAndTransform` (mocks the orders client).

## What changed from sample 2

- Extracted a `fetchAndTransform(string date) returns OrderSummary[]|error` function so the fetch + map step is testable in isolation.
- Wrapped the HTTP client init in `initializeOrdersClient()` / `initializeReportsClient()` — gives the test framework a function to swap out.
- URLs moved to `configurable` (`ordersEP`, `reportsEP`).

## Test data

Module-level values in `tests/tests.bal`:

```ballerina
final readonly & Order[] mockOrders = [
    {
        id: 1234,
        date: "2026-07-29",
        customerId: "C001",
        customerName: "John Doe",
        status: "Shipped",
        items: [
            {productId: "P001", name: "Product 1", quantity: 2, unitPrice: 10.0},
            {productId: "P002", name: "Product 2", quantity: 1, unitPrice: 20.0}
        ],
        total: 40.0
    },
    {
        id: 2212,
        date: "2026-07-29",
        customerId: "C002",
        customerName: "Jane Smith",
        status: "Pending",
        items: [{productId: "P003", name: "Product 3", quantity: 3, unitPrice: 15.0}],
        total: 45.0
    }
];

final readonly & OrderSummary[] expectedSummaries = [
    {
        orderRef: "1234",
        customer: "John Doe",
        amount: 40.0,
        items: [
            {name: "Product 1", quantity: 2},
            {name: "Product 2", quantity: 1}
        ],
        status: "Shipped"
    },
    {
        orderRef: "2212",
        customer: "Jane Smith",
        amount: 45.0,
        items: [{name: "Product 3", quantity: 3}],
        status: "Pending"
    }
];
```

## Mocking the client

The test replaces `initializeOrdersClient()` with a function that returns a mock `http:Client`:

```ballerina
@test:Mock { functionName: "initializeOrdersClient" }
function getMockClient() returns http:Client|error => test:mock(http:Client);
```

Then, per-test, it stubs the resource call:

```ballerina
test:prepare(ordersClient)
    .whenResource("::orders")
    .onMethod("get")
    .thenReturn(mockOrders);
```

## Alternatives to `test:mock`

**Test double.** Instead of stubbing the mock per test with `test:prepare(...).whenResource(...)`, implement a concrete client object that mimics the resource shape and returns canned data, then pass it as the template to `test:mock`:

```ballerina
public isolated client class OrdersClientDouble {
    isolated resource function get [http:PathParamType ...path](map<string|string[]>? headers = (), http:TargetType targetType = anydata,
            *http:QueryParams params) returns http:Response|anydata|stream<http:SseEvent, error?>|http:ClientError {
        return mockOrders;
    }
}

@test:Mock { functionName: "initializeOrdersClient" }
function getMockClient() returns http:Client|error {
    return test:mock(http:Client, new OrdersClientDouble());
}

@test:Config
public function testFetchAndTransform() returns error? {
    OrderSummary[] actual = check fetchAndTransform(date);
    test:assertEquals(actual, expectedSummaries);
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
