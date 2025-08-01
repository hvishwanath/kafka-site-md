---
title: Monitoring
description: Monitoring
weight: 6
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Monitoring 

Kafka uses Yammer Metrics for metrics reporting in the server. The Java clients use Kafka Metrics, a built-in metrics registry that minimizes transitive dependencies pulled into client applications. Both expose metrics via JMX and can be configured to report stats using pluggable stats reporters to hook up to your monitoring system. 

All Kafka rate metrics have a corresponding cumulative count metric with suffix `-total`. For example, `records-consumed-rate` has a corresponding metric named `records-consumed-total`. 

The easiest way to see the available metrics is to fire up jconsole and point it at a running kafka client or server; this will allow browsing all metrics with JMX. 

## Security Considerations for Remote Monitoring using JMX 

Apache Kafka disables remote JMX by default. You can enable remote monitoring using JMX by setting the environment variable `JMX_PORT` for processes started using the CLI or standard Java system properties to enable remote JMX programmatically. You must enable security when enabling remote JMX in production scenarios to ensure that unauthorized users cannot monitor or control your broker or application as well as the platform on which these are running. Note that authentication is disabled for JMX by default in Kafka and security configs must be overridden for production deployments by setting the environment variable `KAFKA_JMX_OPTS` for processes started using the CLI or by setting appropriate Java system properties. See [Monitoring and Management Using JMX Technology](https://docs.oracle.com/javase/8/docs/technotes/guides/management/agent.html") for details on securing JMX. 

We do graphing and alerting on the following metrics:  Description | Mbean name | Normal value  
---|---|---  
Message in rate | kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec |   
Byte in rate from clients | kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec |   
Byte in rate from other brokers | kafka.server:type=BrokerTopicMetrics,name=ReplicationBytesInPerSec |   
Request rate | kafka.network:type=RequestMetrics,name=RequestsPerSec,request={Produce|FetchConsumer|FetchFollower} |   
Error rate | kafka.network:type=RequestMetrics,name=ErrorsPerSec,request=([-.\w]+),error=([-.\w]+) | Number of errors in responses counted per-request-type, per-error-code. If a response contains multiple errors, all are counted. error=NONE indicates successful responses.  
Request size in bytes | kafka.network:type=RequestMetrics,name=RequestBytes,request=([-.\w]+) | Size of requests for each request type.  
Temporary memory size in bytes | kafka.network:type=RequestMetrics,name=TemporaryMemoryBytes,request={Produce|Fetch} | Temporary memory used for message format conversions and decompression.  
Message conversion time | kafka.network:type=RequestMetrics,name=MessageConversionsTimeMs,request={Produce|Fetch} | Time in milliseconds spent on message format conversions.  
Message conversion rate | kafka.server:type=BrokerTopicMetrics,name={Produce|Fetch}MessageConversionsPerSec,topic=([-.\w]+) | Number of records which required message format conversion.  
Byte out rate to clients | kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec |   
Byte out rate to other brokers | kafka.server:type=BrokerTopicMetrics,name=ReplicationBytesOutPerSec |   
Message validation failure rate due to no key specified for compacted topic | kafka.server:type=BrokerTopicMetrics,name=NoKeyCompactedTopicRecordsPerSec |   
Message validation failure rate due to invalid magic number | kafka.server:type=BrokerTopicMetrics,name=InvalidMagicNumberRecordsPerSec |   
Message validation failure rate due to incorrect crc checksum | kafka.server:type=BrokerTopicMetrics,name=InvalidMessageCrcRecordsPerSec |   
Message validation failure rate due to non-continuous offset or sequence number in batch | kafka.server:type=BrokerTopicMetrics,name=InvalidOffsetOrSequenceRecordsPerSec |   
Log flush rate and time | kafka.log:type=LogFlushStats,name=LogFlushRateAndTimeMs |   
# of under replicated partitions (the number of non-reassigning replicas - the number of ISR > 0) | kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions | 0  
# of under minIsr partitions (|ISR| < min.insync.replicas) | kafka.server:type=ReplicaManager,name=UnderMinIsrPartitionCount | 0  
# of at minIsr partitions (|ISR| = min.insync.replicas) | kafka.server:type=ReplicaManager,name=AtMinIsrPartitionCount | 0  
# of offline log directories | kafka.log:type=LogManager,name=OfflineLogDirectoryCount | 0  
Is controller active on broker | kafka.controller:type=KafkaController,name=ActiveControllerCount | only one broker in the cluster should have 1  
Leader election rate | kafka.controller:type=ControllerStats,name=LeaderElectionRateAndTimeMs | non-zero when there are broker failures  
Unclean leader election rate | kafka.controller:type=ControllerStats,name=UncleanLeaderElectionsPerSec | 0  
Pending topic deletes | kafka.controller:type=KafkaController,name=TopicsToDeleteCount |   
Pending replica deletes | kafka.controller:type=KafkaController,name=ReplicasToDeleteCount |   
Ineligible pending topic deletes | kafka.controller:type=KafkaController,name=TopicsIneligibleToDeleteCount |   
Ineligible pending replica deletes | kafka.controller:type=KafkaController,name=ReplicasIneligibleToDeleteCount |   
Partition counts | kafka.server:type=ReplicaManager,name=PartitionCount | mostly even across brokers  
Leader replica counts | kafka.server:type=ReplicaManager,name=LeaderCount | mostly even across brokers  
ISR shrink rate | kafka.server:type=ReplicaManager,name=IsrShrinksPerSec | If a broker goes down, ISR for some of the partitions will shrink. When that broker is up again, ISR will be expanded once the replicas are fully caught up. Other than that, the expected value for both ISR shrink rate and expansion rate is 0.   
ISR expansion rate | kafka.server:type=ReplicaManager,name=IsrExpandsPerSec | See above  
Max lag in messages btw follower and leader replicas | kafka.server:type=ReplicaFetcherManager,name=MaxLag,clientId=Replica | lag should be proportional to the maximum batch size of a produce request.  
Lag in messages per follower replica | kafka.server:type=FetcherLagMetrics,name=ConsumerLag,clientId=([-.\w]+),topic=([-.\w]+),partition=([0-9]+) | lag should be proportional to the maximum batch size of a produce request.  
Requests waiting in the producer purgatory | kafka.server:type=DelayedOperationPurgatory,name=PurgatorySize,delayedOperation=Produce | non-zero if ack=-1 is used  
Requests waiting in the fetch purgatory | kafka.server:type=DelayedOperationPurgatory,name=PurgatorySize,delayedOperation=Fetch | size depends on fetch.wait.max.ms in the consumer  
Request total time | kafka.network:type=RequestMetrics,name=TotalTimeMs,request={Produce|FetchConsumer|FetchFollower} | broken into queue, local, remote and response send time  
Time the request waits in the request queue | kafka.network:type=RequestMetrics,name=RequestQueueTimeMs,request={Produce|FetchConsumer|FetchFollower} |   
Time the request is processed at the leader | kafka.network:type=RequestMetrics,name=LocalTimeMs,request={Produce|FetchConsumer|FetchFollower} |   
Time the request waits for the follower | kafka.network:type=RequestMetrics,name=RemoteTimeMs,request={Produce|FetchConsumer|FetchFollower} | non-zero for produce requests when ack=-1  
Time the request waits in the response queue | kafka.network:type=RequestMetrics,name=ResponseQueueTimeMs,request={Produce|FetchConsumer|FetchFollower} |   
Time to send the response | kafka.network:type=RequestMetrics,name=ResponseSendTimeMs,request={Produce|FetchConsumer|FetchFollower} |   
Number of messages the consumer lags behind the producer by. Published by the consumer, not broker. | kafka.consumer:type=consumer-fetch-manager-metrics,client-id={client-id} Attribute: records-lag-max |   
The average fraction of time the network processors are idle | kafka.network:type=SocketServer,name=NetworkProcessorAvgIdlePercent | between 0 and 1, ideally > 0.3  
The number of connections disconnected on a processor due to a client not re-authenticating and then using the connection beyond its expiration time for anything other than re-authentication | kafka.server:type=socket-server-metrics,listener=[SASL_PLAINTEXT|SASL_SSL],networkProcessor=<#>,name=expired-connections-killed-count | ideally 0 when re-authentication is enabled, implying there are no longer any older, pre-2.2.0 clients connecting to this (listener, processor) combination  
The total number of connections disconnected, across all processors, due to a client not re-authenticating and then using the connection beyond its expiration time for anything other than re-authentication | kafka.network:type=SocketServer,name=ExpiredConnectionsKilledCount | ideally 0 when re-authentication is enabled, implying there are no longer any older, pre-2.2.0 clients connecting to this broker  
The average fraction of time the request handler threads are idle | kafka.server:type=KafkaRequestHandlerPool,name=RequestHandlerAvgIdlePercent | between 0 and 1, ideally > 0.3  
Bandwidth quota metrics per (user, client-id), user or client-id | kafka.server:type={Produce|Fetch},user=([-.\w]+),client-id=([-.\w]+) | Two attributes. throttle-time indicates the amount of time in ms the client was throttled. Ideally = 0. byte-rate indicates the data produce/consume rate of the client in bytes/sec. For (user, client-id) quotas, both user and client-id are specified. If per-client-id quota is applied to the client, user is not specified. If per-user quota is applied, client-id is not specified.  
Request quota metrics per (user, client-id), user or client-id | kafka.server:type=Request,user=([-.\w]+),client-id=([-.\w]+) | Two attributes. throttle-time indicates the amount of time in ms the client was throttled. Ideally = 0. request-time indicates the percentage of time spent in broker network and I/O threads to process requests from client group. For (user, client-id) quotas, both user and client-id are specified. If per-client-id quota is applied to the client, user is not specified. If per-user quota is applied, client-id is not specified.  
Requests exempt from throttling | kafka.server:type=Request | exempt-throttle-time indicates the percentage of time spent in broker network and I/O threads to process requests that are exempt from throttling.  
ZooKeeper client request latency | kafka.server:type=ZooKeeperClientMetrics,name=ZooKeeperRequestLatencyMs | Latency in millseconds for ZooKeeper requests from broker.  
ZooKeeper connection status | kafka.server:type=SessionExpireListener,name=SessionState | Connection status of broker's ZooKeeper session which may be one of Disconnected|SyncConnected|AuthFailed|ConnectedReadOnly|SaslAuthenticated|Expired.  
Max time to load group metadata | kafka.server:type=group-coordinator-metrics,name=partition-load-time-max | maximum time, in milliseconds, it took to load offsets and group metadata from the consumer offset partitions loaded in the last 30 seconds  
Avg time to load group metadata | kafka.server:type=group-coordinator-metrics,name=partition-load-time-avg | average time, in milliseconds, it took to load offsets and group metadata from the consumer offset partitions loaded in the last 30 seconds  
Max time to load transaction metadata | kafka.server:type=transaction-coordinator-metrics,name=partition-load-time-max | maximum time, in milliseconds, it took to load transaction metadata from the consumer offset partitions loaded in the last 30 seconds  
Avg time to load transaction metadata | kafka.server:type=transaction-coordinator-metrics,name=partition-load-time-avg | average time, in milliseconds, it took to load transaction metadata from the consumer offset partitions loaded in the last 30 seconds  
Number of reassigning partitions | kafka.server:type=ReplicaManager,name=ReassigningPartitions | The number of reassigning leader partitions on a broker.  
Outgoing byte rate of reassignment traffic | kafka.server:type=BrokerTopicMetrics,name=ReassignmentBytesOutPerSec |   
Incoming byte rate of reassignment traffic | kafka.server:type=BrokerTopicMetrics,name=ReassignmentBytesInPerSec |   
  
## Common monitoring metrics for producer/consumer/connect/streams 

The following metrics are available on producer/consumer/connector/streams instances. For specific metrics, please see following sections.  Metric/Attribute name | Description | Mbean name  
---|---|---  
connection-close-rate | Connections closed per second in the window. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
connection-close-total | Total connections closed in the window. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
connection-creation-rate | New connections established per second in the window. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
connection-creation-total | Total new connections established in the window. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
network-io-rate | The average number of network operations (reads or writes) on all connections per second. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
network-io-total | The total number of network operations (reads or writes) on all connections. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
outgoing-byte-rate | The average number of outgoing bytes sent per second to all servers. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
outgoing-byte-total | The total number of outgoing bytes sent to all servers. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
request-rate | The average number of requests sent per second. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
request-total | The total number of requests sent. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
request-size-avg | The average size of all requests in the window. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
request-size-max | The maximum size of any request sent in the window. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
incoming-byte-rate | Bytes/second read off all sockets. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
incoming-byte-total | Total bytes read off all sockets. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
response-rate | Responses received per second. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
response-total | Total responses received. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
select-rate | Number of times the I/O layer checked for new I/O to perform per second. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
select-total | Total number of times the I/O layer checked for new I/O to perform. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
io-wait-time-ns-avg | The average length of time the I/O thread spent waiting for a socket ready for reads or writes in nanoseconds. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
io-wait-ratio | The fraction of time the I/O thread spent waiting. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
io-time-ns-avg | The average length of time for I/O per select call in nanoseconds. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
io-ratio | The fraction of time the I/O thread spent doing I/O. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
connection-count | The current number of active connections. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
successful-authentication-rate | Connections per second that were successfully authenticated using SASL or SSL. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
successful-authentication-total | Total connections that were successfully authenticated using SASL or SSL. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
failed-authentication-rate | Connections per second that failed authentication. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
failed-authentication-total | Total connections that failed authentication. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
successful-reauthentication-rate | Connections per second that were successfully re-authenticated using SASL. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
successful-reauthentication-total | Total connections that were successfully re-authenticated using SASL. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
reauthentication-latency-max | The maximum latency in ms observed due to re-authentication. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
reauthentication-latency-avg | The average latency in ms observed due to re-authentication. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
failed-reauthentication-rate | Connections per second that failed re-authentication. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
failed-reauthentication-total | Total connections that failed re-authentication. | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
successful-authentication-no-reauth-total | Total connections that were successfully authenticated by older, pre-2.2.0 SASL clients that do not support re-authentication. May only be non-zero  | kafka.[producer|consumer|connect]:type=[producer|consumer|connect]-metrics,client-id=([-.\w]+)  
  
## Common Per-broker metrics for producer/consumer/connect/streams 

The following metrics are available on producer/consumer/connector/streams instances. For specific metrics, please see following sections.  Metric/Attribute name | Description | Mbean name  
---|---|---  
outgoing-byte-rate | The average number of outgoing bytes sent per second for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
outgoing-byte-total | The total number of outgoing bytes sent for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
request-rate | The average number of requests sent per second for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
request-total | The total number of requests sent for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
request-size-avg | The average size of all requests in the window for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
request-size-max | The maximum size of any request sent in the window for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
incoming-byte-rate | The average number of bytes received per second for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
incoming-byte-total | The total number of bytes received for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
request-latency-avg | The average request latency in ms for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
request-latency-max | The maximum request latency in ms for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
response-rate | Responses received per second for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
response-total | Total responses received for a node. | kafka.[producer|consumer|connect]:type=[consumer|producer|connect]-node-metrics,client-id=([-.\w]+),node-id=([0-9]+)  
  
## Producer monitoring 

The following metrics are available on producer instances.  Metric/Attribute name | Description | Mbean name  
---|---|---  
waiting-threads | The number of user threads blocked waiting for buffer memory to enqueue their records. | kafka.producer:type=producer-metrics,client-id=([-.\w]+)  
buffer-total-bytes | The maximum amount of buffer memory the client can use (whether or not it is currently used). | kafka.producer:type=producer-metrics,client-id=([-.\w]+)  
buffer-available-bytes | The total amount of buffer memory that is not being used (either unallocated or in the free list). | kafka.producer:type=producer-metrics,client-id=([-.\w]+)  
bufferpool-wait-time | The fraction of time an appender waits for space allocation. | kafka.producer:type=producer-metrics,client-id=([-.\w]+)  
  
### Producer Sender Metrics 

{{< include-html file="/static/25/generated/producer_metrics.html" >}} 

## consumer monitoring 

The following metrics are available on consumer instances.  Metric/Attribute name | Description | Mbean name  
---|---|---  
time-between-poll-avg | The average delay between invocations of poll(). | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+)  
time-between-poll-max | The max delay between invocations of poll(). | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+)  
last-poll-seconds-ago | The number of seconds since the last poll() invocation. | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+)  
poll-idle-ratio-avg | The average fraction of time the consumer's poll() is idle as opposed to waiting for the user code to process records. | kafka.consumer:type=consumer-metrics,client-id=([-.\w]+)  
  
