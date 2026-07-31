import ballerina/http;

configurable string ordersEP = "http://localhost:9090";
configurable int servicePort = 9098;

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

type OrderSummary record {|
    string orderRef;
    string customer;
    decimal amount;
    int lineCount;
    string status;
|};

final http:Client ordersClient = check initializeOrdersClient();

service /summaries on new http:Listener(servicePort) {

    resource function get .(string date) returns OrderSummary[]|error {
        return fetchAndTransform(date);
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
    lineCount: orderRes.items.length(),
    status: orderRes.status
};

function initializeOrdersClient() returns http:Client|error {
    return new (ordersEP);
}
