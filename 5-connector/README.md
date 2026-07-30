# 5. Connector — send an email via Gmail

Fetches orders for a given date, builds a summary email body, and sends it via the `ballerinax/googleapis.gmail` connector.

To keep the tutorial runnable without real Google credentials, `backends/gmail-mock/` impersonates the Gmail message-send endpoint (`POST /users/me/messages/send`) and OAuth token refresh (`POST /oauth2/token`). Pointing the connector at a mock is a matter of overriding its `serviceUrl` — the flip to real Gmail is one config change.

## Basic connector snippet

```ballerina
import ballerinax/googleapis.gmail;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;

final gmail:Client gmailClient = check new ({
    auth: {refreshToken, clientId, clientSecret, refreshUrl}
});

isolated function sendEmail(string[] to, string subject, string body)
        returns gmail:Message|error {
    return gmailClient->/users/me/messages/send.post({to, subject, bodyInText: body});
}
```

## Endpoints used

```
GET  http://localhost:9090/orders?date=2026-07-29         (orders backend)
POST http://localhost:9092/users/me/messages/send         (gmail-mock)
POST http://localhost:9092/oauth2/token                   (gmail-mock, called by the connector's OAuth refresh)
```

## Set up

```
bal new connector
```

Add the connector's import and it resolves on the next `bal build`. All external values go into `Config.toml`:

```toml
gmailEP = "http://localhost:9092"
refreshUrl = "http://localhost:9092/oauth2/token"
refreshToken = "dummy-refresh"
clientId = "dummy-client"
clientSecret = "dummy-secret"
toEmail = "test@example.com"
```

The mock accepts any credential values.

## Run

Start the orders backend and the gmail mock:

```
cd backends/orders && bal run       # terminal 1
cd backends/gmail-mock && bal run   # terminal 2
```

Then run the sample with a date:

```
cd 5-connector
bal run -- 2026-07-29
```

The mock logs each incoming send. The email body arrives as a base64-encoded RFC 5322 payload — the `raw` field of the message body — that's what Gmail's API accepts.

## Switching to real Gmail

Drop the `gmailEP` and `refreshUrl` overrides from `Config.toml` (letting them default to Google's endpoints) and fill in real OAuth credentials from Google Cloud Console. No code change.
