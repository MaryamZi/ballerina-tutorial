import ballerina/io;
import products_persist.products as store;

final store:Client dbClient = check new;

public function main() returns error? {
    store:Product product = check dbClient->/products/["SKU-1"];
    io:println("Fetched: ", product);
}
