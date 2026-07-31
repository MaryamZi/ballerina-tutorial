import ballerina/http;
import ballerina/io;

configurable string ordersEP = ?;
configurable string reportsEP = ?;

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

type OrderItem record {|
    string name;
    int quantity;
|};

type OrderSummary record {|
    string orderRef;
    string customer;
    decimal amount;
    OrderItem[] items;
    string status;
|};

final http:Client ordersClient = check new (ordersEP);
final http:Client reportsClient = check new (reportsEP);

public function main(string date) returns error? {
    Order[] orders = check ordersClient->/orders(date = date);

    OrderSummary[] summaries = from Order orderItem in orders
        select toSummary(orderItem);

    http:Response _ = check reportsClient->/reports/summaries.post(summaries);
    io:println(string `Posted ${summaries.length()} order summaries for ${date}.`);
}

function toSummary(Order orderRes) returns OrderSummary => {
    orderRef: orderRes.id.toString(),
    customer: orderRes.customerName,
    amount: orderRes.total,
    items: from LineItem li in orderRes.items
        select {name: li.name, quantity: li.quantity},
    status: orderRes.status
};
