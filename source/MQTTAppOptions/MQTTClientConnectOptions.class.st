"
/**
 * MQTTClient_connectOptions defines several settings that control the way the
 * client connects to an MQTT server.
 *
 * <b>Note:</b> Default values are not defined for members of
 * MQTTClient_connectOptions so it is good practice to specify all settings.
 * If the MQTTClient_connectOptions structure is defined as an automatic
 * variable, all members are set to random values and thus must be set by the
 * client application. If the MQTTClient_connectOptions structure is defined
 * as a static variable, initialization (in compliant compilers) sets all
 * values to 0 (NULL for pointers). A #keepAliveInterval setting of 0 prevents
 * correct operation of the client and so you <b>must</b> at least set a value
 * for #keepAliveInterval.
 */
typedef struct
{
	/** The eyecatcher for this structure.  must be MQTC. */
	char struct_id[4];
	/** The version number of this structure.  Must be 0, 1, 2, 3, 4, 5 or 6.
	 * 0 signifies no SSL options and no serverURIs
	 * 1 signifies no serverURIs
	 * 2 signifies no MQTTVersion
	 * 3 signifies no returned values
	 * 4 signifies no binary password option
	 * 5 signifies no maxInflightMessages and cleanstart
	 */
	int struct_version;
	/** The ""keep alive"" interval, measured in seconds, defines the maximum time
   * that should pass without communication between the client and the server
   * The client will ensure that at least one message travels across the
   * network within each keep alive period.  In the absence of a data-related
	 * message during the time period, the client sends a very small MQTT
   * ""ping"" message, which the server will acknowledge. The keep alive
   * interval enables the client to detect when the server is no longer
	 * available without having to wait for the long TCP/IP timeout.
	 */
	int keepAliveInterval;
	/**
   * This is a boolean value. The cleansession setting controls the behaviour
   * of both the client and the server at connection and disconnection time.
   * The client and server both maintain session state information. This
   * information is used to ensure ""at least once"" and ""exactly once""
   * delivery, and ""exactly once"" receipt of messages. Session state also
   * includes subscriptions created by an MQTT client. You can choose to
   * maintain or discard state information between sessions.
   *
   * When cleansession is true, the state information is discarded at
   * connect and disconnect. Setting cleansession to false keeps the state
   * information. When you connect an MQTT client application with
   * MQTTClient_connect(), the client identifies the connection using the
   * client identifier and the address of the server. The server checks
   * whether session information for this client
   * has been saved from a previous connection to the server. If a previous
   * session still exists, and cleansession=true, then the previous session
   * information at the client and server is cleared. If cleansession=false,
   * the previous session is resumed. If no previous session exists, a new
   * session is started.
	 */
	int cleansession;
	/**
   * This is a boolean value that controls how many messages can be in-flight
   * simultaneously. Setting <i>reliable</i> to true means that a published
   * message must be completed (acknowledgements received) before another
   * can be sent. Attempts to publish additional messages receive an
   * ::MQTTCLIENT_MAX_MESSAGES_INFLIGHT return code. Setting this flag to
   * false allows up to 10 messages to be in-flight. This can increase
   * overall throughput in some circumstances.
	 */
	int reliable;
	/**
   * This is a pointer to an MQTTClient_willOptions structure. If your
   * application does not make use of the Last Will and Testament feature,
   * set this pointer to NULL.
   */
	MQTTClient_willOptions* will;
	/**
   * MQTT servers that support the MQTT v3.1.1 protocol provide authentication
   * and authorisation by user name and password. This is the user name
   * parameter.
   */
	const char* username;
	/**
   * MQTT servers that support the MQTT v3.1.1 protocol provide authentication
   * and authorisation by user name and password. This is the password
   * parameter.
   */
	const char* password;
	/**
   * The time interval in seconds to allow a connect to complete.
   */
	int connectTimeout;
	/**
	 * The time interval in seconds after which unacknowledged publish requests are
	 * retried during a TCP session.  With MQTT 3.1.1 and later, retries are
	 * not required except on reconnect.  0 turns off in-session retries, and is the
	 * recommended setting.  Adding retries to an already overloaded network only
	 * exacerbates the problem.
	 */
	int retryInterval;
	/**
   * This is a pointer to an MQTTClient_SSLOptions structure. If your
   * application does not make use of SSL, set this pointer to NULL.
   */
	MQTTClient_SSLOptions* ssl;
	/**
	 * The number of entries in the optional serverURIs array. Defaults to 0.
	 */
	int serverURIcount;
	/**
   * An optional array of null-terminated strings specifying the servers to
   * which the client will connect. Each string takes the form <i>protocol://host:port</i>.
   * <i>protocol</i> must be <i>tcp</i> or <i>ssl</i>. For <i>host</i>, you can
   * specify either an IP address or a host name. For instance, to connect to
   * a server running on the local machines with the default MQTT port, specify
   * <i>tcp://localhost:1883</i>.
   * If this list is empty (the default), the server URI specified on MQTTClient_create()
   * is used.
   */
	char* const* serverURIs;
	/**
	 * Sets the version of MQTT to be used on the connect.
	 * MQTTVERSION_DEFAULT (0) = default: start with 3.1.1, and if that fails, fall back to 3.1
	 * MQTTVERSION_3_1 (3) = only try version 3.1
	 * MQTTVERSION_3_1_1 (4) = only try version 3.1.1
	 * MQTTVERSION_5 (5) = only try version 5.0
	 */
	int MQTTVersion;
	/**
	 * Returned from the connect when the MQTT version used to connect is 3.1.1
	 */
	struct
	{
		const char* serverURI;     /**< the serverURI connected to */
		int MQTTVersion;     /**< the MQTT version used to connect with */
		int sessionPresent;  /**< if the MQTT version is 3.1.1, the value of sessionPresent returned in the connack */
	} returned;
	/**
   * Optional binary password.  Only checked and used if the password option is NULL
   */
	struct
	{
		int len;           /**< binary password length */
		const void* data;  /**< binary password data */
	} binarypwd;
	/**
	 * The maximum number of messages in flight
	 */
	int maxInflightMessages;
	/*
	 * MQTT V5 clean start flag.  Only clears state at the beginning of the session.
	 */
	int cleanstart;
} MQTTClient_connectOptions;
"
Class {
	#name : 'MQTTClientConnectOptions',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppOptions'
}

