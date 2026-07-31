import ballerina/io;

type LineItem record {|
    string productId;
    string name;
    int quantity;
    decimal unitPrice;
|};

type Order record {|
    int id;
    string date;
    string customerId;
    string customerName;
    string status;
    LineItem[] items;
    decimal total;
|};

type Customer record {|
    string id;
    string firstName;
    string lastName;
    string email;
|};

type NotificationTarget record {|
    string recipientId;
    string name;
    string email;
|};

type OrderItem record {|
    string name;
    int quantity;
|};

type EnrichedOrder record {|
    string orderRef;
    string customer;
    string email;
    decimal amount;
    OrderItem[] items;
    string status;
|};

final Order sampleOrder = {
    id: 1001,
    date: "2026-07-29",
    customerId: "CUST-42",
    customerName: "Alice Perera",
    status: "COMPLETED",
    items: [
        {productId: "SKU-1", name: "Widget", quantity: 2, unitPrice: 19.99}
    ],
    total: 39.98
};

final Customer sampleCustomer = {
    id: "CUST-42",
    firstName: "Alice",
    lastName: "Perera",
    email: "alice@example.com"
};

// One-in, one-out — combines firstName and lastName into a single display name.
function toNotificationTarget(Customer customer) returns NotificationTarget => {
    recipientId: customer.id,
    name: customer.firstName + " " + customer.lastName,
    email: customer.email
};

// Two-in, one-out — join by customerId.
// Uses toString() to get the string representation of Order.id (int), combines the customer's
// firstName and lastName into a single display name, and projects each LineItem
// into a leaner OrderItem.
function toEnrichedOrder(Order 'order, Customer customer) returns EnrichedOrder => {
    orderRef: 'order.id.toString(),
    customer: string `${customer.firstName} ${customer.lastName}`,
    email: customer.email,
    amount: 'order.total,
    items: from LineItem li in 'order.items
        select {name: li.name, quantity: li.quantity},
    status: 'order.status
};

public function main() {
    NotificationTarget target = toNotificationTarget(sampleCustomer);
    io:println("NotificationTarget:");
    io:println("  ", target);

    EnrichedOrder enriched = toEnrichedOrder(sampleOrder, sampleCustomer);
    io:println("\nEnrichedOrder:");
    io:println("  ", enriched);
}
