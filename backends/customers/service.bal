import ballerina/http;

configurable int port = 9096;

final xml customersXml = xml `
<Customers>
    <Customer>
        <id>CUST-42</id>
        <firstName>Alice</firstName>
        <lastName>Perera</lastName>
        <email>alice@example.com</email>
    </Customer>
    <Customer>
        <id>CUST-58</id>
        <firstName>Bob</firstName>
        <lastName>Silva</lastName>
        <email>bob@example.com</email>
    </Customer>
    <Customer>
        <id>CUST-77</id>
        <firstName>Carol</firstName>
        <lastName>Nayak</lastName>
        <email>carol@example.com</email>
    </Customer>
    <Customer>
        <id>CUST-91</id>
        <firstName>Diana</firstName>
        <lastName>Fernando</lastName>
        <email>diana@example.com</email>
    </Customer>
</Customers>`;

service /customers on new http:Listener(port) {

    resource function get .() returns xml {
        return customersXml;
    }

    resource function get [string customerId]() returns xml|http:NotFound {
        xml matches = customersXml/<Customer>.filter(c => (c/<id>/*).toString() == customerId);
        if matches.length() == 0 {
            return http:NOT_FOUND;
        }
        return matches;
    }
}
