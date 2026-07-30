import ballerina/http;
import ballerina/io;

configurable string ordersEP = "http://localhost:9090";
configurable string reportsEP = "http://localhost:9091";

type LineItem record {|
    string productId;
    string name;
    int quantity;
    decimal unitPrice;
|};

type Order record {|
    int id;
    string date;
    string customerId;
    string customerName;
    string status;
    LineItem[] items;
    decimal total;
|};

public type Item record {|
    string name;
    int quantity;
|};

public type OrderSummary record {|
    string orderRef;
    string customer;
    decimal amount;
    Item[] items;
    string status;
|};

final http:Client ordersClient = check initializeOrdersClient();
final http:Client reportsClient = check initializeReportsClient();

public function main(string date) returns error? {
    OrderSummary[] summaries = check fetchAndTransform(date);

    http:Response response = check reportsClient->/reports/summaries.post(summaries);

    if response.statusCode == http:STATUS_CREATED {
        io:println(string `Posted ${summaries.length()} order summaries for ${date}.`);
    } else {
        io:println(string `Failed to post order summaries for ${date}. Status: ${response.statusCode}`);
    }
}

function fetchAndTransform(string date) returns OrderSummary[]|error {
    Order[] orders = check ordersClient->/orders(date = date);
    return from Order orderItem in orders
        select toSummary(orderItem);
}

function toSummary(Order orderRes) returns OrderSummary => {
    orderRef: orderRes.id.toString(),
    customer: orderRes.customerName,
    amount: orderRes.total,
    status: orderRes.status,
    items: from var itemsItem in orderRes.items
        select {name: itemsItem.name, quantity: itemsItem.quantity}
};

function initializeOrdersClient() returns http:Client|error {
    return new (ordersEP);
}

function initializeReportsClient() returns http:Client|error {
    return new (reportsEP);
}