### Consumer Group Metrics 

Metric/Attribute name | Description | Mbean name  
---|---|---  
commit-latency-avg | The average time taken for a commit request | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
commit-latency-max | The max time taken for a commit request | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
commit-rate | The number of commit calls per second | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
commit-total | The total number of commit calls | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
assigned-partitions | The number of partitions currently assigned to this consumer | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
heartbeat-response-time-max | The max time taken to receive a response to a heartbeat request | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
heartbeat-rate | The average number of heartbeats per second | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
heartbeat-total | The total number of heartbeats | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
join-time-avg | The average time taken for a group rejoin | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
join-time-max | The max time taken for a group rejoin | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
join-rate | The number of group joins per second | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
join-total | The total number of group joins | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
sync-time-avg | The average time taken for a group sync | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
sync-time-max | The max time taken for a group sync | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
sync-rate | The number of group syncs per second | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
sync-total | The total number of group syncs | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
rebalance-latency-avg | The average time taken for a group rebalance | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
rebalance-latency-max | The max time taken for a group rebalance | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
rebalance-latency-total | The total time taken for group rebalances so far | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
rebalance-total | The total number of group rebalances participated | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
rebalance-rate-per-hour | The number of group rebalance participated per hour | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
failed-rebalance-total | The total number of failed group rebalances | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
failed-rebalance-rate-per-hour | The number of failed group rebalance event per hour | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
last-rebalance-seconds-ago | The number of seconds since the last rebalance event | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
last-heartbeat-seconds-ago | The number of seconds since the last controller heartbeat | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
partitions-revoked-latency-avg | The average time taken by the on-partitions-revoked rebalance listener callback | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
partitions-revoked-latency-max | The max time taken by the on-partitions-revoked rebalance listener callback | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
partitions-assigned-latency-avg | The average time taken by the on-partitions-assigned rebalance listener callback | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
partitions-assigned-latency-max | The max time taken by the on-partitions-assigned rebalance listener callback | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
partitions-lost-latency-avg | The average time taken by the on-partitions-lost rebalance listener callback | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
partitions-lost-latency-max | The max time taken by the on-partitions-lost rebalance listener callback | kafka.consumer:type=consumer-coordinator-metrics,client-id=([-.\w]+)  
  
