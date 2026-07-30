import ballerina/test;
import ballerina/http;

// Can also use data providers to run the same test with different inputs. 
@test:Config
function testTransformToSummary() {
    Order orderValue = {        
        id: 1,
        date: "2026-07-29",
        customerId: "C001",
        customerName: "John Doe",
        status: "Shipped",
        items: [
            { productId: "P001", name: "Product 1", quantity: 2, unitPrice: 10.0 },
            { productId: "P002", name: "Product 2", quantity: 1, unitPrice: 20.0 }
        ],
        total: 40.0
    };
    OrderSummary expectedSummary = {
        orderRef: "1",
        customer: "John Doe",
        amount: 40.0,
        status: "Shipped",
        items: [
            { name: "Product 1", quantity: 2 },
            { name: "Product 2", quantity: 1 }
        ]
    };
    OrderSummary actualSummary = toSummary(orderValue);
    test:assertEquals(actualSummary, expectedSummary);
}

@test:Mock { functionName: "initializeOrdersClient" }
function getMockClient() returns http:Client|error {
    return test:mock(http:Client);
}

const string date = "2026-07-29";

final readonly & Order[] mockOrders = [
    {
        id: 1234,
        date: date,
        customerId: "C001",
        customerName: "John Doe",
        status: "Shipped",
        items: [
            { productId: "P001", name: "Product 1", quantity: 2, unitPrice: 10.0 },
            { productId: "P002", name: "Product 2", quantity: 1, unitPrice: 20.0 }
        ],
        total: 40.0
    },
    {
        id: 2212,
        date, // Same as date: date
        customerId: "C002",
        customerName: "Jane Smith",
        status: "Pending",
        items: [
            { productId: "P003", name: "Product 3", quantity: 3, unitPrice: 15.0 }
        ],
        total: 45.0
    }
];

final readonly & OrderSummary[] expectedSummaries = [
    {
        orderRef: "1234",
        customer: "John Doe",
        amount: 40.0,
        status: "Shipped",
        items: [
            { name: "Product 1", quantity: 2 },
            { name: "Product 2", quantity: 1 }
        ]
    },
    {
        orderRef: "2212",
        customer: "Jane Smith",
        amount: 45.0,
        status: "Pending",
        items: [
            { name: "Product 3", quantity: 3 }
        ]
    }
];

@test:Config
public function testFetchAndTransform() returns error? {
    test:prepare(ordersClient).whenResource("::orders").onMethod("get").thenReturn(mockOrders);
    OrderSummary[] actual = check fetchAndTransform(date);
    test:assertEquals(actual, expectedSummaries);
}
