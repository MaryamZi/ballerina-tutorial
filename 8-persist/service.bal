import ballerina/http;
import ballerina/persist;
import products_persist.products as store;

public enum ProductCategory {
    TOOLS,
    ELECTRONICS,
    HARDWARE
}

configurable int servicePort = ?;

final store:Client dbClient = check new;

service /products on new http:Listener(servicePort) {

    resource function get .(ProductCategory? category = ()) returns store:Product[]|persist:Error {
        stream<store:Product, persist:Error?> productStream;
        if category is () {
            productStream = dbClient->/products();
        } else {
            productStream = dbClient->/products(whereClause = `category = ${category}`);
        }
        return from store:Product p in productStream select p;
    }

    resource function get [string productId]() returns store:Product|http:NotFound|persist:Error {
        store:Product|persist:Error result = dbClient->/products/[productId];
        if result is persist:NotFoundError {
            return http:NOT_FOUND;
        }
        return result;
    }

    resource function post .(store:Product product) returns http:Created|http:Conflict|persist:Error {
        string[]|persist:Error inserted = dbClient->/products.post([product]);
        if inserted is persist:AlreadyExistsError {
            return http:CONFLICT;
        }
        if inserted is persist:Error {
            return inserted;
        }
        return http:CREATED;
    }
}
