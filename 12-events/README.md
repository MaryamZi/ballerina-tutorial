# 12. Events — a Kafka consumer

A Ballerina service that subscribes to a Kafka topic (`product-events`) and logs each message it receives. The payload is bound to a typed `ProductEvent` record — no manual JSON parsing.

## Steps

### 1. Start Kafka

```
cd 12-events
docker compose up -d
```

Single-container KRaft mode — no ZooKeeper.

### 2. Create the Ballerina package

```
bal new events_consumer
cd events_consumer
```

### 3. Configure the consumer

Copy `Config.toml.example` to `Config.toml`:

```toml
bootstrapServers = "localhost:9092"
topic = "product-events"
groupId = "product-events-consumer"
```

### 4. Define the event record

```ballerina
public type ProductEvent record {|
    string eventType;
    string productId;
    string name;
    decimal price;
|};
```

### 5. Attach the consumer service to a `kafka:Listener`

```ballerina
service kafka:Service on new kafka:Listener(bootstrapServers, {groupId, topics: topic}) {
    remote function onConsumerRecord(ProductEvent[] events) returns error? {
        foreach ProductEvent event in events {
            log:printInfo("Received event", eventType = event.eventType, productId = event.productId);
        }
    }
}
```

`onConsumerRecord` receives an **array** — Kafka delivers records in batches. Each element is deserialized to `ProductEvent`; malformed messages are skipped (`autoSeekOnValidationFailure` defaults to `true`).

### 6. Run the consumer

```
bal run
```

Stays in the foreground waiting for messages.

### 7. Publish a test event

In a second terminal, pipe a JSON line into the container's console producer:

```
echo '{"eventType":"CREATED","productId":"SKU-9","name":"Anvil","price":42.50}' \
  | docker exec -i 12-events-kafka-1 /opt/kafka/bin/kafka-console-producer.sh \
      --bootstrap-server localhost:9092 --topic product-events
```

Consumer log:

```
Received event  eventType="CREATED"  productId="SKU-9"  name="Anvil"  price=42.50
```

## Offsets

`autoCommit` is `true` by default — offsets commit after each `onConsumerRecord` call. For manual control, add `kafka:Caller` as the first parameter and call `caller->commit()` yourself.

## Tear down

```
docker compose down
```
