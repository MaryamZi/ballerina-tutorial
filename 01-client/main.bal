import ballerina/http;
import ballerina/io;

type LineItem record {|
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
    LineItem[] items;
    decimal total;
    json...;
|};

public function main() returns error? {
    http:Client ordersClient = check new ("http://localhost:9090");
    Order 'order = check ordersClient->/orders/[1001];
    io:println(string `Order ${'order.id} for Customer ${
            'order.customerName} of Total value $${'order.total}`);

    Orders orders = check ordersClient->get("/orders");
    foreach Order item in orders {
        io:println(string `Order ${item.id} for Customer ${
                item.customerName} of Total value $${item.total}`);
    }
}
