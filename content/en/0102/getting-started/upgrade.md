---
title: Upgrading
description: 
weight: 5
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

## Upgrading from 0.8.x, 0.9.x, 0.10.0.x or 0.10.1.x to 0.10.2.0

0.10.2.0 has wire protocol changes. By following the recommended rolling upgrade plan below, you guarantee no downtime during the upgrade. However, please review the notable changes in 0.10.2.0 before upgrading. 

Starting with version 0.10.2, Java clients (producer and consumer) have acquired the ability to communicate with older brokers. Version 0.10.2 clients can talk to version 0.10.0 or newer brokers. However, if your brokers are older than 0.10.0, you must upgrade all the brokers in the Kafka cluster before upgrading your clients. Version 0.10.2 brokers support 0.8.x and newer clients. 

**For a rolling upgrade:**

  1. Update server.properties file on all brokers and add the following properties: 
     * inter.broker.protocol.version=CURRENT_KAFKA_VERSION (e.g. 0.8.2, 0.9.0, 0.10.0 or 0.10.1).
     * log.message.format.version=CURRENT_KAFKA_VERSION (See potential performance impact following the upgrade for the details on what this configuration does.) 
  2. Upgrade the brokers one at a time: shut down the broker, update the code, and restart it. 
  3. Once the entire cluster is upgraded, bump the protocol version by editing inter.broker.protocol.version and setting it to 0.10.2. 
  4. If your previous message format is 0.10.0, change log.message.format.version to 0.10.2 (this is a no-op as the message format is the same for 0.10.0, 0.10.1 and 0.10.2). If your previous message format version is lower than 0.10.0, do not change log.message.format.version yet - this parameter should only change once all consumers have been upgraded to 0.10.0.0 or later.
  5. Restart the brokers one by one for the new protocol version to take effect. 
  6. If log.message.format.version is still lower than 0.10.0 at this point, wait until all consumers have been upgraded to 0.10.0 or later, then change log.message.format.version to 0.10.2 on each broker and restart them one by one. 



**Note:** If you are willing to accept downtime, you can simply take all the brokers down, update the code and start all of them. They will start with the new protocol by default. 

**Note:** Bumping the protocol version and restarting can be done any time after the brokers were upgraded. It does not have to be immediately after. 

