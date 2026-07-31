# 2. JSON and XML — other wire formats

Sample 1 used typed records, which validates and binds the entire payload in one go. Alternatively, you can work with it directly as `json`.

This sample demonstrates the `json` and `xml` types.

- The **JSON** section hits the same orders endpoint as sample 1, but binds the response as raw `json` and picks fields out with `check`.
- The **XML** section hits a customers backend that responds with XML. Ballerina has a first-class `xml` type with XPath-style navigation.

The `ballerina/data.jsondata` and `ballerina/data.xmldata` libraries also support JSONPath and XPath.

## Endpoints

```
GET http://localhost:9090/orders/1001                (JSON)
GET http://localhost:9096/customers/CUST-42          (XML)
```

## XML

`customer/<id>` navigates to `<id>` children. `.get(0)` picks the first match, and `.data()` returns the text content. VS Code's **Paste XML as Record** generates a matching record type for record binding instead.

## Run

```
cd backends/orders && bal run       # terminal 1
cd backends/customers && bal run    # terminal 2
cd 02-json-and-xml && bal run       # terminal 3
```

## Expected output

```
Order 1001 for Customer Alice Perera of Total value $39.98
Customer details: ID CUST-42, Name Alice Perera
```