### Consumer Fetch Metrics 

{{< include-html file="/static/25/generated/consumer_metrics.html" >}} 

## Connect Monitoring 

A Connect worker process contains all the producer and consumer metrics as well as metrics specific to Connect. The worker process itself has a number of metrics, while each connector and task have additional metrics. {{< include-html file="/static/25/generated/connect_metrics.html" >}} 

## Streams Monitoring 

A Kafka Streams instance contains all the producer and consumer metrics as well as additional metrics specific to Streams. By default Kafka Streams has metrics with two recording levels: `debug` and `info`. 

Note that the metrics have a 4-layer hierarchy. At the top level there are client-level metrics for each started Kafka Streams client. Each client has stream threads, with their own metrics. Each stream thread has tasks, with their own metrics. Each task has a number of processor nodes, with their own metrics. Each task also has a number of state stores and record caches, all with their own metrics. 

Use the following configuration option to specify which metrics you want collected: 
    
    
    metrics.recording.level="info"

### Client Metrics 

All of the following metrics have a recording level of `info`:  Metric/Attribute name | Description | Mbean name  
---|---|---  
version | The version of the Kafka Streams client. | kafka.streams:type=stream-metrics,client-id=([-.\w]+)  
commit-id | The version control commit ID of the Kafka Streams client. | kafka.streams:type=stream-metrics,client-id=([-.\w]+)  
application-id | The application ID of the Kafka Streams client. | kafka.streams:type=stream-metrics,client-id=([-.\w]+)  
topology-description | The description of the topology executed in the Kafka Streams client. | kafka.streams:type=stream-metrics,client-id=([-.\w]+)  
state | The state of the Kafka Streams client. | kafka.streams:type=stream-metrics,client-id=([-.\w]+)  
  
