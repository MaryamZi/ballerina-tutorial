# 12. Events — a Kafka consumer

A Ballerina service that subscribes to a Kafka topic (`product-events`) and logs each message it receives. The payload is bound to a typed `ProductEvent` record — no manual JSON parsing.

## Topic and message shape

```
Topic: product-events
```

Each message is a JSON object:

```json
{
  "eventType": "CREATED",
  "productId": "SKU-4",
  "name": "Bracket",
  "price": 8.50
}
```

## Set up

```
bal new events_consumer
```

Implement the consumer service using configurables for `bootstrapServers`, `topic`, and `groupId`.

Copy `Config.toml.example` to `Config.toml`:

```toml
bootstrapServers = "localhost:9092"
topic = "product-events"
groupId = "product-events-consumer"
```

## Run

Start Kafka (single-container KRaft mode — no ZooKeeper):

```
cd 12-events
docker compose up -d
```

Then run the consumer:

```
bal run
```

It stays in the foreground waiting for messages.

## Publish a test event

In a second terminal, pipe a JSON line into the container's console producer:

```
echo '{"eventType":"CREATED","productId":"SKU-9","name":"Anvil","price":42.50}' \
  | docker exec -i 12-events-kafka-1 /opt/kafka/bin/kafka-console-producer.sh \
      --bootstrap-server localhost:9092 --topic product-events
```

Consumer log:

```
time=2026-07-31T20:15:14.604+05:30 level=INFO module=tutorial/events_consumer message="Received event" eventType="CREATED" productId="SKU-9" name="Anvil" price=42.50
```

`onConsumerRecord` receives an **array** — Kafka delivers records in batches. The record is deserialized to `ProductEvent[]` automatically; malformed messages are skipped (`autoSeekOnValidationFailure` defaults to `true`).

## Offsets

`autoCommit` is `true` by default — offsets commit after each `onConsumerRecord` call. For manual control, add `kafka:Caller` as the first parameter and call `caller->commit()` yourself.

## Tear down

```
docker compose down
```
