import ballerina/http;
import ballerina/log;

configurable int port = 9097;
configurable int failuresBeforeSuccess = 2;

int attempts = 0;

service /flaky on new http:Listener(port) {

    resource function get orders() returns json|http:ServiceUnavailable {
        attempts += 1;
        log:printInfo("Flaky backend hit", attempt = attempts);
        if attempts <= failuresBeforeSuccess {
            return http:SERVICE_UNAVAILABLE;
        }
        attempts = 0;
        return {message: "Success after retries", ordersCount: 3};
    }
}
