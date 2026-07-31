import ballerina/http;

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

configurable int port = 9093;

isolated final map<Product & readonly> products = {
    "SKU-1": {id: "SKU-1", name: "Widget", price: 19.99, stock: 120, category: TOOLS},
    "SKU-2": {id: "SKU-2", name: "Gadget", price: 149.99, stock: 45, category: ELECTRONICS},
    "SKU-3": {id: "SKU-3", name: "Sprocket", price: 5.50, stock: 500, category: HARDWARE}
};

isolated service /products on new http:Listener(port) {

    isolated resource function get [string productId]() returns Product|http:NotFound {
        lock {
            if products.hasKey(productId) {
                return products.get(productId);
            }
        }
        return http:NOT_FOUND;
    }

    isolated resource function get .(ProductCategory? category = ()) returns Product[] {
        if category is () {
            lock {
                return products.toArray().clone();
            }
        }
        lock {
            readonly & Product[] filteredProducts = from Product p in products
                   where p.category == category
                   select p;
            return filteredProducts;
        }
    }

    isolated resource function post .(Product & readonly product) returns http:Created|http:Conflict {
        lock {
            if products.hasKey(product.id) {
                return http:CONFLICT;
            }
            products[product.id] = product;
            return http:CREATED;
        }
    }
}
