# List all products
GET http://localhost:9095/products
HTTP 200

# Get a single product
GET http://localhost:9095/products/SKU-1
HTTP 200

# Get a missing product
GET http://localhost:9095/products/SKU-99
HTTP 404

# Filter by category
GET http://localhost:9095/products?category=ELECTRONICS
HTTP 200

# Invalid category — enum rejection
GET http://localhost:9095/products?category=FURNITURE
HTTP 400

# Create a new product
POST http://localhost:9095/products
Content-Type: application/json
{
    "id": "SKU-4",
    "name": "Bracket",
    "price": 8.50,
    "stock": 75,
    "category": "HARDWARE"
}
HTTP 201

# Duplicate id
POST http://localhost:9095/products
Content-Type: application/json
{
    "id": "SKU-1",
    "name": "Duplicate",
    "price": 1,
    "stock": 1,
    "category": "TOOLS"
}
HTTP 409