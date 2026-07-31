import ballerina/http;
import ballerina/io;

configurable string flakyEP = "http://localhost:9097";

final http:Client flakyClient = check new (flakyEP,
    retryConfig = {
        count: 3,
        interval: 1,
        backOffFactor: 2.0,
        statusCodes: [502, 503, 504]
    }
);

public function main() returns error? {
    json response = check flakyClient->/flaky/orders;
    io:println("Response: ", response);
}