### Thread Metrics 

All of the following metrics have a recording level of `info`:  Metric/Attribute name | Description | Mbean name  
---|---|---  
commit-latency-avg | The average execution time in ms, for committing, across all running tasks of this thread. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
commit-latency-max | The maximum execution time in ms, for committing, across all running tasks of this thread. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
poll-latency-avg | The average execution time in ms, for consumer polling. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
poll-latency-max | The maximum execution time in ms, for consumer polling. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
process-latency-avg | The average execution time in ms, for processing. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
process-latency-max | The maximum execution time in ms, for processing. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
punctuate-latency-avg | The average execution time in ms, for punctuating. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
punctuate-latency-max | The maximum execution time in ms, for punctuating. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
commit-rate | The average number of commits per second. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
commit-total | The total number of commit calls. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
poll-rate | The average number of consumer poll calls per second. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
poll-total | The total number of consumer poll calls. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
process-rate | The average number of processed records per second. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
process-total | The total number of processed records. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
punctuate-rate | The average number of punctuate calls per second. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
punctuate-total | The total number of punctuate calls. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
task-created-rate | The average number of tasks created per second. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
task-created-total | The total number of tasks created. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
task-closed-rate | The average number of tasks closed per second. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
task-closed-total | The total number of tasks closed. | kafka.streams:type=stream-thread-metrics,thread-id=([-.\w]+)  
  
