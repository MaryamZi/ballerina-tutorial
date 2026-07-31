# 10. Service — expose an HTTP API

An HTTP service that manages products in memory. Exposes list/filter, get-by-id, and create endpoints — a first look at writing a Ballerina service.

## Steps

### 1. Create the Ballerina package

```
bal new products_service
cd products_service
```

### 2. Define the types and seed data

```ballerina
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

final map<Product> products = {
    "SKU-1": {id: "SKU-1", name: "Widget", price: 19.99, stock: 120, category: TOOLS},
    "SKU-2": {id: "SKU-2", name: "Gadget", price: 149.99, stock: 45, category: ELECTRONICS},
    "SKU-3": {id: "SKU-3", name: "Sprocket", price: 5.50, stock: 500, category: HARDWARE}
};
```

### 3. Write the service

`service /products on new http:Listener(port)` with three resources:

- `resource function get .(ProductCategory? category = ())` — list, with an optional category filter. Invalid `category` values are rejected by the listener with 400.
- `resource function get [string productId]()` — 200 with the product, or 404.
- `resource function post .(Product product)` — 201 on success, 409 if `id` already exists.

### 4. Run

```
bal run
```

### 5. Exercise the API

`api.hurl` drives every endpoint with the expected status code. Install [hurl](https://hurl.dev/), then:

```
hurl --test api.hurl
```

## Endpoints

```
GET  http://localhost:9093/products
GET  http://localhost:9093/products?category=<TOOLS|ELECTRONICS|HARDWARE>
GET  http://localhost:9093/products/{productId}
POST http://localhost:9093/products
```

## Generate an OpenAPI spec

Once the service compiles:

```
bal openapi -i service.bal --json
```

Emits `service_openapi.json` (or `<service_name>_openapi.json` when the service has a base path). Drop `--json` for YAML. This spec is what sample 3 feeds into `bal openapi --mode client` to generate a typed client.
