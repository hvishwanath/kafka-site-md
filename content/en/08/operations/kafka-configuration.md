---
title: Kafka Configuration
description: Kafka Configuration
weight: 2
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Kafka Configuration

Kafka 0.8 is the version we currently run. We are currently running with replication but with producers acks = 1. 

## Important Server Configurations

The most important server configurations for performance are those that control the disk flush rate. The more often data is flushed to disk, the more "seek-bound" Kafka will be and the lower the throughput. However very low application flush rates can lead to high latency when the flush finally does occur (because of the volume of data that must be flushed). See the section below on application versus OS flush. 

## Important Client Configurations

The most important producer configurations control 

  * compression
  * sync vs async production>
  * batch size (for async producers)

The most important consumer configuration is the fetch size. 

All configurations are documented in the configuration section. 

## A Production Server Config

Here is our server production server configuration: 
    
    
    # Replication configurations
    num.replica.fetchers=4
    replica.fetch.max.bytes=1048576
    replica.fetch.wait.max.ms=500
    replica.high.watermark.checkpoint.interval.ms=5000
    replica.socket.timeout.ms=30000
    replica.socket.receive.buffer.bytes=65536
    replica.lag.time.max.ms=10000
    replica.lag.max.messages=4000
    
    controller.socket.timeout.ms=30000
    controller.message.queue.size=10
    
    # Log configuration
    num.partitions=8
    message.max.bytes=1000000
    auto.create.topics.enable=true
    log.index.interval.bytes=4096
    log.index.size.max.bytes=10485760
    log.retention.hours=168
    log.flush.interval.ms=10000
    log.flush.interval.messages=20000
    log.flush.scheduler.interval.ms=2000
    log.roll.hours=168
    log.retention.check.interval.ms=300000
    log.segment.bytes=1073741824
    
    # ZK configuration
    zk.connection.timeout.ms=6000
    zk.sync.time.ms=2000
    
    # Socket server configuration
    num.io.threads=8
    num.network.threads=8
    socket.request.max.bytes=104857600
    socket.receive.buffer.bytes=1048576
    socket.send.buffer.bytes=1048576
    queued.max.requests=16
    fetch.purgatory.purge.interval.requests=100
    producer.purgatory.purge.interval.requests=100
    

Our client configuration varies a fair amount between different use cases. 