### Upgrading a 0.10.1 Kafka Streams Application

  * Upgrading your Streams application from 0.10.1 to 0.10.2 does not require a broker upgrade. A Kafka Streams 0.10.2 application can connect to 0.10.2 and 0.10.1 brokers (it is not possible to connect to 0.10.0 brokers though). 
  * You need to recompile your code. Just swapping the Kafka Streams library jar file will not work and will break your application. 
  * If you use a custom (i.e., user implemented) timestamp extractor, you will need to update this code, because the `TimestampExtractor` interface was changed. 
  * If you register custom metrics, you will need to update this code, because the `StreamsMetric` interface was changed. 
  * See [Streams API changes in 0.10.2](/0102/streams#streams_api_changes_0102) for more details. 



### Notable changes in 0.10.2.2

  * New configuration parameter `upgrade.from` added that allows rolling bounce upgrade from version 0.10.0.x 



### Notable changes in 0.10.2.1

  * The default values for two configurations of the StreamsConfig class were changed to improve the resiliency of Kafka Streams applications. The internal Kafka Streams producer `retries` default value was changed from 0 to 10. The internal Kafka Streams consumer `max.poll.interval.ms` default value was changed from 300000 to `Integer.MAX_VALUE`. 



### Notable changes in 0.10.2.0

  * The Java clients (producer and consumer) have acquired the ability to communicate with older brokers. Version 0.10.2 clients can talk to version 0.10.0 or newer brokers. Note that some features are not available or are limited when older brokers are used. 
  * Several methods on the Java consumer may now throw `InterruptException` if the calling thread is interrupted. Please refer to the `KafkaConsumer` Javadoc for a more in-depth explanation of this change.
  * Java consumer now shuts down gracefully. By default, the consumer waits up to 30 seconds to complete pending requests. A new close API with timeout has been added to `KafkaConsumer` to control the maximum wait time.
  * Multiple regular expressions separated by commas can be passed to MirrorMaker with the new Java consumer via the --whitelist option. This makes the behaviour consistent with MirrorMaker when used the old Scala consumer.
  * Upgrading your Streams application from 0.10.1 to 0.10.2 does not require a broker upgrade. A Kafka Streams 0.10.2 application can connect to 0.10.2 and 0.10.1 brokers (it is not possible to connect to 0.10.0 brokers though).
  * The Zookeeper dependency was removed from the Streams API. The Streams API now uses the Kafka protocol to manage internal topics instead of modifying Zookeeper directly. This eliminates the need for privileges to access Zookeeper directly and "StreamsConfig.ZOOKEEPER_CONFIG" should not be set in the Streams app any more. If the Kafka cluster is secured, Streams apps must have the required security privileges to create new topics.
  * Several new fields including "security.protocol", "connections.max.idle.ms", "retry.backoff.ms", "reconnect.backoff.ms" and "request.timeout.ms" were added to StreamsConfig class. User should pay attention to the default values and set these if needed. For more details please refer to [3.5 Kafka Streams Configs](/0102/#streamsconfigs).



### New Protocol Versions

  * [KIP-88](https://cwiki.apache.org/confluence/display/KAFKA/KIP-88%3A+OffsetFetch+Protocol+Update): OffsetFetchRequest v2 supports retrieval of offsets for all topics if the `topics` array is set to `null`. 
  * [KIP-88](https://cwiki.apache.org/confluence/display/KAFKA/KIP-88%3A+OffsetFetch+Protocol+Update): OffsetFetchResponse v2 introduces a top-level `error_code` field. 
  * [KIP-103](https://cwiki.apache.org/confluence/display/KAFKA/KIP-103%3A+Separation+of+Internal+and+External+traffic): UpdateMetadataRequest v3 introduces a `listener_name` field to the elements of the `end_points` array. 
  * [KIP-108](https://cwiki.apache.org/confluence/display/KAFKA/KIP-108%3A+Create+Topic+Policy): CreateTopicsRequest v1 introduces a `validate_only` field. 
  * [KIP-108](https://cwiki.apache.org/confluence/display/KAFKA/KIP-108%3A+Create+Topic+Policy): CreateTopicsResponse v1 introduces an `error_message` field to the elements of the `topic_errors` array. 



## Upgrading from 0.8.x, 0.9.x or 0.10.0.X to 0.10.1.0

0.10.1.0 has wire protocol changes. By following the recommended rolling upgrade plan below, you guarantee no downtime during the upgrade. However, please notice the Potential breaking changes in 0.10.1.0 before upgrade.   
Note: Because new protocols are introduced, it is important to upgrade your Kafka clusters before upgrading your clients (i.e. 0.10.1.x clients only support 0.10.1.x or later brokers while 0.10.1.x brokers also support older clients). 

**For a rolling upgrade:**

  1. Update server.properties file on all brokers and add the following properties: 
     * inter.broker.protocol.version=CURRENT_KAFKA_VERSION (e.g. 0.8.2.0, 0.9.0.0 or 0.10.0.0).
     * log.message.format.version=CURRENT_KAFKA_VERSION (See potential performance impact following the upgrade for the details on what this configuration does.) 
  2. Upgrade the brokers one at a time: shut down the broker, update the code, and restart it. 
  3. Once the entire cluster is upgraded, bump the protocol version by editing inter.broker.protocol.version and setting it to 0.10.1.0. 
  4. If your previous message format is 0.10.0, change log.message.format.version to 0.10.1 (this is a no-op as the message format is the same for both 0.10.0 and 0.10.1). If your previous message format version is lower than 0.10.0, do not change log.message.format.version yet - this parameter should only change once all consumers have been upgraded to 0.10.0.0 or later.
  5. Restart the brokers one by one for the new protocol version to take effect. 
  6. If log.message.format.version is still lower than 0.10.0 at this point, wait until all consumers have been upgraded to 0.10.0 or later, then change log.message.format.version to 0.10.1 on each broker and restart them one by one. 



**Note:** If you are willing to accept downtime, you can simply take all the brokers down, update the code and start all of them. They will start with the new protocol by default. 

**Note:** Bumping the protocol version and restarting can be done any time after the brokers were upgraded. It does not have to be immediately after. 

### Potential breaking changes in 0.10.1.0

  * The log retention time is no longer based on last modified time of the log segments. Instead it will be based on the largest timestamp of the messages in a log segment.
  * The log rolling time is no longer depending on log segment create time. Instead it is now based on the timestamp in the messages. More specifically. if the timestamp of the first message in the segment is T, the log will be rolled out when a new message has a timestamp greater than or equal to T + log.roll.ms 
  * The open file handlers of 0.10.0 will increase by ~33% because of the addition of time index files for each segment.
  * The time index and offset index share the same index size configuration. Since each time index entry is 1.5x the size of offset index entry. User may need to increase log.index.size.max.bytes to avoid potential frequent log rolling. 
  * Due to the increased number of index files, on some brokers with large amount the log segments (e.g. >15K), the log loading process during the broker startup could be longer. Based on our experiment, setting the num.recovery.threads.per.data.dir to one may reduce the log loading time. 



### Upgrading a 0.10.0 Kafka Streams Application

  * Upgrading your Streams application from 0.10.0 to 0.10.1 does require a broker upgrade because a Kafka Streams 0.10.1 application can only connect to 0.10.1 brokers. 
  * There are couple of API changes, that are not backward compatible (cf. [Streams API changes in 0.10.1](/0102/streams#streams_api_changes_0101) for more details). Thus, you need to update and recompile your code. Just swapping the Kafka Streams library jar file will not work and will break your application. 
  * Upgrading from 0.10.0.x to 0.10.1.0 or 0.10.1.1 requires an offline upgrade (rolling bounce upgrade is not supported) 
    * stop all old (0.10.0.x) application instances 
    * update your code and swap old code and jar file with new code and new jar file 
    * restart all new (0.10.1.0 or 0.10.1.1) application instances 



### Notable changes in 0.10.1.0

  * The new Java consumer is no longer in beta and we recommend it for all new development. The old Scala consumers are still supported, but they will be deprecated in the next release and will be removed in a future major release. 
  * The `--new-consumer`/`--new.consumer` switch is no longer required to use tools like MirrorMaker and the Console Consumer with the new consumer; one simply needs to pass a Kafka broker to connect to instead of the ZooKeeper ensemble. In addition, usage of the Console Consumer with the old consumer has been deprecated and it will be removed in a future major release. 
  * Kafka clusters can now be uniquely identified by a cluster id. It will be automatically generated when a broker is upgraded to 0.10.1.0. The cluster id is available via the kafka.server:type=KafkaServer,name=ClusterId metric and it is part of the Metadata response. Serializers, client interceptors and metric reporters can receive the cluster id by implementing the ClusterResourceListener interface. 
  * The BrokerState "RunningAsController" (value 4) has been removed. Due to a bug, a broker would only be in this state briefly before transitioning out of it and hence the impact of the removal should be minimal. The recommended way to detect if a given broker is the controller is via the kafka.controller:type=KafkaController,name=ActiveControllerCount metric. 
  * The new Java Consumer now allows users to search offsets by timestamp on partitions. 
  * The new Java Consumer now supports heartbeating from a background thread. There is a new configuration `max.poll.interval.ms` which controls the maximum time between poll invocations before the consumer will proactively leave the group (5 minutes by default). The value of the configuration `request.timeout.ms` must always be larger than `max.poll.interval.ms` because this is the maximum time that a JoinGroup request can block on the server while the consumer is rebalancing, so we have changed its default value to just above 5 minutes. Finally, the default value of `session.timeout.ms` has been adjusted down to 10 seconds, and the default value of `max.poll.records` has been changed to 500.
  * When using an Authorizer and a user doesn't have **Describe** authorization on a topic, the broker will no longer return TOPIC_AUTHORIZATION_FAILED errors to requests since this leaks topic names. Instead, the UNKNOWN_TOPIC_OR_PARTITION error code will be returned. This may cause unexpected timeouts or delays when using the producer and consumer since Kafka clients will typically retry automatically on unknown topic errors. You should consult the client logs if you suspect this could be happening.
  * Fetch responses have a size limit by default (50 MB for consumers and 10 MB for replication). The existing per partition limits also apply (1 MB for consumers and replication). Note that neither of these limits is an absolute maximum as explained in the next point. 
  * Consumers and replicas can make progress if a message larger than the response/partition size limit is found. More concretely, if the first message in the first non-empty partition of the fetch is larger than either or both limits, the message will still be returned. 
  * Overloaded constructors were added to `kafka.api.FetchRequest` and `kafka.javaapi.FetchRequest` to allow the caller to specify the order of the partitions (since order is significant in v3). The previously existing constructors were deprecated and the partitions are shuffled before the request is sent to avoid starvation issues. 



### New Protocol Versions

  * ListOffsetRequest v1 supports accurate offset search based on timestamps. 
  * MetadataResponse v2 introduces a new field: "cluster_id". 
  * FetchRequest v3 supports limiting the response size (in addition to the existing per partition limit), it returns messages bigger than the limits if required to make progress and the order of partitions in the request is now significant. 
  * JoinGroup v1 introduces a new field: "rebalance_timeout". 



## Upgrading from 0.8.x or 0.9.x to 0.10.0.0

0.10.0.0 has potential breaking changes (please review before upgrading) and possible  performance impact following the upgrade. By following the recommended rolling upgrade plan below, you guarantee no downtime and no performance impact during and following the upgrade.   
Note: Because new protocols are introduced, it is important to upgrade your Kafka clusters before upgrading your clients. 

**Notes to clients with version 0.9.0.0:** Due to a bug introduced in 0.9.0.0, clients that depend on ZooKeeper (old Scala high-level Consumer and MirrorMaker if used with the old consumer) will not work with 0.10.0.x brokers. Therefore, 0.9.0.0 clients should be upgraded to 0.9.0.1 **before** brokers are upgraded to 0.10.0.x. This step is not necessary for 0.8.X or 0.9.0.1 clients. 

**For a rolling upgrade:**

  1. Update server.properties file on all brokers and add the following properties: 
     * inter.broker.protocol.version=CURRENT_KAFKA_VERSION (e.g. 0.8.2 or 0.9.0.0).
     * log.message.format.version=CURRENT_KAFKA_VERSION (See potential performance impact following the upgrade for the details on what this configuration does.) 
  2. Upgrade the brokers. This can be done a broker at a time by simply bringing it down, updating the code, and restarting it. 
  3. Once the entire cluster is upgraded, bump the protocol version by editing inter.broker.protocol.version and setting it to 0.10.0.0. NOTE: You shouldn't touch log.message.format.version yet - this parameter should only change once all consumers have been upgraded to 0.10.0.0 
  4. Restart the brokers one by one for the new protocol version to take effect. 
  5. Once all consumers have been upgraded to 0.10.0, change log.message.format.version to 0.10.0 on each broker and restart them one by one. 



**Note:** If you are willing to accept downtime, you can simply take all the brokers down, update the code and start all of them. They will start with the new protocol by default. 

**Note:** Bumping the protocol version and restarting can be done any time after the brokers were upgraded. It does not have to be immediately after. 

### Potential performance impact following upgrade to 0.10.0.0

The message format in 0.10.0 includes a new timestamp field and uses relative offsets for compressed messages. The on disk message format can be configured through log.message.format.version in the server.properties file. The default on-disk message format is 0.10.0. If a consumer client is on a version before 0.10.0.0, it only understands message formats before 0.10.0. In this case, the broker is able to convert messages from the 0.10.0 format to an earlier format before sending the response to the consumer on an older version. However, the broker can't use zero-copy transfer in this case. Reports from the Kafka community on the performance impact have shown CPU utilization going from 20% before to 100% after an upgrade, which forced an immediate upgrade of all clients to bring performance back to normal. To avoid such message conversion before consumers are upgraded to 0.10.0.0, one can set log.message.format.version to 0.8.2 or 0.9.0 when upgrading the broker to 0.10.0.0. This way, the broker can still use zero-copy transfer to send the data to the old consumers. Once consumers are upgraded, one can change the message format to 0.10.0 on the broker and enjoy the new message format that includes new timestamp and improved compression. The conversion is supported to ensure compatibility and can be useful to support a few apps that have not updated to newer clients yet, but is impractical to support all consumer traffic on even an overprovisioned cluster. Therefore, it is critical to avoid the message conversion as much as possible when brokers have been upgraded but the majority of clients have not. 

For clients that are upgraded to 0.10.0.0, there is no performance impact. 

**Note:** By setting the message format version, one certifies that all existing messages are on or below that message format version. Otherwise consumers before 0.10.0.0 might break. In particular, after the message format is set to 0.10.0, one should not change it back to an earlier format as it may break consumers on versions before 0.10.0.0. 

**Note:** Due to the additional timestamp introduced in each message, producers sending small messages may see a message throughput degradation because of the increased overhead. Likewise, replication now transmits an additional 8 bytes per message. If you're running close to the network capacity of your cluster, it's possible that you'll overwhelm the network cards and see failures and performance issues due to the overload. 

**Note:** If you have enabled compression on producers, you may notice reduced producer throughput and/or lower compression rate on the broker in some cases. When receiving compressed messages, 0.10.0 brokers avoid recompressing the messages, which in general reduces the latency and improves the throughput. In certain cases, however, this may reduce the batching size on the producer, which could lead to worse throughput. If this happens, users can tune linger.ms and batch.size of the producer for better throughput. In addition, the producer buffer used for compressing messages with snappy is smaller than the one used by the broker, which may have a negative impact on the compression ratio for the messages on disk. We intend to make this configurable in a future Kafka release. 

### Potential breaking changes in 0.10.0.0

  * Starting from Kafka 0.10.0.0, the message format version in Kafka is represented as the Kafka version. For example, message format 0.9.0 refers to the highest message version supported by Kafka 0.9.0. 
  * Message format 0.10.0 has been introduced and it is used by default. It includes a timestamp field in the messages and relative offsets are used for compressed messages. 
  * ProduceRequest/Response v2 has been introduced and it is used by default to support message format 0.10.0 
  * FetchRequest/Response v2 has been introduced and it is used by default to support message format 0.10.0 
  * MessageFormatter interface was changed from `def writeTo(key: Array[Byte], value: Array[Byte], output: PrintStream)` to `def writeTo(consumerRecord: ConsumerRecord[Array[Byte], Array[Byte]], output: PrintStream)`
  * MessageReader interface was changed from `def readMessage(): KeyedMessage[Array[Byte], Array[Byte]]` to `def readMessage(): ProducerRecord[Array[Byte], Array[Byte]]`
  * MessageFormatter's package was changed from `kafka.tools` to `kafka.common`
  * MessageReader's package was changed from `kafka.tools` to `kafka.common`
  * MirrorMakerMessageHandler no longer exposes the `handle(record: MessageAndMetadata[Array[Byte], Array[Byte]])` method as it was never called. 
  * The 0.7 KafkaMigrationTool is no longer packaged with Kafka. If you need to migrate from 0.7 to 0.10.0, please migrate to 0.8 first and then follow the documented upgrade process to upgrade from 0.8 to 0.10.0. 
  * The new consumer has standardized its APIs to accept `java.util.Collection` as the sequence type for method parameters. Existing code may have to be updated to work with the 0.10.0 client library. 
  * LZ4-compressed message handling was changed to use an interoperable framing specification (LZ4f v1.5.1). To maintain compatibility with old clients, this change only applies to Message format 0.10.0 and later. Clients that Produce/Fetch LZ4-compressed messages using v0/v1 (Message format 0.9.0) should continue to use the 0.9.0 framing implementation. Clients that use Produce/Fetch protocols v2 or later should use interoperable LZ4f framing. A list of interoperable LZ4 libraries is available at http://www.lz4.org/ 


### Notable changes in 0.10.0.0

  * Starting from Kafka 0.10.0.0, a new client library named **Kafka Streams** is available for stream processing on data stored in Kafka topics. This new client library only works with 0.10.x and upward versioned brokers due to message format changes mentioned above. For more information please read [Streams documentation](/0102/streams).
  * The default value of the configuration parameter `receive.buffer.bytes` is now 64K for the new consumer.
  * The new consumer now exposes the configuration parameter `exclude.internal.topics` to restrict internal topics (such as the consumer offsets topic) from accidentally being included in regular expression subscriptions. By default, it is enabled.
  * The old Scala producer has been deprecated. Users should migrate their code to the Java producer included in the kafka-clients JAR as soon as possible. 
  * The new consumer API has been marked stable. 



## Upgrading from 0.8.0, 0.8.1.X or 0.8.2.X to 0.9.0.0

0.9.0.0 has potential breaking changes (please review before upgrading) and an inter-broker protocol change from previous versions. This means that upgraded brokers and clients may not be compatible with older versions. It is important that you upgrade your Kafka cluster before upgrading your clients. If you are using MirrorMaker downstream clusters should be upgraded first as well. 

**For a rolling upgrade:**

  1. Update server.properties file on all brokers and add the following property: inter.broker.protocol.version=0.8.2.X 
  2. Upgrade the brokers. This can be done a broker at a time by simply bringing it down, updating the code, and restarting it. 
  3. Once the entire cluster is upgraded, bump the protocol version by editing inter.broker.protocol.version and setting it to 0.9.0.0.
  4. Restart the brokers one by one for the new protocol version to take effect 



**Note:** If you are willing to accept downtime, you can simply take all the brokers down, update the code and start all of them. They will start with the new protocol by default. 

**Note:** Bumping the protocol version and restarting can be done any time after the brokers were upgraded. It does not have to be immediately after. 

### Potential breaking changes in 0.9.0.0

  * Java 1.6 is no longer supported. 
  * Scala 2.9 is no longer supported. 
  * Broker IDs above 1000 are now reserved by default to automatically assigned broker IDs. If your cluster has existing broker IDs above that threshold make sure to increase the reserved.broker.max.id broker configuration property accordingly. 
  * Configuration parameter replica.lag.max.messages was removed. Partition leaders will no longer consider the number of lagging messages when deciding which replicas are in sync. 
  * Configuration parameter replica.lag.time.max.ms now refers not just to the time passed since last fetch request from replica, but also to time since the replica last caught up. Replicas that are still fetching messages from leaders but did not catch up to the latest messages in replica.lag.time.max.ms will be considered out of sync. 
  * Compacted topics no longer accept messages without key and an exception is thrown by the producer if this is attempted. In 0.8.x, a message without key would cause the log compaction thread to subsequently complain and quit (and stop compacting all compacted topics). 
  * MirrorMaker no longer supports multiple target clusters. As a result it will only accept a single --consumer.config parameter. To mirror multiple source clusters, you will need at least one MirrorMaker instance per source cluster, each with its own consumer configuration. 
  * Tools packaged under _org.apache.kafka.clients.tools.*_ have been moved to _org.apache.kafka.tools.*_. All included scripts will still function as usual, only custom code directly importing these classes will be affected. 
  * The default Kafka JVM performance options (KAFKA_JVM_PERFORMANCE_OPTS) have been changed in kafka-run-class.sh. 
  * The kafka-topics.sh script (kafka.admin.TopicCommand) now exits with non-zero exit code on failure. 
  * The kafka-topics.sh script (kafka.admin.TopicCommand) will now print a warning when topic names risk metric collisions due to the use of a '.' or '_' in the topic name, and error in the case of an actual collision. 
  * The kafka-console-producer.sh script (kafka.tools.ConsoleProducer) will use the Java producer instead of the old Scala producer be default, and users have to specify 'old-producer' to use the old producer. 
  * By default, all command line tools will print all logging messages to stderr instead of stdout. 



### Notable changes in 0.9.0.1

  * The new broker id generation feature can be disabled by setting broker.id.generation.enable to false. 
  * Configuration parameter log.cleaner.enable is now true by default. This means topics with a cleanup.policy=compact will now be compacted by default, and 128 MB of heap will be allocated to the cleaner process via log.cleaner.dedupe.buffer.size. You may want to review log.cleaner.dedupe.buffer.size and the other log.cleaner configuration values based on your usage of compacted topics. 
  * Default value of configuration parameter fetch.min.bytes for the new consumer is now 1 by default. 



### Deprecations in 0.9.0.0

  * Altering topic configuration from the kafka-topics.sh script (kafka.admin.TopicCommand) has been deprecated. Going forward, please use the kafka-configs.sh script (kafka.admin.ConfigCommand) for this functionality. 
  * The kafka-consumer-offset-checker.sh (kafka.tools.ConsumerOffsetChecker) has been deprecated. Going forward, please use kafka-consumer-groups.sh (kafka.admin.ConsumerGroupCommand) for this functionality. 
  * The kafka.tools.ProducerPerformance class has been deprecated. Going forward, please use org.apache.kafka.tools.ProducerPerformance for this functionality (kafka-producer-perf-test.sh will also be changed to use the new class). 
  * The producer config block.on.buffer.full has been deprecated and will be removed in future release. Currently its default value has been changed to false. The KafkaProducer will no longer throw BufferExhaustedException but instead will use max.block.ms value to block, after which it will throw a TimeoutException. If block.on.buffer.full property is set to true explicitly, it will set the max.block.ms to Long.MAX_VALUE and metadata.fetch.timeout.ms will not be honoured



## Upgrading from 0.8.1 to 0.8.2

0.8.2 is fully compatible with 0.8.1. The upgrade can be done one broker at a time by simply bringing it down, updating the code, and restarting it. 

## Upgrading from 0.8.0 to 0.8.1

0.8.1 is fully compatible with 0.8. The upgrade can be done one broker at a time by simply bringing it down, updating the code, and restarting it. 

## Upgrading from 0.7

Release 0.7 is incompatible with newer releases. Major changes were made to the API, ZooKeeper data structures, and protocol, and configuration in order to add replication (Which was missing in 0.7). The upgrade from 0.7 to later versions requires a [special tool](https://cwiki.apache.org/confluence/display/KAFKA/Migrating+from+0.7+to+0.8) for migration. This migration can be done without downtime. 
