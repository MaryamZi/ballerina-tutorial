import ballerina/http;
import ballerina/log;

configurable int port = 9092;

public type MessageResponse record {|
    string id;
    string threadId;
    string[] labelIds;
|};

public type TokenResponse record {|
    string access_token;
    int expires_in;
    string token_type;
|};

service on new http:Listener(port) {

    resource function post users/me/messages/send(@http:Payload json message) returns MessageResponse {
        log:printInfo("Mock Gmail — message send");
        return {id: "mock-message-id", threadId: "mock-thread-id", labelIds: ["SENT"]};
    }

    resource function post oauth2/token() returns TokenResponse {
        return {access_token: "mock-access-token", expires_in: 3600, token_type: "Bearer"};
    }
}
