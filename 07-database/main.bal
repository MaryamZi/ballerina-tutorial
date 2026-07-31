import ballerina/io;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

configurable string dbHost = ?;
configurable int dbPort = ?;
configurable string dbName = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;

type Product record {|
    string id;
    string name;
    decimal price;
    int stock;
    string category;
|};

final postgresql:Client dbClient = check new (
    host = dbHost,
    port = dbPort,
    database = dbName,
    username = dbUser,
    password = dbPassword
);

public function main() returns error? {
    Product product = check dbClient->queryRow(
        `SELECT id, name, price, stock, category FROM products WHERE id = 'SKU-1'`
    );
    io:println("Fetched: ", product);
}