### Task Metrics 

All of the following metrics have a recording level of `debug`, except for metrics dropped-records-rate and dropped-records-total which have a recording level of `info`:  Metric/Attribute name | Description | Mbean name  
---|---|---  
process-latency-avg | The average execution time in ns, for processing. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
process-latency-max | The maximum execution time in ns, for processing. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
process-rate | The average number of processed records per second across all source processor nodes of this task. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
process-total | The total number of processed records across all source processor nodes of this task. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
commit-latency-avg | The average execution time in ns, for committing. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
commit-latency-max | The maximum execution time in ns, for committing. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
commit-rate | The average number of commit calls per second. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
commit-total | The total number of commit calls.  | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
record-lateness-avg | The average observed lateness of records (stream time - record timestamp). | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
record-lateness-max | The max observed lateness of records (stream time - record timestamp). | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
enforced-processing-rate | The average number of enforced processings per second. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
enforced-processing-total | The total number enforced processings. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
dropped-records-rate | The average number of records dropped within this task. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
dropped-records-total | The total number of records dropped within this task. | kafka.streams:type=stream-task-metrics,thread-id=([-.\w]+),task-id=([-.\w]+)  
  
### Processor Node Metrics 

The following metrics are only available on certain types of nodes, i.e., process-rate and process-total are only available for source processor nodes and suppression-emit-rate and suppression-emit-total are only available for suppression operation nodes. All of the metrics have a recording level of `debug`:  Metric/Attribute name | Description | Mbean name  
---|---|---  
process-rate | The average number of records processed by a source processor node per second. | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+)  
process-total | The total number of records processed by a source processor node per second. | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+)  
suppression-emit-rate | The rate at which records that have been emitted downstream from suppression operation nodes. | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+)  
suppression-emit-total | The total number of records that have been emitted downstream from suppression operation nodes. | kafka.streams:type=stream-processor-node-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),processor-node-id=([-.\w]+)  
  
