# 2. Work with JSON and XML directly

Sample 1 used typed records — the entire payload validated and bound in one step. This sample shows the alternatives: treat the response as raw `json`, or as `xml` when the wire format is XML.

## Steps

### 1. Start the backends

```
cd backends/orders && bal run       # terminal 1 — port 9090, JSON
cd backends/customers && bal run    # terminal 2 — port 9096, XML
```

### 2. Create the Ballerina package

```
bal new json_and_xml
cd json_and_xml
```

### 3. Fetch as JSON

In `main`, hit `GET /orders/1001`, bind the response to `json`, and pull out fields with `check`:

```ballerina
json orderJson = check ordersClient->/orders/[1001];
int id = check orderJson.id;
string name = check orderJson.customerName;
```

Every access is checked at runtime — no compile-time guarantee that `orderJson.id` is an `int`.

### 4. Fetch as XML

Hit `GET /customers/CUST-42` on the customers backend. Ballerina's `xml` type supports XPath-style navigation (`/<id>`, `.get(0)`, `.data()`):

```ballerina
xml customer = check customersClient->/customers/["CUST-42"];
xml:Element idElement = customer/<id>.get(0);
```

VS Code's **Paste XML as Record** generates a matching record type if you'd rather bind the XML to a record.

### 5. Run

```
bal run
```

Expected output:

```
Order 1001 for Customer Alice Perera of Total value $39.98
Customer details: ID CUST-42, Name Alice Perera
```

## JSONPath and XPath

The `ballerina/data.jsondata` and `ballerina/data.xmldata` libraries support JSONPath and XPath too.
