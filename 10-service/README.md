# 10. Service — expose an HTTP API (Integration as an API)

An HTTP service that manages products in memory. Exposes list/filter, get-by-id, and create endpoints. Same shape as the mock services under `backends/`, but simpler — a good first look at writing a Ballerina service.

## Endpoints

```
GET  http://localhost:9093/products
GET  http://localhost:9093/products?category=<TOOLS|ELECTRONICS|HARDWARE>
GET  http://localhost:9093/products/{productId}
POST http://localhost:9093/products
```

- `category` on the list endpoint is optional; invalid values return 400 (the listener rejects strings that aren't in the `ProductCategory` enum).
- `GET /products/{productId}` returns 404 for unknown ids.
- `POST /products` returns 201 on success, 409 if `id` already exists.

## Sample data

Seeded on startup — matches the `productId` values used in the orders backend:

```
SKU-1  Widget    19.99  stock 120   TOOLS
SKU-2  Gadget   149.99  stock  45   ELECTRONICS
SKU-3  Sprocket   5.50  stock 500   HARDWARE
```

## Set up

```
bal new products_service
```

Add the following types and variables.

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

## Run

```
cd 10-service
bal run
```

## Exercise the API

`api.hurl` in this directory drives each endpoint with the expected status code. Install [hurl](https://hurl.dev/), then:

```
hurl --test api.hurl
```

## Generate the OpenAPI spec

Once the service compiles, produce an OAS document from it:

```
bal openapi -i service.bal --json
```

Emits `service_openapi.json` (or `<service_name>_openapi.json` when the service has a base path). Drop `--json` for YAML. This spec is what sample 3 feeds into `bal openapi --mode client` to generate a typed client.
