import ballerina/http;
import ballerina/log;

public type OrderItem record {|
    string name;
    int quantity;
|};

public type OrderSummary record {|
    string orderRef;
    string customer;
    decimal amount;
    OrderItem[] items;
    string status;
|};

configurable int port = 9091;

service /reports on new http:Listener(port) {

    resource function post summaries(OrderSummary[] summaries) returns http:Created {
        log:printInfo("Received order summaries", count = summaries.length(), data = summaries);
        return http:CREATED;
    }
}
