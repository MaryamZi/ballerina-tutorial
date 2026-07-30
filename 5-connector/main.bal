import ballerina/http;
import ballerinax/googleapis.gmail;

configurable string ordersEP = "http://localhost:9090";
configurable string gmailEP = "https://gmail.googleapis.com/gmail/v1";

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;
configurable string toEmail = ?;

final http:Client ordersClient = check new (ordersEP);

final gmail:Client gmailClient = check new (
    {auth: {refreshToken, clientId, clientSecret, refreshUrl}},
    gmailEP
);

public function main(string date) returns error? {
    Order[] orders = check ordersClient->/orders(date = date);

    string[] to = [toEmail];
    string subject = string `Order Summary for ${date}`;
    string body = string `Total Orders: ${orders.length()}
        ${buildOrderSummary(orders)}`;

    _ = check gmailClient->/users/me/messages/send.post({to, subject, bodyInText: body});
}

function buildOrderSummary(Order[] orders) returns string =>
    from Order orderItem in orders
        select string `Order ID: ${orderItem.id}, Customer: ${
                orderItem.customerName}, Total: ${orderItem.total}${"\n"}`;

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
