# 6. Connector — send an email via Gmail

Send a message through the `ballerinax/googleapis.gmail` connector. `main.bal` shows the minimum: initialize the client and call `->/users/me/messages/send.post(...)`.

To keep the tutorial runnable without real Google credentials, `backends/gmail-mock/` mocks the Gmail message-send endpoint (`POST /users/me/messages/send`) and OAuth token refresh (`POST /oauth2/token`). Pointing the connector at the mock is a matter of overriding its `serviceUrl` — the flip to real Gmail is one config change.

## Steps

### 1. Start the Gmail mock

```
cd backends/gmail-mock && bal run
```

Serves the message-send endpoint on port 9092.

### 2. Create the Ballerina package

```
bal new connector
cd connector
```

Add the import — `bal build` resolves the dependency from Central on the next build:

```ballerina
import ballerinax/googleapis.gmail;
```

### 3. Configure the connector

Copy `Config.toml.example` to `Config.toml`:

```toml
gmailEP = "http://localhost:9092"
refreshUrl = "http://localhost:9092/oauth2/token"
refreshToken = "dummy-refresh"
clientId = "dummy-client"
clientSecret = "dummy-secret"
toEmail = "test@example.com"
```

The mock accepts any credential values.

### 4. Initialize the client

Point the client at the mock's `serviceUrl`. Pass the OAuth config as the auth field:

```ballerina
final gmail:Client gmailClient = check new (
    {auth: {refreshToken, clientId, clientSecret, refreshUrl}},
    gmailEP
);
```

### 5. Send a message from `main`

```ballerina
gmail:Message message = check gmailClient->/users/me/messages/send.post({
    to: [toEmail],
    subject: "Hello from Ballerina",
    bodyInText: "Sent via the ballerinax/googleapis.gmail connector."
});
```

### 6. Run

```
bal run
```

Output:

```
Sent message, Message ID: mock-message-id
```

The mock logs the incoming send. The email body arrives as a base64-encoded RFC 5322 payload — the `raw` field of the message body — that's what Gmail's API accepts.

## Switching to real Gmail

Drop the `gmailEP` and `refreshUrl` overrides from `Config.toml` (letting them default to Google's endpoints) and fill in real OAuth credentials from Google Cloud Console. No code change.

## Extended example — send an order summary

Wire the connector call into an automation flow — fetch orders, build a summary, send. Uses two clients (`http:Client` for orders, `gmail:Client` for send).

```ballerina
import ballerina/http;
import ballerinax/googleapis.gmail;

configurable string ordersEP = "http://localhost:9090";
configurable string gmailEP = "https://gmail.googleapis.com/gmail/v1";

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshUrl = ?;
configurable string toEmail = ?;

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
```

Run with a date argument (`bal run -- 2026-07-29`) after also starting the orders backend.
