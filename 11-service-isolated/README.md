# 11. Service — isolated

Same API as sample 10, this time with the shared mutable state properly protected. `bal build` on sample 10 emits hints for each resource:

```
concurrent calls will not be made to this method since the method is not an 'isolated' method
```

Ballerina serializes non-isolated resource methods, so the sample 10 code is safe but throttled. Marking the service and its resources `isolated` lets Ballerina schedule them concurrently - i.e., a gurantee that no shared mutable state is accessed in an unsafe manner, preventing data races.

## What changed from sample 10

- `map<Product>` → `isolated final map<Product>` — the compiler treats it as isolated shared state.
- `service /products` → `isolated service /products`.
- Each resource → `isolated resource function ...`.
- All access to `products` wrapped in a `lock { ... }` block.
- Values passing across the lock boundary are `.clone()`d, since the isolation checker won't let a reference to a mutable value escape.

## `readonly` — the alternative

Ballerina's `readonly` marks a value as deeply immutable. Immutable values are safe to share across isolation boundaries without cloning — nothing can be modified, so no data race. A `readonly` store also doesn't need `lock` blocks around reads.

The trade-off: no writes. Since this sample supports `POST /products`, the store has to stay mutable and pay the `lock` + `.clone()` price on reads.

## Reading data with a filter

Query expressions inside a `lock` restrict what you can capture from outside. Simplest pattern: pull a snapshot out under the lock, filter outside:

```ballerina
isolated resource function get .(ProductCategory? category = ()) returns Product[] {
    Product[] all;
    lock {
        all = products.toArray().clone();
    }
    if category is () {
        return all;
    }
    return from Product p in all
           where p.category == category
           select p;
}
```

## Run

Same as sample 10 — endpoints unchanged (`GET /products`, `GET /products/{id}`, `POST /products`, `?category=` filter). `api.hurl` copied over.

```
cd 11-service-isolated
bal run
```

Then:

```
hurl --test api.hurl
```

## What's the win?

Sample 10's warnings go away, and requests can be handled concurrently under load. On a tutorial-scale demo the difference is invisible; on a real service it's the difference between "correct but single-threaded" and "correct and concurrent."
