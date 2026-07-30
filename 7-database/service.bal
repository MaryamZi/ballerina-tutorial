import ballerina/http;
import ballerina/sql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

public enum ProductCategory {
    TOOLS,
    ELECTRONICS,
    HARDWARE
}

public type Product record {|
    string id;
    string name;
    decimal price;
    int stock;
    ProductCategory category;
|};

configurable string dbHost = ?;
configurable int dbPort = ?;
configurable string dbName = ?;
configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable int port = ?;

final postgresql:Client dbClient = check new (
    host = dbHost,
    port = dbPort,
    database = dbName,
    username = dbUser,
    password = dbPassword
);

service /products on new http:Listener(port) {

    resource function get .(ProductCategory? category = ()) returns Product[]|error {
        sql:ParameterizedQuery query = category is ()
            ? `SELECT id, name, price, stock, category FROM products`
            : `SELECT id, name, price, stock, category FROM products WHERE category = ${category}`;
        stream<Product, sql:Error?> resultStream = dbClient->query(query);
        return from Product p in resultStream select p;
    }

    resource function get [string productId]() returns Product|http:NotFound|error {
        Product|sql:Error result = dbClient->queryRow(
            `SELECT id, name, price, stock, category FROM products WHERE id = ${productId}`
        );
        if result is sql:NoRowsError {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function post .(Product product) returns http:Created|http:Conflict|error {
        Product|sql:Error existing = dbClient->queryRow(
            `SELECT id, name, price, stock, category FROM products WHERE id = ${product.id}`
        );
        if existing is Product {
            return http:CONFLICT;
        }
        _ = check dbClient->execute(`
            INSERT INTO products (id, name, price, stock, category)
            VALUES (${product.id}, ${product.name}, ${product.price}, ${product.stock}, ${product.category})
        `);
        return http:CREATED;
    }
}
