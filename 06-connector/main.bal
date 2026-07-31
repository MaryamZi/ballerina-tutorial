import ballerinax/googleapis.gmail;
import ballerina/io;

// To mock for demonstration. Usually need not specify explicitly.
configurable string gmailEP = "https://gmail.googleapis.com/gmail/v1";

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;
configurable string toEmail = ?;

final gmail:Client gmailClient = check new (
    {auth: {refreshToken, clientId, clientSecret, refreshUrl}},
    gmailEP
);

public function main() returns error? {
    gmail:Message message = check gmailClient->/users/me/messages/send.post({
        to: [toEmail],
        subject: "Hello from Ballerina",
        bodyInText: "This message was sent via the ballerinax/googleapis.gmail connector."
    });
    io:println("Sent message, Message ID: ", message.id);
}
