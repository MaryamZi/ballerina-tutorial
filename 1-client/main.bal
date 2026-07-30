import ballerina/http;
import ballerina/io;

type Item record {|
    string productId;
    string name;
    int quantity;
    decimal unitPrice;
    json...;
|};

type Order record {|
    int id;
    string date;
    string customerId;
    string customerName;
    string status;
    Item[] items;
    decimal total;
    json...;
|};

public function main() returns error? {
    http:Client ordersClient = check new ("http://localhost:9090");

    Order[] orders = check ordersClient->/orders(date = "2026-07-29");

    io:println("Pending orders on 2026-07-29:");
    foreach Order 'order in orders {
        io:println(string `Order ${'order.id} for Customer '${
            'order.customerName}' of Total value $${'order.total} is ${'order.status}`);
    }
}
