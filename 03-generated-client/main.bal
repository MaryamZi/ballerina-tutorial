import automation.orders_client as orders;

import ballerina/io;

public function main() returns error? {
    orders:Client ordersClient = check new;

    orders:Order[] ordersList = check ordersClient->/orders(date = "2026-07-29");
    orders:Order firstOrder = ordersList[0];

    io:println(string `Order ${firstOrder.id} for Customer ${
        firstOrder.customerName} of Total value $${firstOrder.total}`);
}
