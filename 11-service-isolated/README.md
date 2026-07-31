# 11. Service — isolated

Same API as sample 10, this time with shared mutable state properly protected. Ballerina listeners serialize calls to non-isolated methods, so the sample 10 code is safe but throttled. Making the service and its resources `isolated` lets Ballerina schedule them concurrently — with a compile-time guarantee that shared state isn't accessed unsafely.

## Steps

### 1. Start from sample 10

Copy `10-service` as a working base, or open both side by side to compare.

### 2. Mark the state as isolated

```ballerina
isolated final map<Product & readonly> products = { ... };
```

Two things happening here:

- `isolated final` — the compiler treats `products` as isolated shared state.
- `Product & readonly` — each stored value is deeply immutable, so reads can escape the lock without cloning.

### 3. Mark the service and each resource `isolated`

```ballerina
isolated service /products on new http:Listener(port) {
    isolated resource function get [string productId]() returns Product|http:NotFound { ... }
    isolated resource function get .(ProductCategory? category = ()) returns Product[] { ... }
    isolated resource function post .(Product product) returns http:Created|http:Conflict { ... }
}
```

### 4. Wrap every access to `products` in a `lock` block

Values leaving the lock have to be safe to pass across the isolation boundary. Two ways to make them safe:

- `readonly` — a deeply immutable value can't mutate, so sharing is safe.
- `.clone()` — the caller gets an independent copy of the data.

For a single lookup, the stored value is already `Product & readonly` (from step 2), so no clone is needed:

```ballerina
isolated resource function get [string productId]() returns Product|http:NotFound {
    lock {
        if products.hasKey(productId) {
            return products.get(productId);
        }
    }
    return http:NOT_FOUND;
}
```

### 5. Handle the filter

Getting an array out of the map is different — `products.toArray()` returns a *mutable* array of readonly values. The array itself can't escape as-is. Either `.clone()` it, or type the result as `readonly & Product[]` so the whole thing is immutable:

```ballerina
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
```

### 6. Run

Endpoints are unchanged from sample 10 — `api.hurl` from that sample works here too.

```
cd 11-service-isolated
bal run
```

Then:

```
hurl --test api.hurl
```

The isolation warnings from sample 10 are gone, and Ballerina can now schedule requests concurrently.

If the store didn't need to accept writes, the entire map could be typed `readonly & map<Product>` — reads wouldn't need `lock` blocks or clones at all. `POST /products` is what forces the mutable-store + `lock` pattern here.
