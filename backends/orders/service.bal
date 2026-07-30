import ballerina/http;

public enum OrderStatus {
    PENDING,
    COMPLETED,
    CANCELLED
};

public type LineItem record {|
    string productId;
    string name;
    int quantity;
    decimal unitPrice;
|};

public type Order record {|
    int id;
    string date;
    string customerId;
    string customerName;
    OrderStatus status;
    LineItem[] items;
    decimal total;
|};

configurable int port = 9090;

final readonly & map<Order> orders = {
    "1001": {
        id: 1001,
        date: "2026-07-29",
        customerId: "CUST-42",
        customerName: "Alice Perera",
        status: COMPLETED,
        items: [{productId: "SKU-1", name: "Widget", quantity: 2, unitPrice: 19.99}],
        total: 39.98
    },
    "1002": {
        id: 1002,
        date: "2026-07-29",
        customerId: "CUST-58",
        customerName: "Bob Silva",
        status: COMPLETED,
        items: [{productId: "SKU-2", name: "Gadget", quantity: 1, unitPrice: 149.99}],
        total: 149.99
    },
    "1003": {
        id: 1003,
        date: "2026-07-29",
        customerId: "CUST-42",
        customerName: "Alice Perera",
        status: COMPLETED,
        items: [{productId: "SKU-3", name: "Sprocket", quantity: 3, unitPrice: 5.50}],
        total: 16.50
    },
    "1004": {
        id: 1004,
        date: "2026-07-29",
        customerId: "CUST-77",
        customerName: "Carol Nayak",
        status: PENDING,
        items: [
            {productId: "SKU-1", name: "Widget", quantity: 1, unitPrice: 19.99},
            {productId: "SKU-2", name: "Gadget", quantity: 2, unitPrice: 149.99}
        ],
        total: 319.97
    },
    "1005": {
        id: 1005,
        date: "2026-07-29",
        customerId: "CUST-58",
        customerName: "Bob Silva",
        status: CANCELLED,
        items: [{productId: "SKU-1", name: "Widget", quantity: 1, unitPrice: 19.99}],
        total: 19.99
    },
    "1006": {
        id: 1006,
        date: "2026-07-28",
        customerId: "CUST-42",
        customerName: "Alice Perera",
        status: COMPLETED,
        items: [{productId: "SKU-2", name: "Gadget", quantity: 1, unitPrice: 149.99}],
        total: 149.99
    },
    "1007": {
        id: 1007,
        date: "2026-07-29",
        customerId: "CUST-58",
        customerName: "Bob Silva",
        status: PENDING,
        items: [{productId: "SKU-3", name: "Sprocket", quantity: 4, unitPrice: 5.50}],
        total: 22.00
    },
    "1008": {
        id: 1008,
        date: "2026-07-29",
        customerId: "CUST-91",
        customerName: "Diana Fernando",
        status: PENDING,
        items: [
            {productId: "SKU-1", name: "Widget", quantity: 5, unitPrice: 19.99},
            {productId: "SKU-3", name: "Sprocket", quantity: 2, unitPrice: 5.50}
        ],
        total: 110.95
    }
};

service on new http:Listener(port) {

    resource function get orders(string? date = ()) returns Order[] {
        if date is () {
            return orders.toArray();
        }

        return from Order 'order in orders
               where 'order.date == date
               select 'order;
    }

    resource function get orders/[int orderId]() returns Order|http:NotFound {
        string key = orderId.toString();
        if orders.hasKey(key) {
            return orders.get(key);
        }
        return http:NOT_FOUND;
    }
}
