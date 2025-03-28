---
title: Upgrading
description: 
weight: 5
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

## Upgrading to 4.0.0

### Upgrading Clients to 4.0.0

**For a rolling upgrade:**

  1. Upgrade the clients one at a time: shut down the client, update the code, and restart it.
  2. Clients (including Streams and Connect) must be on version 2.1 or higher before upgrading to 4.0. Many deprecated APIs were removed in Kafka 4.0. For more information about the compatibility, please refer to the [compatibility matrix](/40/compatibility.html) or [KIP-1124](https://cwiki.apache.org/confluence/x/y4kgF).



### Upgrading Servers to 4.0.0 from any version 3.3.x through 3.9.x

Note: Apache Kafka 4.0 only supports KRaft mode - ZooKeeper mode has been removed. As such, **broker upgrades to 4.0.0 (and higher) require KRaft mode and the software and metadata versions must be at least 3.3.x** (the first version when KRaft mode was deemed production ready). For clusters in KRaft mode with versions older than 3.3.x, we recommend upgrading to 3.9.x before upgrading to 4.0.x. Clusters in ZooKeeper mode have to be [migrated to KRaft mode](/40/documentation.html#kraft_zk_migration) before they can be upgraded to 4.0.x. 

**For a rolling upgrade:**

  1. Upgrade the brokers one at a time: shut down the broker, update the code, and restart it. Once you have done so, the brokers will be running the latest version and you can verify that the cluster's behavior and performance meets expectations. 
  2. Once the cluster's behavior and performance has been verified, finalize the upgrade by running ` bin/kafka-features.sh --bootstrap-server localhost:9092 upgrade --release-version 4.0 `
  3. Note that cluster metadata downgrade is not supported in this version since it has metadata changes. Every [MetadataVersion](https://github.com/apache/kafka/blob/trunk/server-common/src/main/java/org/apache/kafka/server/common/MetadataVersion.java) has a boolean parameter that indicates if there are metadata changes (i.e. `IBP_4_0_IV1(23, "4.0", "IV1", true)` means this version has metadata changes). Given your current and target versions, a downgrade is only possible if there are no metadata changes in the versions between.



### Notable changes in 4.0.0

  * Old protocol API versions have been removed. Users should ensure brokers are version 2.1 or higher before upgrading Java clients (including Connect and Kafka Streams which use the clients internally) to 4.0. Similarly, users should ensure their Java clients (including Connect and Kafka Streams) version is 2.1 or higher before upgrading brokers to 4.0. Finally, care also needs to be taken when it comes to kafka clients that are not part of Apache Kafka, please see [KIP-896](https://cwiki.apache.org/confluence/display/KAFKA/KIP-896%3A+Remove+old+client+protocol+API+versions+in+Kafka+4.0) for the details. 
  * Apache Kafka 4.0 only supports KRaft mode - ZooKeeper mode has been removed. About version upgrade, check [Upgrading to 4.0.0 from any version 3.3.x through 3.9.x](/40/documentation.html#upgrade_4_0_0) for more info. 
  * Apache Kafka 4.0 ships with a brand-new group coordinator implementation (See [here](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=217387038#KIP848:TheNextGenerationoftheConsumerRebalanceProtocol-GroupCoordinator)). Functionally speaking, it implements all the same APIs. There are reasonable defaults, but the behavior of the new group coordinator can be tuned by setting the configurations with prefix `group.coordinator`. 
  * The Next Generation of the Consumer Rebalance Protocol ([KIP-848](https://cwiki.apache.org/confluence/display/KAFKA/KIP-848%3A+The+Next+Generation+of+the+Consumer+Rebalance+Protocol)) is now Generally Available (GA) in Apache Kafka 4.0. The protocol is automatically enabled on the server when the upgrade to 4.0 is finalized. Note that once the new protocol is used by consumer groups, the cluster can only downgrade to version 3.4.1 or newer. Check [here](/40/documentation.html#consumer_rebalance_protocol) for details. 
  * Transactions Server Side Defense ([KIP-890](https://cwiki.apache.org/confluence/display/KAFKA/KIP-890%3A+Transactions+Server-Side+Defense)) brings a strengthened transactional protocol to Apache Kafka 4.0. The new and improved transactional protocol is enabled when the upgrade to 4.0 is finalized. When using 4.0 producer clients, the producer epoch is bumped on every transaction to ensure every transaction includes the intended messages and duplicates are not written as part of the next transaction. Downgrading the protocol is safe. For more information check [here](/40/documentation.html#transaction_protocol)
  * Eligible Leader Replicas ([KIP-966 Part 1](https://cwiki.apache.org/confluence/display/KAFKA/KIP-966%3A+Eligible+Leader+Replicas)) enhances the replication protocol for the Apache Kafka 4.0. Now the KRaft controller keeps track of the data partition replicas that are not included in ISR but are safe to be elected as leader without data loss. Such replicas are stored in the partition metadata as the `Eligible Leader Replicas`(ELR). For more information check [here](/40/documentation.html#eligible_leader_replicas)
  * Since Apache Kafka 4.0.0, we have added a system property ("org.apache.kafka.sasl.oauthbearer.allowed.urls") to set the allowed URLs as SASL OAUTHBEARER token or jwks endpoints. By default, the value is an empty list. Users should explicitly set the allowed list if necessary. 
  * A number of deprecated classes, methods, configurations and tools have been removed. 
    * **Common**
      * The `metrics.jmx.blacklist` and `metrics.jmx.whitelist` configurations were removed from the `org.apache.kafka.common.metrics.JmxReporter` Please use `metrics.jmx.exclude` and `metrics.jmx.include` respectively instead. 
      * The `auto.include.jmx.reporter` configuration was removed. The `metric.reporters` configuration is now set to `org.apache.kafka.common.metrics.JmxReporter` by default. 
      * The constructor `org.apache.kafka.common.metrics.JmxReporter` with string argument was removed. See [KIP-606](https://cwiki.apache.org/confluence/display/KAFKA/KIP-606%3A+Add+Metadata+Context+to+MetricsReporter) for details. 
      * The `bufferpool-wait-time-total`, `io-waittime-total`, and `iotime-total` metrics were removed. Please use `bufferpool-wait-time-ns-total`, `io-wait-time-ns-total`, and `io-time-ns-total` metrics as replacements, respectively. 
      * The `kafka.common.requests.DescribeLogDirsResponse.LogDirInfo` class was removed. Please use the `kafka.clients.admin.DescribeLogDirsResult.descriptions()` class and `kafka.clients.admin.DescribeLogDirsResult.allDescriptions()`instead. 
      * The `kafka.common.requests.DescribeLogDirsResponse.ReplicaInfo` class was removed. Please use the `kafka.clients.admin.DescribeLogDirsResult.descriptions()` class and `kafka.clients.admin.DescribeLogDirsResult.allDescriptions()`instead. 
      * The `org.apache.kafka.common.security.oauthbearer.secured.OAuthBearerLoginCallbackHandler` class was removed. Please use the `org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginCallbackHandler` class instead. 
      * The `org.apache.kafka.common.security.oauthbearer.secured.OAuthBearerValidatorCallbackHandler` class was removed. Please use the `org.apache.kafka.common.security.oauthbearer.OAuthBearerValidatorCallbackHandler` class instead. 
      * The `org.apache.kafka.common.errors.NotLeaderForPartitionException` class was removed. The `org.apache.kafka.common.errors.NotLeaderOrFollowerException` is returned if a request could not be processed because the broker is not the leader or follower for a topic partition. 
      * The `org.apache.kafka.clients.producer.internals.DefaultPartitioner` and `org.apache.kafka.clients.producer.UniformStickyPartitioner` class was removed. 
      * The `log.message.format.version` and `message.format.version` configs were removed. 
      * The function `onNewBatch` in `org.apache.kafka.clients.producer.Partitioner` class was removed. 
      * The default properties files for KRaft mode are no longer stored in the separate `config/kraft` directory since Zookeeper has been removed. These files have been consolidated with other configuration files. Now all configuration files are in `config` directory. 
      * The valid format for `--bootstrap-server` only supports comma-separated value, such as `host1:port1,host2:port2,...`. Providing other formats, like space-separated bootstrap servers (e.g., `host1:port1 host2:port2 host3:port3`), will result in an exception, even though this was allowed in Apache Kafka versions prior to 4.0. 
    * **Broker**
      * The `delegation.token.master.key` configuration was removed. Please use `delegation.token.secret.key` instead. 
      * The `offsets.commit.required.acks` configuration was removed. See [KIP-1041](https://cwiki.apache.org/confluence/x/9YobEg) for details. 
      * The `log.message.timestamp.difference.max.ms` configuration was removed. Please use `log.message.timestamp.before.max.ms` and `log.message.timestamp.after.max.ms` instead. See [KIP-937](https://cwiki.apache.org/confluence/display/KAFKA/KIP-937%3A+Improve+Message+Timestamp+Validation) for details. 
      * The `remote.log.manager.copier.thread.pool.size` configuration default value was changed to 10 from -1. Values of -1 are no longer valid. A minimum of 1 or higher is valid. See [KIP-1030](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1030%3A+Change+constraints+and+default+values+for+various+configurations)
      * The `remote.log.manager.expiration.thread.pool.size` configuration default value was changed to 10 from -1. Values of -1 are no longer valid. A minimum of 1 or higher is valid. See [KIP-1030](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1030%3A+Change+constraints+and+default+values+for+various+configurations)
      * The `remote.log.manager.thread.pool.size` configuration default value was changed to 2 from 10. See [KIP-1030](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1030%3A+Change+constraints+and+default+values+for+various+configurations)
      * The minimum `segment.bytes/log.segment.bytes` has changed from 14 bytes to 1MB. See [KIP-1030](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1030%3A+Change+constraints+and+default+values+for+various+configurations)
    * **MirrorMaker**
      * The original MirrorMaker (MM1) and related classes were removed. Please use the Connect-based MirrorMaker (MM2), as described in the [Geo-Replication section.](/40/#georeplication). 
      * The `use.incremental.alter.configs` configuration was removed from `MirrorSourceConnector`. The modified behavior is identical to the previous `required` configuration, therefore users should ensure that brokers in the target cluster are at least running 2.3.0. 
      * The `add.source.alias.to.metrics` configuration was removed from `MirrorSourceConnector`. The source cluster alias is now always added to the metrics. 
      * The `config.properties.blacklist` was removed from the `org.apache.kafka.connect.mirror.MirrorSourceConfig` Please use `config.properties.exclude` instead. 
      * The `topics.blacklist` was removed from the `org.apache.kafka.connect.mirror.MirrorSourceConfig` Please use `topics.exclude` instead. 
      * The `groups.blacklist` was removed from the `org.apache.kafka.connect.mirror.MirrorSourceConfig` Please use `groups.exclude` instead. 
    * **Tools**
      * The `kafka.common.MessageReader` class was removed. Please use the [`org.apache.kafka.tools.api.RecordReader`](/40/javadoc/org/apache/kafka/tools/api/RecordReader.html) interface to build custom readers for the `kafka-console-producer` tool. 
      * The `kafka.tools.DefaultMessageFormatter` class was removed. Please use the `org.apache.kafka.tools.consumer.DefaultMessageFormatter` class instead. 
      * The `kafka.tools.LoggingMessageFormatter` class was removed. Please use the `org.apache.kafka.tools.consumer.LoggingMessageFormatter` class instead. 
      * The `kafka.tools.NoOpMessageFormatter` class was removed. Please use the `org.apache.kafka.tools.consumer.NoOpMessageFormatter` class instead. 
      * The `--whitelist` option was removed from the `kafka-console-consumer` command line tool. Please use `--include` instead. 
      * Redirections from the old tools packages have been removed: `kafka.admin.FeatureCommand`, `kafka.tools.ClusterTool`, `kafka.tools.EndToEndLatency`, `kafka.tools.StateChangeLogMerger`, `kafka.tools.StreamsResetter`, `kafka.tools.JmxTool`. 
      * The `--authorizer`, `--authorizer-properties`, and `--zk-tls-config-file` options were removed from the `kafka-acls` command line tool. Please use `--bootstrap-server` or `--bootstrap-controller` instead. 
      * The `kafka.serializer.Decoder` trait was removed, please use the [`org.apache.kafka.tools.api.Decoder`](/40/javadoc/org/apache/kafka/tools/api/Decoder.html) interface to build custom decoders for the `kafka-dump-log` tool. 
      * The `kafka.coordinator.group.OffsetsMessageFormatter` class was removed. Please use the `org.apache.kafka.tools.consumer.OffsetsMessageFormatter` class instead. 
      * The `kafka.coordinator.group.GroupMetadataMessageFormatter` class was removed. Please use the `org.apache.kafka.tools.consumer.GroupMetadataMessageFormatter` class instead. 
      * The `kafka.coordinator.transaction.TransactionLogMessageFormatter` class was removed. Please use the `org.apache.kafka.tools.consumer.TransactionLogMessageFormatter` class instead. 
      * The `--topic-white-list` option was removed from the `kafka-replica-verification` command line tool. Please use `--topics-include` instead. 
      * The `--broker-list` option was removed from the `kafka-verifiable-consumer` command line tool. Please use `--bootstrap-server` instead. 
      * kafka-configs.sh now uses incrementalAlterConfigs API to alter broker configurations instead of the deprecated alterConfigs API, and it will fall directly if the broker doesn't support incrementalAlterConfigs API, which means the broker version is prior to 2.3.x. See [KIP-1011](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1011%3A+Use+incrementalAlterConfigs+when+updating+broker+configs+by+kafka-configs.sh) for more details. 
      * The `kafka.admin.ZkSecurityMigrator` tool was removed. 
    * **Connect**
      * The `whitelist` and `blacklist` configurations were removed from the `org.apache.kafka.connect.transforms.ReplaceField` transformation. Please use `include` and `exclude` respectively instead. 
      * The `onPartitionsRevoked(Collection<TopicPartition>)` and `onPartitionsAssigned(Collection<TopicPartition>)` methods were removed from `SinkTask`. 
      * The `commitRecord(SourceRecord)` method was removed from `SourceTask`. 
    * **Consumer**
      * The `poll(long)` method was removed from the consumer. Please use `poll(Duration)` instead. Note that there is a difference in behavior between the two methods. The `poll(Duration)` method does not block beyond the timeout awaiting partition assignment, whereas the earlier `poll(long)` method used to wait beyond the timeout. 
      * The `committed(TopicPartition)` and `committed(TopicPartition, Duration)` methods were removed from the consumer. Please use `committed(Set&ltTopicPartition;>)` and `committed(Set&ltTopicPartition;>, Duration)` instead. 
      * The `setException(KafkaException)` method was removed from the `org.apache.kafka.clients.consumer.MockConsumer`. Please use `setPollException(KafkaException)` instead. 
    * **Producer**
      * The `enable.idempotence` configuration will no longer automatically fall back when the `max.in.flight.requests.per.connection` value exceeds 5. 
      * The deprecated `sendOffsetsToTransaction(Map<TopicPartition, OffsetAndMetadata>, String)` method has been removed from the Producer API. 
      * The default `linger.ms` changed from 0 to 5 in Apache Kafka 4.0 as the efficiency gains from larger batches typically result in similar or lower producer latency despite the increased linger. 
    * **Admin client**
      * The `alterConfigs` method was removed from the `org.apache.kafka.clients.admin.Admin`. Please use `incrementalAlterConfigs` instead. 
      * The `org.apache.kafka.common.ConsumerGroupState` enumeration and related methods have been deprecated. Please use `GroupState` instead which applies to all types of group. 
      * The `Admin.describeConsumerGroups` method used to return a `ConsumerGroupDescription` in state `DEAD` if the group ID was not found. In Apache Kafka 4.0, the `GroupIdNotFoundException` is thrown instead as part of the support for new types of group. 
      * The `org.apache.kafka.clients.admin.DeleteTopicsResult.values()` method was removed. Please use `org.apache.kafka.clients.admin.DeleteTopicsResult.topicNameValues()` instead. 
      * The `org.apache.kafka.clients.admin.TopicListing.TopicListing(String, boolean)` method was removed. Please use `org.apache.kafka.clients.admin.TopicListing.TopicListing(String, Uuid, boolean)` instead. 
      * The `org.apache.kafka.clients.admin.ListConsumerGroupOffsetsOptions.topicPartitions(List<TopicPartition>)` method was removed. Please use `org.apache.kafka.clients.admin.Admin.listConsumerGroupOffsets(Map<String, ListConsumerGroupOffsetsSpec>, ListConsumerGroupOffsetsOptions)` instead. 
      * The deprecated `dryRun` methods were removed from the `org.apache.kafka.clients.admin.UpdateFeaturesOptions`. Please use `validateOnly` instead. 
      * The constructor `org.apache.kafka.clients.admin.FeatureUpdate` with short and boolean arguments was removed. Please use the constructor that accepts short and the specified UpgradeType enum instead. 
      * The `allowDowngrade` method was removed from the `org.apache.kafka.clients.admin.FeatureUpdate`. 
      * The `org.apache.kafka.clients.admin.DescribeTopicsResult.DescribeTopicsResult(Map<String, KafkaFuture<TopicDescription>>)` method was removed. Please use `org.apache.kafka.clients.admin.DescribeTopicsResult.DescribeTopicsResult(Map<Uuid, KafkaFuture<TopicDescription>>, Map<String, KafkaFuture<TopicDescription>>)` instead. 
      * The `values()` method was removed from the `org.apache.kafka.clients.admin.DescribeTopicsResult`. Please use `topicNameValues()` instead. 
      * The `all()` method was removed from the `org.apache.kafka.clients.admin.DescribeTopicsResult`. Please use `allTopicNames()` instead. 
    * **Kafka Streams**
      * All public API, deprecated in Apache Kafka 3.6 or an earlier release, have been removed, with the exception of `JoinWindows.of()` and `JoinWindows#grace()`. See [KAFKA-17531](https://issues.apache.org/jira/browse/KAFKA-17531) for details. 
      * The most important changes are highlighted in the [Kafka Streams upgrade guide](/40/streams/upgrade-guide.html#streams_api_changes_400). 
      * For a full list of changes, see [KAFKA-12822](https://issues.apache.org/jira/browse/KAFKA-12822). 
  * Other changes: 
    * The minimum Java version required by clients and Kafka Streams applications has been increased from Java 8 to Java 11 while brokers, connect and tools now require Java 17. See [KIP-750](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=181308223) and [KIP-1013](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=284789510) for more details. 
    * Java 23 support has been added in Apache Kafka 4.0 
    * Scala 2.12 support has been removed in Apache Kafka 4.0 See [KIP-751](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=181308218) for more details 
    * Logging framework has been migrated from Log4j to Log4j2. Users can use the log4j-transform-cli tool to automatically convert their existing Log4j configuration files to Log4j2 format. See [log4j-transform-cli](https://logging.staged.apache.org/log4j/transform/cli.html#log4j-transform-cli) for more details. Log4j2 provides limited compatibility for Log4j configurations. See [Use Log4j 1 to Log4j 2 bridge](https://logging.apache.org/log4j/2.x/migrate-from-log4j1.html#ConfigurationCompatibility) for more information, 
    * KafkaLog4jAppender has been removed, users should migrate to the log4j2 appender See [KafkaAppender](https://logging.apache.org/log4j/2.x/manual/appenders.html#KafkaAppender) for more details 
    * The `--delete-config` option in the `kafka-topics` command line tool has been deprecated. 
    * For implementors of RemoteLogMetadataManager (RLMM), a new API `nextSegmentWithTxnIndex` is introduced in RLMM to allow the implementation to return the next segment metadata with a transaction index. This API is used when the consumers are enabled with isolation level as READ_COMMITTED. See [KIP-1058](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1058:+Txn+consumer+exerts+pressure+on+remote+storage+when+collecting+aborted+transactions) for more details. 
    * The criteria for identifying internal topics in ReplicationPolicy and DefaultReplicationPolicy have been updated to enable the replication of topics that appear to be internal but aren't truly internal to Kafka and Mirror Maker 2. See [KIP-1074](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1074%3A+Allow+the+replication+of+user+internal+topics) for more details. 
    * KIP-714 is now enabled for Kafka Streams via [KIP-1076](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1076%3A++Metrics+for+client+applications+KIP-714+extension). This allows to not only collect the metric of the internally used clients of a Kafka Streams appliction via a broker-side plugin, but also to collect the [metrics](/40/#kafka_streams_monitoring) of the Kafka Streams runtime itself. 
    * The default value of 'num.recovery.threads.per.data.dir' has been changed from 1 to 2. The impact of this is faster recovery post unclean shutdown at the expense of extra IO cycles. See [KIP-1030](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1030%3A+Change+constraints+and+default+values+for+various+configurations)
    * The default value of 'message.timestamp.after.max.ms' has been changed from Long.Max to 1 hour. The impact of this messages with a timestamp of more than 1 hour in the future will be rejected when message.timestamp.type=CreateTime is set. See [KIP-1030](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1030%3A+Change+constraints+and+default+values+for+various+configurations)
    * Introduced in KIP-890, the `TransactionAbortableException` enhances error handling within transactional operations by clearly indicating scenarios where transactions should be aborted due to errors. It is important for applications to properly manage both `TimeoutException` and `TransactionAbortableException` when working with transaction producers.
      * **TimeoutException:** This exception indicates that a transactional operation has timed out. Given the risk of message duplication that can arise from retrying operations after a timeout (potentially violating exactly-once semantics), applications should treat timeouts as reasons to abort the ongoing transaction.
      * **TransactionAbortableException:** Specifically introduced to signal errors that should lead to transaction abortion, ensuring this exception is properly handled is critical for maintaining the integrity of transactional processing.
      * To ensure seamless operation and compatibility with future Kafka versions, developers are encouraged to update their error-handling logic to treat both exceptions as triggers for aborting transactions. This approach is pivotal for preserving exactly-once semantics.
      * See [KIP-890](https://cwiki.apache.org/confluence/display/KAFKA/KIP-890%3A+Transactions+Server-Side+Defense) and [KIP-1050](https://cwiki.apache.org/confluence/display/KAFKA/KIP-1050%3A+Consistent+error+handling+for+Transactions) for more details 



## Upgrading to 3.9.0 and older versions

See [Upgrading From Previous Versions](/39/#upgrade) in the 3.9 documentation.
