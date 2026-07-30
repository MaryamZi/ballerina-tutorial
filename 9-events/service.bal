import ballerina/log;
import ballerinax/kafka;

public type ProductEvent record {|
    string eventType;
    string productId;
    string name;
    decimal price;
|};

configurable string bootstrapServers = ?;
configurable string topic = ?;
configurable string groupId = ?;

service kafka:Service on new kafka:Listener(bootstrapServers, 
        {groupId, topics: topic}) {
    remote function onConsumerRecord(ProductEvent[] events) returns error? {
        foreach ProductEvent event in events {
            log:printInfo("Received event",
                    eventType = event.eventType,
                    productId = event.productId,
                    name = event.name,
                    price = event.price);
        }
    }
}