{ #category : 'Accessing' }
MQTTClientConnectOptions class >> id [
	"Answer the identifier for this struct type
	 
	 Answers:
		<String>"
	
	^'MQTC'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTClientConnectOptions class >> initialize: anInstance version: aVersion [
	"Initialize the instance to default values defined in MQTTClient.h"

	^(super initialize: anInstance version: aVersion)
		keepAliveInterval: 60;
		cleansession: true;
		reliable: true;
		will: nil;
		username: nil;
		password: nil;
		connectTimeout: 30;
		retryInterval: 0;
		ssl: nil;
		serverURIcount: 0;
		serverURIs: nil;
		MQTTVersion: aVersion;
		returnedServerURI: nil;
		returnedMQTTVersion: 0;
		returnedSessionPresent: 0;
		binarypwdLen: 0;
		binarypwdData: nil;
		maxInflightMessages: -1;
		cleanstart: (aVersion = MQTTVERSION_5 ifTrue: [1] ifFalse: [0])
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientConnectOptions class >> initializeAfterLoad [

	self
		members: #(
			struct_id struct_version keepAliveInterval cleansession reliable will username password
			connectTimeout retryInterval ssl serverURIcount serverURIs MQTTVersion
			(serverURI MQTTVersionFor311 sessionPresent) (len data) maxInflightMessages cleanstart)
		types: #(
			'char8[4]' int32 int32 int32 int32 pointer pointer pointer int32 int32 pointer int32
			pointer int32 ((pointer int32 int32)) ((int32 pointer)) int32 int32)
]

{ #category : 'Accessing' }
MQTTClientConnectOptions class >> version [
	"Answer the structure version
	 
	 Answers:
		<Integer>"
	
	^6
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> binarypwdData [

	^OSVoid address: (self pointerAt: #data)
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> binarypwdData: anObject [

	self pointerAt: #data put: (anObject ifNotNil: [anObject copyToOSMemory])
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> binarypwdLen [

	^self int32At: #len
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> binarypwdLen: anObject [

	self int32At: #len put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> cleansession [

	^self int32At: #cleansession
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> cleansession: anObject [

	self int32At: #cleansession put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> cleanstart [

	^self int32At: #cleanstart
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> cleanstart: aBoolean [

	self int32At: #cleanstart put: aBoolean asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> connectTimeout [

	^self int32At: #connectTimeout
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> connectTimeout: anObject [

	self int32At: #connectTimeout put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> keepAliveInterval [

	^self int32At: #keepAliveInterval
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> keepAliveInterval: anInteger [

	self int32At: #keepAliveInterval put: anInteger asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> maxInflightMessages [

	^self int32At: #maxInflightMessages
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> maxInflightMessages: anObject [

	self int32At: #maxInflightMessages put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> MQTTVersion [

	^self int32At: #MQTTVersion
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> MQTTVersion: anInteger [

	self int32At: #MQTTVersion put: anInteger asInteger asInt32
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTClientConnectOptions >> nativeFree [
	"Free the MQTTClientConnectOptions object
	 This will also free the will and ssl options
	 INTERNAL USE ONLY: External callers need to use #free"
	
	| obj |

	obj := self will.
	obj notNull
		ifTrue: [
			self will: nil.
			obj free].

	obj := self osStringAt: #username.
	obj notNull
		ifTrue: [
			self username: nil.
			obj free].

	obj := self osStringAt: #password.
	obj notNull
		ifTrue: [
			self password: nil.
			obj free].

	obj := self ssl.
	obj notNull
		ifTrue: [
			self ssl: nil.
			obj free].

	obj := self serverURIs.
	obj notNull
		ifTrue: [
			self serverURIs: nil.
			self freeOSArray: obj length: self serverURIcount].

	obj := self binarypwdData.
	obj notNull
		ifTrue: [
			self binarypwdData: nil.
			obj free].
			
	self basicFree
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> password [

	^self stringAt: #password
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> password: anObject [

	self stringAt: #password put: anObject
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> reliable [

	^self int32At: #reliable
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> reliable: anObject [

	self int32At: #reliable put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> retryInterval [

	^self int32At: #retryInterval
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> retryInterval: anObject [

	self int32At: #retryInterval put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> returnedMQTTVersion [

	^self int32At: #MQTTVersionFor311
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> returnedMQTTVersion: anObject [

	self int32At: #MQTTVersionFor311 put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> returnedServerURI [

	^self stringAt: #serverURI
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> returnedServerURI: aString [

	self stringAt: #serverURI put: aString
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> returnedSessionPresent [

	^self int32At: #sessionPresent
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> returnedSessionPresent: anObject [

	self int32At: #sessionPresent put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> serverURIcount [

	^self int32At: #serverURIcount
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> serverURIcount: anObject [

	self int32At: #serverURIcount put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> serverURIs [

	^OSObjectPointer address: (self pointerAt: #serverURIs) itemType: OSStringZ
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> serverURIs: anObject [

	self pointerAt: #serverURIs put: anObject
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> ssl [

	^(MQTTClientSslOptions createStaticReferenceTo: (self pointerAt: #ssl))
		dispatcher: self dispatcher;
		yourself
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> ssl: anSslOptions [

	self pointerAt: #ssl put: anSslOptions
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> username [

	^self stringAt: #username
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> username: anObject [

	self stringAt: #username put: anObject
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> will [

	^(MQTTClientWillOptions createStaticReferenceTo: (self pointerAt: #will))
		dispatcher: self dispatcher;
		yourself
]

{ #category : 'Accessing' }
MQTTClientConnectOptions >> will: aWillOptions [

	self pointerAt: #will put: aWillOptions
]