### State Store Metrics 

All of the following metrics have a recording level of `debug`. Note that the `store-scope` value is specified in `StoreSupplier#metricsScope()` for user's customized state stores; for built-in state stores, currently we have: 

  * `in-memory-state`
  * `in-memory-lru-state`
  * `in-memory-window-state`
  * `in-memory-suppression` (for suppression buffers)
  * `rocksdb-state` (for RocksDB backed key-value store)
  * `rocksdb-window-state` (for RocksDB backed window store)
  * `rocksdb-session-state` (for RocksDB backed session store)

Metrics suppression-buffer-size-avg, suppression-buffer-size-max, suppression-buffer-count-avg, and suppression-buffer-count-max are only available for suppression buffers. All other metrics are not available for suppression buffers.  Metric/Attribute name | Description | Mbean name  
---|---|---  
put-latency-avg | The average put execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-latency-max | The maximum put execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-if-absent-latency-avg | The average put-if-absent execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-if-absent-latency-max | The maximum put-if-absent execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
get-latency-avg | The average get execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
get-latency-max | The maximum get execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
delete-latency-avg | The average delete execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
delete-latency-max | The maximum delete execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-all-latency-avg | The average put-all execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-all-latency-max | The maximum put-all execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
all-latency-avg | The average all operation execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
all-latency-max | The maximum all operation execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
range-latency-avg | The average range execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
range-latency-max | The maximum range execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
flush-latency-avg | The average flush execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
flush-latency-max | The maximum flush execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
restore-latency-avg | The average restore execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
restore-latency-max | The maximum restore execution time in ns.  | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-rate | The average put rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-if-absent-rate | The average put-if-absent rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
get-rate | The average get rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
delete-rate | The average delete rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
put-all-rate | The average put-all rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
all-rate | The average all operation rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
range-rate | The average range rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
flush-rate | The average flush rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
restore-rate | The average restore rate for this store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
suppression-buffer-size-avg | The average total size, in bytes, of the buffered data over the sampling window. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+)  
suppression-buffer-size-max | The maximum total size, in bytes, of the buffered data over the sampling window. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+)  
suppression-buffer-count-avg | The average number of records buffered over the sampling window. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+)  
suppression-buffer-count-max | The maximum number of records buffered over the sampling window. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),in-memory-suppression-id=([-.\w]+)  
  
