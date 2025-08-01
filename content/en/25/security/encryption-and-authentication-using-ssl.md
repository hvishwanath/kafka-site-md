---
title: Encryption and Authentication using SSL
description: Encryption and Authentication using SSL
weight: 2
tags: ['kafka', 'docs']
aliases: 
keywords: 
type: docs
---

# Encryption and Authentication using SSL 

Apache Kafka allows clients to connect over SSL. By default, SSL is disabled but can be turned on as needed. 

  1. ####  Generate SSL key and certificate for each Kafka broker 

The first step of deploying one or more brokers with the SSL support is to generate the key and the certificate for each machine in the cluster. You can use Java's keytool utility to accomplish this task. We will generate the key into a temporary keystore initially so that we can export and sign it later with CA. 
    
                    keytool -keystore server.keystore.jks -alias localhost -validity {validity} -genkey -keyalg RSA

You need to specify two parameters in the above command: 
    1. keystore: the keystore file that stores the certificate. The keystore file contains the private key of the certificate; therefore, it needs to be kept safely.
    2. validity: the valid time of the certificate in days.
  


### Configuring Host Name Verification 

From Kafka version 2.0.0 onwards, host name verification of servers is enabled by default for client connections as well as inter-broker connections to prevent man-in-the-middle attacks. Server host name verification may be disabled by setting `ssl.endpoint.identification.algorithm` to an empty string. For example, 
    
        	ssl.endpoint.identification.algorithm=

For dynamically configured broker listeners, hostname verification may be disabled using `kafka-configs.sh`. For example, 
    
                bin/kafka-configs.sh --bootstrap-server localhost:9093 --entity-type brokers --entity-name 0 --alter --add-config "listener.name.internal.ssl.endpoint.identification.algorithm="

For older versions of Kafka, `ssl.endpoint.identification.algorithm` is not defined by default, so host name verification is not performed. The property should be set to `HTTPS` to enable host name verification. 
    
        	ssl.endpoint.identification.algorithm=HTTPS 

Host name verification must be enabled to prevent man-in-the-middle attacks if server endpoints are not validated externally. 

### Configuring Host Name In Certificates 

If host name verification is enabled, clients will verify the server's fully qualified domain name (FQDN) against one of the following two fields: 
    1. Common Name (CN) 
    2. Subject Alternative Name (SAN)    
Both fields are valid, RFC-2818 recommends the use of SAN however. SAN is also more flexible, allowing for multiple DNS entries to be declared. Another advantage is that the CN can be set to a more meaningful value for authorization purposes. To add a SAN field append the following argument ` -ext SAN=DNS:{FQDN} ` to the keytool command: 
    
                keytool -keystore server.keystore.jks -alias localhost -validity {validity} -genkey -keyalg RSA -ext SAN=DNS:{FQDN}

The following command can be run afterwards to verify the contents of the generated certificate: 
    
                keytool -list -v -keystore server.keystore.jks

  2. ####  Creating your own CA 

After the first step, each machine in the cluster has a public-private key pair, and a certificate to identify the machine. The certificate, however, is unsigned, which means that an attacker can create such a certificate to pretend to be any machine.

Therefore, it is important to prevent forged certificates by signing them for each machine in the cluster. A certificate authority (CA) is responsible for signing certificates. CA works likes a government that issues passports—the government stamps (signs) each passport so that the passport becomes difficult to forge. Other governments verify the stamps to ensure the passport is authentic. Similarly, the CA signs the certificates, and the cryptography guarantees that a signed certificate is computationally difficult to forge. Thus, as long as the CA is a genuine and trusted authority, the clients have high assurance that they are connecting to the authentic machines. 
    
                    openssl req -new -x509 -keyout ca-key -out ca-cert -days 365

The generated CA is simply a public-private key pair and certificate, and it is intended to sign other certificates.  
The next step is to add the generated CA to the **clients' truststore** so that the clients can trust this CA: 
    
                    keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert

