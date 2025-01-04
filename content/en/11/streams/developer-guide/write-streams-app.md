---
title: Writing a Streams Application
description: 
weight: 1
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Writing a Streams Application

**Table of Contents**

  * Libraries and Maven artifacts
  * Using Kafka Streams within your application code



Any Java application that makes use of the Kafka Streams library is considered a Kafka Streams application. The computational logic of a Kafka Streams application is defined as a [processor topology](../core-concepts.html#streams_topology), which is a graph of stream processors (nodes) and streams (edges).

You can define the processor topology with the Kafka Streams APIs:

[Kafka Streams DSL](dsl-api.html#streams-developer-guide-dsl)
    A high-level API that provides the most common data transformation operations such as `map`, `filter`, `join`, and `aggregations` out of the box. The DSL is the recommended starting point for developers new to Kafka Streams, and should cover many use cases and stream processing needs.
[Processor API](processor-api.html#streams-developer-guide-processor-api)
    A low-level API that lets you add and connect processors as well as interact directly with state stores. The Processor API provides you with even more flexibility than the DSL but at the expense of requiring more manual work on the side of the application developer (e.g., more lines of code).

# Libraries and Maven artifacts

This section lists the Kafka Streams related libraries that are available for writing your Kafka Streams applications.

You can define dependencies on the following libraries for your Kafka Streams applications.

Group ID | Artifact ID | Version | Description  
---|---|---|---  
`org.apache.kafka` | `kafka-streams` | `1.1.0` | (Required) Base library for Kafka Streams.  
`org.apache.kafka` | `kafka-clients` | `1.1.0` | (Required) Kafka client library. Contains built-in serializers/deserializers.  
  
**Tip**

See the section [Data Types and Serialization](datatypes.html#streams-developer-guide-serdes) for more information about Serializers/Deserializers.

Example `pom.xml` snippet when using Maven:
    
    
    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka-streams</artifactId>
        <version>1.1.0</version>
    </dependency>
    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka-clients</artifactId>
        <version>1.1.0</version>
    </dependency>
                  
    

# Using Kafka Streams within your application code

You can call Kafka Streams from anywhere in your application code, but usually these calls are made within the `main()` method of your application, or some variant thereof. The basic elements of defining a processing topology within your application are described below.

First, you must create an instance of `KafkaStreams`.

  * The first argument of the `KafkaStreams` constructor takes a topology (either `StreamsBuilder#build()` for the [DSL](dsl-api.html#streams-developer-guide-dsl) or `Topology` for the [Processor API](processor-api.html#streams-developer-guide-processor-api)) that is used to define a topology.
  * The second argument is an instance of `StreamsConfig`, which defines the configuration for this specific topology.



Code example:
    
    
    import org.apache.kafka.streams.KafkaStreams;
    import org.apache.kafka.streams.StreamsConfig;
    import org.apache.kafka.streams.kstream.StreamsBuilder;
    import org.apache.kafka.streams.processor.Topology;
    
    // Use the builders to define the actual processing topology, e.g. to specify
    // from which input topics to read, which stream operations (filter, map, etc.)
    // should be called, and so on.  We will cover this in detail in the subsequent
    // sections of this Developer Guide.
    
    StreamsBuilder builder = ...;  // when using the DSL
    Topology topology = builder.build();
    //
    // OR
    //
    Topology topology = ...; // when using the Processor API
    
    // Use the configuration to tell your application where the Kafka cluster is,
    // which Serializers/Deserializers to use by default, to specify security settings,
    // and so on.
    StreamsConfig config = ...;
    
    KafkaStreams streams = new KafkaStreams(topology, config);
    

At this point, internal structures are initialized, but the processing is not started yet. You have to explicitly start the Kafka Streams thread by calling the `KafkaStreams#start()` method:
    
    
    // Start the Kafka Streams threads
    streams.start();
    

If there are other instances of this stream processing application running elsewhere (e.g., on another machine), Kafka Streams transparently re-assigns tasks from the existing instances to the new instance that you just started. For more information, see [Stream Partitions and Tasks](../architecture.html#streams-architecture-tasks) and [Threading Model](../architecture.html#streams-architecture-threads).

To catch any unexpected exceptions, you can set an `java.lang.Thread.UncaughtExceptionHandler` before you start the application. This handler is called whenever a stream thread is terminated by an unexpected exception:
    
    
    // Java 8+, using lambda expressions
    streams.setUncaughtExceptionHandler((Thread thread, Throwable throwable) -> {
      // here you should examine the throwable/exception and perform an appropriate action!
    });
    
    
    // Java 7
    streams.setUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler() {
      public void uncaughtException(Thread thread, Throwable throwable) {
        // here you should examine the throwable/exception and perform an appropriate action!
      }
    });
    

To stop the application instance, call the `KafkaStreams#close()` method:
    
    
    // Stop the Kafka Streams threads
    streams.close();
    

To allow your application to gracefully shutdown in response to SIGTERM, it is recommended that you add a shutdown hook and call `KafkaStreams#close`.

  * Here is a shutdown hook example in Java 8+:

> >     // Add shutdown hook to stop the Kafka Streams threads.
>     // You can optionally provide a timeout to `close`.
>     Runtime.getRuntime().addShutdownHook(new Thread(streams::close));
>     

  * Here is a shutdown hook example in Java 7:

> >     // Add shutdown hook to stop the Kafka Streams threads.
>     // You can optionally provide a timeout to `close`.
>     Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
>       @Override
>       public void run() {
>           streams.close();
>       }
>     }));
>     




After an application is stopped, Kafka Streams will migrate any tasks that had been running in this instance to available remaining instances.

[Previous](/11/streams/developer-guide/) [Next](/11/streams/developer-guide/config-streams)

  * [Documentation](/documentation)
  * [Kafka Streams](/streams)
  * [Developer Guide](/streams/developer-guide/)