### RocksDB Metrics 

All of the following metrics have a recording level of `debug`. The metrics are collected every minute from the RocksDB state stores. If a state store consists of multiple RocksDB instances as it is the case for aggregations over time and session windows, each metric reports an aggregation over the RocksDB instances of the state store. Note that the `store-scope` for built-in RocksDB state stores are currently the following: 

  * `rocksdb-state` (for RocksDB backed key-value store)
  * `rocksdb-window-state` (for RocksDB backed window store)
  * `rocksdb-session-state` (for RocksDB backed session store)

Metric/Attribute name | Description | Mbean name  
---|---|---  
bytes-written-rate | The average number of bytes written per second to the RocksDB state store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
bytes-written-total | The total number of bytes written to the RocksDB state store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
bytes-read-rate | The average number of bytes read per second from the RocksDB state store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
bytes-read-total | The total number of bytes read from the RocksDB state store. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
memtable-bytes-flushed-rate | The average number of bytes flushed per second from the memtable to disk. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
memtable-bytes-flushed-total | The total number of bytes flushed from the memtable to disk. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
memtable-hit-ratio | The ratio of memtable hits relative to all lookups to the memtable. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
block-cache-data-hit-ratio | The ratio of block cache hits for data blocks relative to all lookups for data blocks to the block cache. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
block-cache-index-hit-ratio | The ratio of block cache hits for index blocks relative to all lookups for index blocks to the block cache. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
block-cache-filter-hit-ratio | The ratio of block cache hits for filter blocks relative to all lookups for filter blocks to the block cache. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
write-stall-duration-avg | The average duration of write stalls in ms. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
write-stall-duration-total | The total duration of write stalls in ms. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
bytes-read-compaction-rate | The average number of bytes read per second during compaction. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
bytes-written-compaction-rate | The average number of bytes written per second during compaction. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
number-open-files | The number of current open files. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
number-file-errors-total | The total number of file errors occurred. | kafka.streams:type=stream-state-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),[store-scope]-id=([-.\w]+)  
  
### Record Cache Metrics 

All of the following metrics have a recording level of `debug`:  Metric/Attribute name | Description | Mbean name  
---|---|---  
hit-ratio-avg | The average cache hit ratio defined as the ratio of cache read hits over the total cache read requests. | kafka.streams:type=stream-record-cache-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),record-cache-id=([-.\w]+)  
hit-ratio-min | The mininum cache hit ratio. | kafka.streams:type=stream-record-cache-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),record-cache-id=([-.\w]+)  
hit-ratio-max | The maximum cache hit ratio. | kafka.streams:type=stream-record-cache-metrics,thread-id=([-.\w]+),task-id=([-.\w]+),record-cache-id=([-.\w]+)  
  
## Others 

We recommend monitoring GC time and other stats and various server stats such as CPU utilization, I/O service time, etc. On the client side, we recommend monitoring the message/byte rate (global and per topic), request rate/size/time, and on the consumer side, max lag in messages among all partitions and min fetch request rate. For a consumer to keep up, max lag needs to be less than a threshold and min fetch rate needs to be larger than 0. 
