---
title: Java Version
description: Java Version
weight: 6
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Java Version

Java 8 and Java 11 are supported. Java 11 performs significantly better if TLS is enabled, so it is highly recommended (it also includes a number of other performance improvements: G1GC, CRC32C, Compact Strings, Thread-Local Handshakes and more). From a security perspective, we recommend the latest released patch version as older freely available versions have disclosed security vulnerabilities. Typical arguments for running Kafka with OpenJDK-based Java implementations (including Oracle JDK) are: 
    
    
      -Xmx6g -Xms6g -XX:MetaspaceSize=96m -XX:+UseG1GC
      -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:G1HeapRegionSize=16M
      -XX:MinMetaspaceFreeRatio=50 -XX:MaxMetaspaceFreeRatio=80 -XX:+ExplicitGCInvokesConcurrent

For reference, here are the stats for one of LinkedIn's busiest clusters (at peak) that uses said Java arguments: 

  * 60 brokers
  * 50k partitions (replication factor 2)
  * 800k messages/sec in
  * 300 MB/sec inbound, 1 GB/sec+ outbound

All of the brokers in that cluster have a 90% GC pause time of about 21ms with less than 1 young GC per second. 
