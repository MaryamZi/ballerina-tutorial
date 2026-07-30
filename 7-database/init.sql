CREATE TABLE products (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    category VARCHAR(32) NOT NULL
);

INSERT INTO products (id, name, price, stock, category) VALUES
    ('SKU-1', 'Widget', 19.99, 120, 'TOOLS'),
    ('SKU-2', 'Gadget', 149.99, 45, 'ELECTRONICS'),
    ('SKU-3', 'Sprocket', 5.50, 500, 'HARDWARE');
