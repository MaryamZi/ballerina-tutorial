import ballerina/http;
import ballerina/io;

public function main() returns error? {
    // JSON — orders backend responds with JSON. Access the response as a
    // `json` value; each field is pulled out with `check`.
    http:Client ordersClient = check new ("http://localhost:9090");
    json orderJson = check ordersClient->/orders/[1001];

    int id = check orderJson.id;
    string name = check orderJson.customerName;
    decimal total = check orderJson.total;
    io:println(string `Order ${id} for Customer ${name} of Total value $${total}`);

    // XML — customers backend responds with XML. Ballerina's built-in `xml`
    // type supports XPath-style navigation (`/<firstName>`) and `.data()` for text.
    http:Client customersClient = check new ("http://localhost:9096");
    xml customer = check customersClient->/customers/["CUST-42"];

    xml:Element customerIdElement = customer/<id>.get(0);
    xml:Element firstNameElement = customer/<firstName>.get(0);
    xml:Element lastNameElement = customer/<lastName>.get(0);
    io:println(string `Customer details: ID ${customerIdElement.data()}, Name ${
            firstNameElement.data()} ${lastNameElement.data()}`);
}