**Note:** If you configure the Kafka brokers to require client authentication by setting ssl.client.auth to be "requested" or "required" on the Kafka brokers config then you must provide a truststore for the Kafka brokers as well and it should have all the CA certificates that clients' keys were signed by. 
    
                    keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert

In contrast to the keystore in step 1 that stores each machine's own identity, the truststore of a client stores all the certificates that the client should trust. Importing a certificate into one's truststore also means trusting all certificates that are signed by that certificate. As the analogy above, trusting the government (CA) also means trusting all passports (certificates) that it has issued. This attribute is called the chain of trust, and it is particularly useful when deploying SSL on a large Kafka cluster. You can sign all certificates in the cluster with a single CA, and have all machines share the same truststore that trusts the CA. That way all machines can authenticate all other machines.
  3. ####  Signing the certificate 

The next step is to sign all certificates generated by step 1 with the CA generated in step 2. First, you need to export the certificate from the keystore: 
    
                    keytool -keystore server.keystore.jks -alias localhost -certreq -file cert-file

Then sign it with the CA: 
    
                    openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days {validity} -CAcreateserial -passin pass:{ca-password}

Finally, you need to import both the certificate of the CA and the signed certificate into the keystore: 
    
                    keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert
                keytool -keystore server.keystore.jks -alias localhost -import -file cert-signed

The definitions of the parameters are the following: 
    1. keystore: the location of the keystore
    2. ca-cert: the certificate of the CA
    3. ca-key: the private key of the CA
    4. ca-password: the passphrase of the CA
    5. cert-file: the exported, unsigned certificate of the server
    6. cert-signed: the signed certificate of the server
Here is an example of a bash script with all above steps. Note that one of the commands assumes a password of `test1234`, so either use that password or edit the command before running it. 
    
                    #!/bin/bash
                #Step 1
                keytool -keystore server.keystore.jks -alias localhost -validity 365 -keyalg RSA -genkey
                #Step 2
                openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
                keytool -keystore server.truststore.jks -alias CARoot -import -file ca-cert
                keytool -keystore client.truststore.jks -alias CARoot -import -file ca-cert
                #Step 3
                keytool -keystore server.keystore.jks -alias localhost -certreq -file cert-file
                openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:test1234
                keytool -keystore server.keystore.jks -alias CARoot -import -file ca-cert
                keytool -keystore server.keystore.jks -alias localhost -import -file cert-signed

  4. ####  Configuring Kafka Brokers 

Kafka Brokers support listening for connections on multiple ports. We need to configure the following property in server.properties, which must have one or more comma-separated values: 
    
        listeners

If SSL is not enabled for inter-broker communication (see below for how to enable it), both PLAINTEXT and SSL ports will be necessary. 
    
                    listeners=PLAINTEXT://host.name:port,SSL://host.name:port

Following SSL configs are needed on the broker side 
    
                    ssl.keystore.location=/var/private/ssl/server.keystore.jks
                ssl.keystore.password=test1234
                ssl.key.password=test1234
                ssl.truststore.location=/var/private/ssl/server.truststore.jks
                ssl.truststore.password=test1234

Note: ssl.truststore.password is technically optional but highly recommended. If a password is not set access to the truststore is still available, but integrity checking is disabled. Optional settings that are worth considering: 
    1. ssl.client.auth=none ("required" => client authentication is required, "requested" => client authentication is requested and client without certs can still connect. The usage of "requested" is discouraged as it provides a false sense of security and misconfigured clients will still connect successfully.)
    2. ssl.cipher.suites (Optional). A cipher suite is a named combination of authentication, encryption, MAC and key exchange algorithm used to negotiate the security settings for a network connection using TLS or SSL network protocol. (Default is an empty list)
    3. ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1 (list out the SSL protocols that you are going to accept from clients. Do note that SSL is deprecated in favor of TLS and using SSL in production is not recommended)
    4. ssl.keystore.type=JKS
    5. ssl.truststore.type=JKS
    6. ssl.secure.random.implementation=SHA1PRNG
