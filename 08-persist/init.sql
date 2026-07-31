-- Schema mirrors what `bal persist generate` writes to generated/products/script.sql.

DROP TABLE IF EXISTS "Product";

CREATE TABLE "Product" (
    "id" VARCHAR(191) NOT NULL,
    "name" VARCHAR(191) NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "stock" INT NOT NULL,
    "category" VARCHAR(191) NOT NULL,
    PRIMARY KEY("id")
);

INSERT INTO "Product" ("id", "name", "price", "stock", "category") VALUES
    ('SKU-1', 'Widget',   19.99,  120, 'TOOLS'),
    ('SKU-2', 'Gadget',   149.99,  45, 'ELECTRONICS'),
    ('SKU-3', 'Sprocket',   5.50, 500, 'HARDWARE');
