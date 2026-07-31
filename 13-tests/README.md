# 13. Tests — unit-test a mapper, mock a client, exercise a service

A simple service (`GET /summaries?date=…`) that fetches orders from a backend, maps them to a leaner shape, and returns the list. Three tests exercise it at three layers:

1. **Function test** — `toSummary(Order)` in isolation. No HTTP, no mocking.
2. **With a mocked client** — `fetchAndTransform(date)` against a mocked `ordersClient`.
3. **Through the service** — an `http:Client` hits the running listener; the mock is still in effect inside.

## Steps

### 1. Create the Ballerina package

```
bal new summaries_service
cd summaries_service
```

### 2. Structure the code for testability

Copy the contents of the `service.bal` file.

Note the following changes from previous examples:

- Extract `fetchAndTransform(string date) returns OrderSummary[]|error` so the fetch + map is one function callable from tests or the service resource.
- Wrap client construction in `initializeOrdersClient()` — the test framework replaces this function with one that returns a mock.

### 3. Write test data

Module-level values in `tests/tests.bal`:

```ballerina
final readonly & Order[] mockOrders = [ ... ];
final readonly & OrderSummary[] expectedSummaries = [ ... ];
```

### 4. Test the mapper — no HTTP, no mock

```ballerina
@test:Config
function testTransformToSummary() {
    OrderSummary actual = toSummary(sampleOrder);
    test:assertEquals(actual, expectedSummary);
}
```

### 5. Mock the client and test `fetchAndTransform`

Replace `initializeOrdersClient()` with a function that returns a mock, then stub the resource call per test:

```ballerina
@test:Mock { functionName: "initializeOrdersClient" }
function getMockClient() returns http:Client|error => test:mock(http:Client);

@test:Config
function testFetchAndTransform() returns error? {
    test:prepare(ordersClient).whenResource("::orders").onMethod("get").thenReturn(mockOrders);
    OrderSummary[] actual = check fetchAndTransform(date);
    test:assertEquals(actual, expectedSummaries);
}
```

### 6. Test the service end-to-end

`bal test` starts the listener on `servicePort`. Create an `http:Client` in the test and drive the endpoint. The mocked `ordersClient` is still in effect inside the service, so no real orders backend is needed:

```ballerina
@test:Config
function testSummariesService() returns error? {
    test:prepare(ordersClient).whenResource("::orders").onMethod("get").thenReturn(mockOrders);

    http:Client serviceClient = check new (string `http://localhost:${servicePort}`);
    OrderSummary[] actual = check serviceClient->/summaries(date = date);
    test:assertEquals(actual, expectedSummaries);
}
```

### 7. Run

```
bal test
```

For an HTML report + code coverage:

```
bal test --test-report --code-coverage
```

Report opens at `target/report/index.html`.

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
