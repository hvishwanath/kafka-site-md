---
title: Messages
description: Messages
weight: 3
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Messages

Messages consist of a fixed-size header, a variable length opaque key byte array and a variable length opaque value byte array. The header contains the following fields: 

  * A CRC32 checksum to detect corruption or truncation. 
  *   * A format version. 
  * An attributes identifier 
  * A timestamp 

Leaving the key and value opaque is the right decision: there is a great deal of progress being made on serialization libraries right now, and any particular choice is unlikely to be right for all uses. Needless to say a particular application using Kafka would likely mandate a particular serialization type as part of its usage. The `MessageSet` interface is simply an iterator over messages with specialized methods for bulk reading and writing to an NIO `Channel`. 