If you want to enable SSL for inter-broker communication, add the following to the server.properties file (it defaults to PLAINTEXT) 
    
                    security.inter.broker.protocol=SSL

Due to import regulations in some countries, the Oracle implementation limits the strength of cryptographic algorithms available by default. If stronger algorithms are needed (for example, AES with 256-bit keys), the [JCE Unlimited Strength Jurisdiction Policy Files](http://www.oracle.com/technetwork/java/javase/downloads/index.html) must be obtained and installed in the JDK/JRE. See the [JCA Providers Documentation](https://docs.oracle.com/javase/8/docs/technotes/guides/security/SunProviders.html) for more information. 

The JRE/JDK will have a default pseudo-random number generator (PRNG) that is used for cryptography operations, so it is not required to configure the implementation used with the 
    
        ssl.secure.random.implementation

. However, there are performance issues with some implementations (notably, the default chosen on Linux systems, 
    
        NativePRNG

, utilizes a global lock). In cases where performance of SSL connections becomes an issue, consider explicitly setting the implementation to be used. The 
    
        SHA1PRNG

implementation is non-blocking, and has shown very good performance characteristics under heavy load (50 MB/sec of produced messages, plus replication traffic, per-broker). 

Once you start the broker you should be able to see in the server.log 
    
                    with addresses: PLAINTEXT -> EndPoint(192.168.64.1,9092,PLAINTEXT),SSL -> EndPoint(192.168.64.1,9093,SSL)

To check quickly if the server keystore and truststore are setup properly you can run the following command 
    
        openssl s_client -debug -connect localhost:9093 -tls1

(Note: TLSv1 should be listed under ssl.enabled.protocols)  
In the output of this command you should see server's certificate: 
    
                    -----BEGIN CERTIFICATE-----
                {variable sized random bytes}
                -----END CERTIFICATE-----
                subject=/C=US/ST=CA/L=Santa Clara/O=org/OU=org/CN=Sriharsha Chintalapani
                issuer=/C=US/ST=CA/L=Santa Clara/O=org/OU=org/CN=kafka/emailAddress=test@test.com

If the certificate does not show up or if there are any other error messages then your keystore is not setup properly.
  5. ####  Configuring Kafka Clients 

SSL is supported only for the new Kafka Producer and Consumer, the older API is not supported. The configs for SSL will be the same for both producer and consumer.  
If client authentication is not required in the broker, then the following is a minimal configuration example: 
    
                    security.protocol=SSL
                ssl.truststore.location=/var/private/ssl/client.truststore.jks
                ssl.truststore.password=test1234

Note: ssl.truststore.password is technically optional but highly recommended. If a password is not set access to the truststore is still available, but integrity checking is disabled. If client authentication is required, then a keystore must be created like in step 1 and the following must also be configured: 
    
                    ssl.keystore.location=/var/private/ssl/client.keystore.jks
                ssl.keystore.password=test1234
                ssl.key.password=test1234

Other configuration settings that may also be needed depending on our requirements and the broker configuration: 
    1. ssl.provider (Optional). The name of the security provider used for SSL connections. Default value is the default security provider of the JVM.
    2. ssl.cipher.suites (Optional). A cipher suite is a named combination of authentication, encryption, MAC and key exchange algorithm used to negotiate the security settings for a network connection using TLS or SSL network protocol.
    3. ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1. It should list at least one of the protocols configured on the broker side
    4. ssl.truststore.type=JKS
    5. ssl.keystore.type=JKS
  
Examples using console-producer and console-consumer: 
    
                    kafka-console-producer.sh --bootstrap-server localhost:9093 --topic test --producer.config client-ssl.properties
                kafka-console-consumer.sh --bootstrap-server localhost:9093 --topic test --consumer.config client-ssl.properties



