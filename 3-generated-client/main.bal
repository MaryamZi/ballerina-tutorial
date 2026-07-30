import automation.orders_client as orders;

import ballerina/io;

public function main() returns error? {
    orders:Client ordersClient = check new;

    orders:Order[] orders = check ordersClient->/orders(date = "2026-07-29");

    io:println("Pending orders on 2026-07-29:");
    foreach orders:Order 'order in orders {
        io:println(string `Order ${'order.id} for Customer '${
            'order.customerName}' of Total value $${'order.total} is ${'order.status}`);
    }
}
