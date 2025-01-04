---
title: Message Format
description: Message Format
weight: 3
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Message Format

Messages (aka Records) are always written in batches. The technical term for a batch of messages is a record batch, and a record batch contains one or more records. In the degenerate case, we could have a record batch containing a single record. Record batches and records have their own headers. The format of each is described below for Kafka version 0.11.0 and later (message format version v2, or magic=2). [Click here](https://cwiki.apache.org/confluence/display/KAFKA/A+Guide+To+The+Kafka+Protocol#AGuideToTheKafkaProtocol-Messagesets) for details about message formats 0 and 1.

## Record Batch

The following is the on-disk format of a RecordBatch. 
    
    
    		baseOffset: int64
    		batchLength: int32
    		partitionLeaderEpoch: int32
    		magic: int8 (current magic value is 2)
    		crc: int32
    		attributes: int16
    			bit 0~2:
    				0: no compression
    				1: gzip
    				2: snappy
    				3: lz4
    			bit 3: timestampType
    			bit 4: isTransactional (0 means not transactional)
    			bit 5: isControlBatch (0 means not a control batch)
    			bit 6~15: unused
    		lastOffsetDelta: int32
    		firstTimestamp: int64
    		maxTimestamp: int64
    		producerId: int64
    		producerEpoch: int16
    		baseSequence: int32
    		records: [Record]
    	

Note that when compression is enabled, the compressed record data is serialized directly following the count of the number of records. 

The CRC covers the data from the attributes to the end of the batch (i.e. all the bytes that follow the CRC). It is located after the magic byte, which means that clients must parse the magic byte before deciding how to interpret the bytes between the batch length and the magic byte. The partition leader epoch field is not included in the CRC computation to avoid the need to recompute the CRC when this field is assigned for every batch that is received by the broker. The CRC-32C (Castagnoli) polynomial is used for the computation.

On compaction: unlike the older message formats, magic v2 and above preserves the first and last offset/sequence numbers from the original batch when the log is cleaned. This is required in order to be able to restore the producer's state when the log is reloaded. If we did not retain the last sequence number, for example, then after a partition leader failure, the producer might see an OutOfSequence error. The base sequence number must be preserved for duplicate checking (the broker checks incoming Produce requests for duplicates by verifying that the first and last sequence numbers of the incoming batch match the last from that producer). As a result, it is possible to have empty batches in the log when all the records in the batch are cleaned but batch is still retained in order to preserve a producer's last sequence number. One oddity here is that the baseTimestamp field is not preserved during compaction, so it will change if the first record in the batch is compacted away.

### Control Batches

A control batch contains a single record called the control record. Control records should not be passed on to applications. Instead, they are used by consumers to filter out aborted transactional messages.

The key of a control record conforms to the following schema: 
    
    
           version: int16 (current version is 0)
           type: int16 (0 indicates an abort marker, 1 indicates a commit)
        

The schema for the value of a control record is dependent on the type. The value is opaque to clients.

## Record

Record level headers were introduced in Kafka 0.11.0. The on-disk format of a record with Headers is delineated below. 
    
    
    		length: varint
    		attributes: int8
    			bit 0~7: unused
    		timestampDelta: varint
    		offsetDelta: varint
    		keyLength: varint
    		key: byte[]
    		valueLen: varint
    		value: byte[]
    		Headers => [Header]
    	

### Record Header
    
    
    		headerKeyLength: varint
    		headerKey: String
    		headerValueLength: varint
    		Value: byte[]
    	

We use the the same varint encoding as Protobuf. More information on the latter can be found [here](https://developers.google.com/protocol-buffers/docs/encoding#varints). The count of headers in a record is also encoded as a varint.
