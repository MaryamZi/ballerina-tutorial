import ballerina/persist as _;
import ballerinax/persist.sql;

type Product record {|
    readonly string id;
    string name;
    @sql:Decimal {precision: [10, 2]}
    decimal price;
    int stock;
    string category;
|};
