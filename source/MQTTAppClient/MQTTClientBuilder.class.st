Class {
	#name : 'MQTTClientBuilder',
	#superclass : 'Object',
	#instVars : [
		'client',
		'dispatcher',
		'mqttVersion',
		'createOptions',
		'connectOptions',
		'sslOptions',
		'willOptions'
	],
	#pools : [
		'MQTTConstants'
	],
	#category : 'MQTTAppClient'
}

{ #category : 'Creation' }
MQTTClientBuilder class >> new [
	"Answer a new initialized instance of this builder
	 
	 Answers:
		<MQTTClientBuilder>"
	
	^self basicNew initialize
]

{ #category : 'Building',
  #vaVisibility : 'private' }
MQTTClientBuilder >> buildClient [
	"Answer a newly built mqtt client using the dispatcher provided
	 
	 Arguments:
		dispatcher - <MQTTLibraryDispatcher>
	 Answers:
		<MQTTClient>"

	| rc clientPtr createOptionsStruct serverUri clientId pType pContext |

	serverUri := self createOptions at: ##ServerURI ifAbsent: [nil].
	clientId := self createOptions at: ##ClientId ifAbsent: [nil].
	pType := self createOptions at: ##PersistenceType ifAbsent: [MQTTCLIENT_PERSISTENCE_NONE].
	pContext := self createOptions at: ##PersistenceContext ifAbsent: [nil].
	clientPtr := OSObjectPointer itemType: MQTTClient.
	rc :=
		mqttVersion isNil
			ifTrue: [
				self dispatcher
					callMQTTClient_createWith: clientPtr
					with: serverUri
					with: clientId
					with: pType
					with: pContext]
			ifFalse: [
				"C-ALLOC"
				createOptionsStruct := self buildCreateOptionsStruct.
				self dispatcher
					callMQTTClient_createWithOptionsWith: clientPtr
					with: serverUri
					with: clientId
					with: pType
					with: pContext
					with: createOptionsStruct].
	rc == MQTTCLIENT_SUCCESS
		ifTrue: [createOptionsStruct ifNotNil: [
				"C-FREE"
				createOptionsStruct free]]
		ifFalse: [MQTTException errorCode: rc].

	client := clientPtr at: 0.
	client isNull ifTrue: [^nil].
	client
		ownsMemory: true;
		dispatcher: self dispatcher.
	^client
]

{ #category : 'Building',
  #vaVisibility : 'private' }
MQTTClientBuilder >> buildConnectOptionsStruct [

	| connectStruct |

	connectStruct := MQTTClientConnectOptions create: self dispatcher.
	mqttVersion ifNotNil: [connectStruct MQTTVersion: mqttVersion].
	self connectOptions
		at: ##KeepAliveInterval ifPresent: [:val | connectStruct keepAliveInterval: val];
		at: ##CleanSession ifPresent: [:val | connectStruct cleansession: val];
		at: ##Reliable ifPresent: [:val | connectStruct reliable: val];
		at: ##Username ifPresent: [:val | connectStruct username: val];
		at: ##Password
			ifPresent: [:val |
				val isString
					ifTrue: [connectStruct password: val]
					ifFalse: [
						connectStruct
							password: nil;
							binarypwdData: val;
							binarypwdLen: val size]];
		at: ##ConnectTimeout ifPresent: [:val | connectStruct connectTimeout: val];
		at: ##RetryInterval ifPresent: [:val | connectStruct retryInterval: val];
		at: ##ServerURIs
			ifPresent: [:val |
				connectStruct
					serverURIs: (self osConvertCollectionOfStrings: val);
					serverURIcount: val size];
		at: ##MaxInflightMessages ifPresent: [:val | connectStruct maxInflightMessages: val];
		at: ##CleanStart ifPresent: [:val | connectStruct cleanstart: val].

	connectStruct will: self buildWillOptionsStruct.
	connectStruct ssl: self buildSslOptionsStruct.

	^connectStruct
]

{ #category : 'Building',
  #vaVisibility : 'private' }
MQTTClientBuilder >> buildCreateOptionsStruct [

	| createOptionsStruct |

	createOptionsStruct := MQTTClientCreateOptions create: self dispatcher.
	createOptionsStruct MQTTVersion: (mqttVersion ifNil: [MQTTVERSION_DEFAULT]).
	^createOptionsStruct
]

{ #category : 'Building',
  #vaVisibility : 'private' }
MQTTClientBuilder >> buildSslOptionsStruct [

	| sslStruct |

	sslStruct := MQTTClientSslOptions create: self dispatcher.
	self sslOptions
		at: ##TrustStore ifPresent: [:val | sslStruct trustStore: val];
		at: ##KeyStore ifPresent: [:val | sslStruct keyStore: val];
		at: ##PrivateKey ifPresent: [:val | sslStruct privateKey: val];
		at: ##PrivateKeyPassword ifPresent: [:val | sslStruct privateKeyPassword: val];
		at: ##EnabledCipherSuites ifPresent: [:val | sslStruct enabledCipherSuites: val];
		at: ##EnableServerCertAuth ifPresent: [:val | sslStruct enableServerCertAuth: val];
		at: ##SslVersion ifPresent: [:val | sslStruct sslVersion: val];
		at: ##SslVerify ifPresent: [:val | sslStruct verify: val];
		at: ##CAPath ifPresent: [:val | sslStruct CApath: val].

	^sslStruct
]

{ #category : 'Building',
  #vaVisibility : 'private' }
MQTTClientBuilder >> buildWillOptionsStruct [

	| willStruct |

	self willOptions isEmpty ifTrue: [^nil].
	willStruct := MQTTClientWillOptions create: self dispatcher.
	self willOptions
		at: ##TopicName ifPresent: [:val | willStruct topicName: val];
		at: ##Message
			ifPresent: [:val | | message payloadData payloadLength |
				val isString
					ifTrue: [
						message := val.
						payloadData := nil.
						payloadLength := 0].
				val isByteArray
					ifTrue: [
						message := nil.
						payloadData := val.
						payloadLength := val size].
				(message isNil and: [payloadData isNil])
					ifTrue: [
						willStruct free.
						MQTTException signal: 'Invalid Argument'].
				willStruct
					message: message;
					payloadData: payloadData;
					payloadLen: payloadLength];
		at: ##Retained ifPresent: [:val | willStruct retained: val];
		at: ##Qos ifPresent: [:val | willStruct qos: val].
	^willStruct
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> cleanSession: aBoolean [
	"The cleansession setting controls the behaviour
	 of both the client and the server at connection and disconnection time.
	 
	 The client and server both maintain session state information. This
	 information is used to ensure 'at least once' and 'exactly once'
	 delivery, and 'exactly once' receipt of messages. Session state also
	 includes subscriptions created by an MQTT client. You can choose to
	 maintain or discard state information between sessions.
	 
	 When cleansession is true, the state information is discarded at
	 connect and disconnect. Setting cleansession to false keeps the state
	 information. When you connect an MQTT client application with
	 MQTTClient>>connect:, the client identifies the connection using the
	 client identifier and the address of the server. The server checks
	 whether session information for this client
	 has been saved from a previous connection to the server. If a previous
	 session still exists, and cleansession=true, then the previous session
	 information at the client and server is cleared. If cleansession=false,
	 the previous session is resumed. If no previous session exists, a new
	 session is started.
	 
	 Arguments:
		aBoolean - <Boolean>
	 Answers:
		<MQTTClientBuilder> self"

	self connectOptions at: ##CleanSession put: aBoolean.
	^self
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> cleanStart: aBoolean [
	"MQTT V5 clean start flag.  Only clears state at the beginning of the session.
	 
	 Arguments:
		aBoolean - <Boolean>
	 Answers:
		<MQTTClientBuilder>"

	self connectOptions at: ##CleanStart put: aBoolean.
	^self
]

{ #category : 'API' }
MQTTClientBuilder >> connectClient [
	"Connect the client using the connection options that have been defined.
	 On exception, do nothing
	 
	 Answers:
		<Boolean> true if connected, false if not connected"
	
	^self connectClient: []
]

{ #category : 'API' }
MQTTClientBuilder >> connectClient: anExceptionBlock [
	"Retrieve the client (building if necessary) and connect using
	 the connection options. If an existing connected client exists,
	 simply answer true.
	 
	 Arguments:
		aBlock - <Block> 0 or 1-arg block that takes exception as argument
	 Answers:
		<Boolean> true if connected, false otherwise"

	[
		self getClient ifNil: [MQTTException signal: 'Could not create client'].
		self getClient isConnected
			ifFalse: [| connectStruct |
				connectStruct := self buildConnectOptionsStruct.
				[self getClient connect: connectStruct] ensure: [
					"Frees connectOptions/willOptions/sslOptions structs"
					self freeConnectOptionsStruct: connectStruct]].
		^true]
			on: Exception
			do: [:ex |
				anExceptionBlock cull: ex.
				^false]
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTClientBuilder >> connectOptions [
	"Answer the client create options struct
	 
	 Answers:
		<KeyedCollection>"

	^connectOptions
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> connectTimeout: aDuration [
	"The time interval to allow a connect to complete.
	 
	 Arguments:
		aDuration - <Duration> of <Integer> seconds
	 Answers:
		<MQTTClientBuilder> self"

	| timeout |

	timeout := aDuration isInteger ifTrue: [aDuration] ifFalse: [aDuration asSeconds].
	self connectOptions at: ##ConnectTimeout put: timeout.
	^self
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTClientBuilder >> createOptions [
	"Answer the client create options
	 
	 Answers:
		<KeyedCollection>"

	^createOptions
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTClientBuilder >> dispatcher [
	"Answer the dispatcher that is to be assigned to the client and options
	 
	 Answers:
		<MQTTLibraryDispatcher>"
	
	dispatcher isNil ifTrue: [self dispatcher: MQTTLibraryDispatcher default].
	^dispatcher
]

{ #category : 'Accessing' }
MQTTClientBuilder >> dispatcher: aDispatcher [
	"Answer the dispatcher that is to be assigned to the client and options
	 
	 Arguments:
		aDispatcher - <MQTTLibraryDispatcher>
	 Answers:
		<MQTTClientBuilder> self"

	dispatcher := aDispatcher.
	^self
]

{ #category : 'Internal' }
MQTTClientBuilder >> freeConnectOptionsStruct: connectStruct [
	"Frees the connectionOptions/willOptions/sslOptions
	 and internal string data"
	
	connectStruct free
]

{ #category : 'API' }
MQTTClientBuilder >> getClient [
	"Answer the client.  If none is availble, then attempt to build it
	 If the client can not be built, then nil if answered
	 
	 Answers:
		<MQTTClient>"

	(client notNil and: [client isNull or: [client isUndefined]]) ifTrue: [client := nil].
	client isNil ifTrue: [client := self buildClient].
	^client
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTClientBuilder >> initialize [

	createOptions := LookupTable new.
	connectOptions := LookupTable new.
	willOptions := LookupTable new.
	sslOptions := LookupTable new
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> keepAliveInterval: aDuration [
	"The 'keep alive' interval defines the maximum time
	 that should pass without communication between the client and the server.
	 
	 The client will ensure that at least one message travels across the
	 network within each keep alive period.  In the absence of a data-related
	 message during the time period, the client sends a very small MQTT
	 'ping' message, which the server will acknowledge.
	 
	 The keep alive interval enables the client to detect when the server is no longer
	 available without having to wait for the long TCP/IP timeout.
	 
	 Arguments:
		aDuration - <Duration> or <Integer> seconds
	 Answers:
		<MQTTClientBuilder> self"

	| interval |

	interval := aDuration isInteger ifTrue: [aDuration] ifFalse: [aDuration asSeconds].
	self connectOptions at: ##KeepAliveInterval put: interval.
	^self
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> maxInflightMessages: aNumber [
	"Set the maximum number of messages in flight
	 
	 Arguments:
		aNumber - <Number>
	 Answers:
		<MQTTClientBuilder>"

	self connectOptions at: ##MaxInflightMessages put: aNumber.
	^self
]

{ #category : 'Options - Creation' }
MQTTClientBuilder >> mqttVersion: aVersion [
	"Set the mqtt version for the client
	 
	 @see MQTTConstants::MQTTVERSION*
		-MQTTVERSION_DEFAULT  (default)
		-MQTTVERSION_3_1
		-MQTTVERSION_3_1_1
		-MQTTVERSION_5
		
	 Arguments:
		<Integer> one of the constants above 
	 Answers:
		<MQTTClientBuilder>"

	mqttVersion := aVersion.
	^self
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTClientBuilder >> osConvertCollectionOfStrings: aCollection [
	"Private: Convert a smalltalk collection of strings to an os object collection of
	 null-term strings.  This is modelled as an OSObjectPointer to OSStringZ.
	 The 'length' of the string is the same as the size of @aCollection.
	 
	 IMPORTANT: The memory returned by this method is os-heap allocated.
	 The caller is responsible for freeing this memory
	 
	 Arguments:
		aCollection - <Collection>
	 Answers:
		<OSObjectPointer>"

	| osObject |

	(aCollection allSatisfy: [:e | e isString or: [e isByteArray]])
		ifFalse: [MQTTException signal: 'Invalid Argument: Expecting Collection of byte objects'].
	osObject := OSObjectPointer calloc: aCollection size itemType: OSStringZ.
	aCollection doWithIndex: [:str :i | osObject at: i - 1 put: str copyToOSMemory].
	^osObject
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> password: aString [
	"MQTT servers that support the MQTT v3.1.1 protocol provide authentication
	 and authorisation by user name and password.
	 This is the password parameter.
	 
	 Arguments:
		aString - <String> | <ByteArray>
	 Answers:
		<MQTTClientBuilder> self"

	self connectOptions at: ##Password put: aString.
	^self
]

{ #category : 'Options - Creation' }
MQTTClientBuilder >> persistenceContext: anObject [
	"If the application uses MQTTCLIENT_PERSISTENCE_NONE persistence,
	 this argument is unused and should be nil.
	 
	 For MQTTCLIENT_PERSISTENCE_DEFAULT persistence, it
	 should be set to the location of the persistence directory (if set
	 to nil, the persistence directory used is the working directory).
	 
	 Applications that use MQTTCLIENT_PERSISTENCE_USER persistence set this
	 argument to point to a valid MQTTClientPersistence object.
	 
	 Arguments:
		anObject - <Object>
	 Answers:
		<MQTTClientBuilder>"

	self createOptions at: ##PersistenceContext put: anObject.
	^self
]

{ #category : 'Options - Creation' }
MQTTClientBuilder >> persistenceType: type [
	"Additional options for the create.
	 
	 The type of persistence to be used by the client @see MQTTConstants:
	 
	 MQTTCLIENT_PERSISTENCE_NONE: Use in-memory persistence. If the device or
	 system on which the client is running fails or is switched off, the current
	 state of any in-flight messages is lost and some messages may not be
	 delivered even at QoS1 and QoS2.
	 
	 MQTTCLIENT_PERSISTENCE_DEFAULT: Use the default (file system-based)
	 persistence mechanism. Status about in-flight messages is held in persistent
	 storage and provides some protection against message loss in the case of
	 unexpected failure.
	 
	 MQTTCLIENT_PERSISTENCE_USER: Use an application-specific persistence
	 implementation. Using this type of persistence gives control of the
	 persistence mechanism to the application. The application has to implement
	 the MQTTClient_persistence interface.
 
	 Arguments:
		type - <Integer>
	 Answers:
		<MQTTClientBuilder>"

	self createOptions at: ##PersistenceType put: type.
	^self
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> reliable: aBoolean [
	"This is a boolean value that controls how many messages can be in-flight
	 simultaneously. 
	 
	 Setting this to true means that a published
	 message must be completed (acknowledgements received) before another
	 can be sent. Attempts to publish additional messages receive an
	 MQTTCLIENT_MAX_MESSAGES_INFLIGHT return code.
	 
	 Setting this flag to false allows up to 10 messages to be in-flight.
	 This can increase overall throughput in some circumstances.
	 
	 Arguments:
		aBoolean - <Boolean>
	 Answers:
		<MQTTClientBuilder> self"

	self connectOptions at: ##Reliable put: aBoolean.
	^self
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> retryInterval: aDuration [
	"The time interval in seconds after which unacknowledged publish requests are
	 retried during a TCP session.
	 
	 With MQTT 3.1.1 and later, retries are not required except on reconnect.
	 0 turns off in-session retries, and is the recommended setting.
	 Adding retries to an already overloaded network only exacerbates the problem.
	 
	 Arguments:
		aDuration - <Duration> or <Integer> seconds
	 Answers:
		<MQTTClientBuilder> self"

	| interval |

	interval := aDuration isInteger ifTrue: [aDuration] ifFalse: [aDuration asSeconds].
	self connectOptions at: ##RetryInterval put: interval.
	^self
]

{ #category : 'Options - Creation' }
MQTTClientBuilder >> serverURI: serverUri clientId: clientId [
	"ServerURI:
	 A string specifying the server to which the client will connect.
	 It takes the form 'protocol://host:port'
	 Currently, 'protocol' must be 'tcp' or 'ssl'.
	 For 'host', you can specify either an IP address or a host name.
	 For instance, to connect to a server running on the local machines 
	 with the default MQTT port, specify 'tcp://localhost:1883'
	 
	 ClientId:
	 The client identifier passed to the server when the client connects to it.
	 It is a UTF-8 encoded string.
	 
	 Arguments:
		serverUri - <String> 
		clientId - <String> utf8-encoded
	 Answers:
		<MQTTClientBuilder>"

	self createOptions
		at: ##ServerURI put: serverUri;
		at: ##ClientId put: clientId.
	^self
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> serverURIs: aCollection [
	"An optional array of null-terminated strings specifying the servers to
	 which the client will connect. Each string takes the form 'protocol://host:port'.
	 'protocol' must be 'tcp' or 'ssl'. For 'host', you can
	 specify either an IP address or a host name. For instance, to connect to
	 a server running on the local machines with the default MQTT port, specify
	 'tcp://localhost:1883'.
	 If this list is empty (the default), the server URI specified on MQTTClient_create()
	 is used.
	 
	 Arguments:
		aCollection - <Collection> of <String> values
	 Answers:
		<MQTTClientBuilder>"

	self connectOptions at: ##ServerURIs put: aCollection.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslCAPath: aPath [
	"From the OpenSSL documentation:
	 If CApath is not NULL, it points to a directory containing CA certificates in PEM format.
	 Exists only if struct_version >= 2
	 
	 Arguments:
		aPath - <String | CfsPath>
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##CAPath put: aPath asString.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslEnabledCipherSuites: aString [
	"The list of cipher suites that the client will present to the server during the SSL handshake. For a
	 full explanation of the cipher list format, please see the OpenSSL on-line documentation:
	 http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT
	 
	 If this setting is ommitted, its default value will be 'ALL', that is, all the cipher suites -excluding
	 those offering no encryption- will be considered.
	 
	 This setting can be used to set an SSL anonymous connection ('aNULL' string value, for instance).
	 
	 Arguments:
		aString - <String>
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##EnabledCipherSuites put: aString.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslEnableServerCertAuth: aBoolean [
	"True/False option to enable verification of the server certificate
	 
	 Arguments:
		aBoolean - <Boolean>
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##EnableServerCertAuth put: aBoolean.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslKeyStore: aPath [
	"The file in PEM format containing the public certificate chain of the client. It may also include
	 the client's private key.
	 
	 Arguments:
		aPath - <String | CfsPath>
	 Answers:
		<MQTTClientBuilder>"
	
	self sslOptions at: ##KeyStore put: aPath asString.
	^self
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTClientBuilder >> sslOptions [
	"Answer the connection ssl options
	 
	 Answers:
		<KeyedCollection>"

	^sslOptions
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslPrivateKey: aPath [
	"If not included in the sslKeyStore, this setting points to the file in PEM format containing
	 the client's private key.
	 
	 Arguments:
		aPath - <String | CfsPath>
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##PrivateKey put: aPath asString.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslPrivateKeyPassword: aString [
	"The password to load the client's privateKey if encrypted.
	 
	 Arguments:
		aString - <String>
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##PrivateKeyPassword put: aString.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslTrustStore: aPath [
	"The file in PEM format containing the public digital certificates trusted by the client.
	 
	 Arguments:
		aPath - <String | CfsPath>
	 Answers:
		<MQTTClientBuilder>"
	
	self sslOptions at: ##TrustStore put: aPath asString.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslVerify: aBoolean [
	"Whether to carry out post-connect checks, including that a certificate
	 matches the given host name.
	 Exists only if struct_version >= 2
	 
	 Arguments:
		aBoolean - <Boolean>
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##SslVerify put: aBoolean.
	^self
]

{ #category : 'Options - SSL' }
MQTTClientBuilder >> sslVersion: anInteger [
	"The SSL/TLS version to use. Specify one of MQTT_SSL_VERSION_DEFAULT (0),
	 MQTT_SSL_VERSION_TLS_1_0 (1), MQTT_SSL_VERSION_TLS_1_1 (2) or MQTT_SSL_VERSION_TLS_1_2 (3).
	 Only used if struct_version is >= 1.
	 
	 Arguments:
		anInteger - <Integer> MQTT_SSL_VERSION_DEFAULT | MQTT_SSL_VERSION_TLS_1_0 |
									   MQTT_SSL_VERSION_TLS_1_1 |  MQTT_SSL_VERSION_TLS_1_2
	 Answers:
		<MQTTClientBuilder>"

	self sslOptions at: ##SslVersion put: anInteger.
	^self
]

{ #category : 'Options - Connection' }
MQTTClientBuilder >> username: aString [
	"MQTT servers that support the MQTT v3.1.1 protocol provide authentication
	 and authorisation by user name and password.
	 This is the user name parameter.
	 
	 Arguments:
		aString - <String>
	 Answers:
		<MQTTClientBuilder> self"

	self connectOptions at: ##Username put: aString.
	^self
]

{ #category : 'Options - Will' }
MQTTClientBuilder >> willMessage: aByteObject [
	"Set the 'Last Will and Testament' payload in string or bytes form.
	 
	 Arguments:
		aByteObject - <String | ByteArray>
	 Answers:
		<MQTTClientBuilder> self"

	self willOptions at: ##Message put: aByteObject.
	^self
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTClientBuilder >> willOptions [
	"Answer the connection will options
	 
	 Answers:
		<KeyedCollection>"

	^willOptions
]

{ #category : 'Options - Will' }
MQTTClientBuilder >> willQos: anInteger [
	"Set the quality of service setting for the LWT message 
	 for the 'Last Will and Testament'

	 Qos constants from MQTTConstants:
		MQTT_QoS0 - Fire and forget - the message may not be delivered
		MQTT_QoS1 - At least once - the message will be delivered, but may be
		    				delivered more than once in some circumstances.
		MQTT_QoS2 - Once and one only - the message will be delivered exactly once.	 
		
	 Arguments:
		anInteger - <Integer>
	 Answers:
		<MQTTClientBuilder> self"

	self willOptions at: ##Qos put: anInteger.
	^self
]

{ #category : 'Options - Will' }
MQTTClientBuilder >> willRetained: aBoolean [
	"Set the retained flag for the 'Last Will and Testament'
	 
	 Arguments:
		aBoolean - <Boolean>
	 Answers:
		<MQTTClientBuilder> self"

	self willOptions at: ##Retained put: aBoolean.
	^self
]

{ #category : 'Options - Will' }
MQTTClientBuilder >> willTopicName: aString [
	"Set the 'Last Will and Testament' topic to which this will
	 be published
	 
	 Arguments:
		aString - <String>
	 Answers:
		<MQTTClientBuilder> self"

	self willOptions at: ##TopicName put: aString.
	^self
]
