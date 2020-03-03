"
/**
 * MQTTClient_willOptions defines the MQTT ""Last Will and Testament"" (LWT) settings for
 * the client. In the event that a client unexpectedly loses its connection to
 * the server, the server publishes the LWT message to the LWT topic on
 * behalf of the client. This allows other clients (subscribed to the LWT topic)
 * to be made aware that the client has disconnected. To enable the LWT
 * function for a specific client, a valid pointer to an MQTTClient_willOptions
 * structure is passed in the MQTTClient_connectOptions structure used in the
 * MQTTClient_connect() call that connects the client to the server. The pointer
 * to MQTTClient_willOptions can be set to NULL if the LWT function is not
 * required.
 */
typedef struct
{
	/** The eyecatcher for this structure.  must be MQTW. */
	char struct_id[4];
	/** The version number of this structure.  Must be 0 or 1
		   0 means there is no binary payload option
	 */
	int struct_version;
	/** The LWT topic to which the LWT message will be published. */
	const char* topicName;
	/** The LWT payload in string form. */
	const char* message;
	/**
	 * The retained flag for the LWT message (see MQTTClient_message.retained).
	 */
	int retained;
	/**
	 * The quality of service setting for the LWT message (see
	 * MQTTClient_message.qos and @ref qos).
	 */
	int qos;
  /** The LWT payload in binary form. This is only checked and used if the message option is NULL */
	struct
	{
		int len;            /**< binary payload length */
		const void* data;  /**< binary payload data */
	} payload;
} MQTTClient_willOptions;
"
Class {
	#name : 'MQTTClientWillOptions',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppOptions'
}

{ #category : 'Accessing' }
MQTTClientWillOptions class >> id [
	"Answer the struct_id for this structure
	 
	 Answers:
		<String> 4 bytes"
	
	^'MQTW'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTClientWillOptions class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		topicName: nil;
		message: nil;
		retained: 0;
		qos: 0;
		payloadLen: 0;
		payloadData: nil;
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientWillOptions class >> initializeAfterLoad [

	self
		members: #(struct_id struct_version topicName message retained qos (len data))
		types: #('int8[4]' int32 pointer pointer int32 int32 ((int32 pointer)))
]

{ #category : 'Accessing' }
MQTTClientWillOptions class >> version [
	"Answer the identifier for this struct type
	 
	 Answers:
		<Integer>"

	^1
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> message [

	^self stringAt: #message
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> message: anObject [

	self stringAt: #message put: anObject
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTClientWillOptions >> nativeFree [
	"Free the MQTTClientWillOptions struct
	 INTERNAL USE ONLY: External callers need to use #free"

	| obj |

	obj := self osStringAt: #topicName.
	obj notNull
		ifTrue: [
			self topicName: nil.
			obj free].

	obj := self osStringAt: #message.
	obj notNull
		ifTrue: [
			self message: nil.
			obj free].

	obj := self payloadData.
	obj notNull
		ifTrue: [
			self payloadData: nil.
			obj free].

	self basicFree
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> payloadData [

	^OSVoid address: (self pointerAt: #data)
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> payloadData: anObject [

	self pointerAt: #data put: (anObject ifNotNil: [anObject copyToOSMemory])
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> payloadLen [

	^self int32At: #len
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> payloadLen: anObject [

	self int32At: #len put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> qos [

	^self int32At: #qos
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> qos: anObject [

	self int32At: #qos put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> retained [

	^self int32At: #retained
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> retained: anObject [

	self int32At: #retained put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> topicName [

	^self stringAt: #topicName
]

{ #category : 'Accessing' }
MQTTClientWillOptions >> topicName: aString [

	self stringAt: #topicName put: aString
]
