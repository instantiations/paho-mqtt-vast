"
/**
 * Structure to hold an MQTT version 5 property of any type
 */
typedef struct
{
  enum MQTTPropertyCodes identifier; /**<  The MQTT V5 property id. A multi-byte integer. */
  /** The value of the property, as a union of the different possible types. */
  union {
    char byte;       /**< holds the value of a byte property type */
    short integer2;  /**< holds the value of a 2 byte integer property type */
    int integer4;    /**< holds the value of a 4 byte integer property type */
    struct {
      MQTTLenString data;  /**< The value of a string property, or the name of a user property. */
      MQTTLenString value; /**< The value of a user property. */
    };
  } value;
} MQTTProperty;
"
Class {
	#name : 'MQTTProperty',
	#superclass : 'MQTTStructure',
	#category : 'MQTTAppProperties'
}

{ #category : 'Factory' }
MQTTProperty class >> assignedClientIdentifier [
	"Answer a new initialized instance of this
	 'assigned client identifier' property

	 Answers:
		<MQTTProperty>"
	
	"Constant is misspelled in MQProperties.h..should be MQTTPROPERTY_CODE_ASSIGNED_CLIENT_IDENTIFIER"
	^self createWith: MQTTPROPERTY_CODE_ASSIGNED_CLIENT_IDENTIFER
]

{ #category : 'Factory' }
MQTTProperty class >> authenticationData [
	"Answer a new initialized instance of this
	 'authentication data' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_AUTHENTICATION_DATA
]

{ #category : 'Factory' }
MQTTProperty class >> authenticationMethod [
	"Answer a new initialized instance of this
	 'authentication method' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_AUTHENTICATION_METHOD
]

{ #category : 'Factory' }
MQTTProperty class >> contentType [
	"Answer a new initialized instance of this
	 'content type' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_CONTENT_TYPE
]

{ #category : 'Factory' }
MQTTProperty class >> correlationData [
	"Answer a new initialized instance of this
	 'correlation data' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_CORRELATION_DATA
]

{ #category : 'Creation' }
MQTTProperty class >> createWith: propertyCode [
	"Answer a os-allocated initialized instance of this property
	 with @propertyCode
	 
	 Arguments:
		propertyCode - <Integer> identifier
	 Answers:
		<MQTTProperty>"

	^self create
		identifier: propertyCode;
		yourself
]

{ #category : 'API' }
MQTTProperty class >> getType: propertyCode [
	"Answers the MQTT V5 type code of an MQTT V5 property.
	 @see MQTTConstants::MQTTPROPERTY_CODE*
	 @see MQTTConstatns::MQTTPROPERTY_TYPE*
	 
	 Arugments:
		propertyCode - <Integer> an MQTT V5 property code.
	 Answers:
		<Integer> MQTT V5 type code of the input property. -1 if the code was not found"

	^MQTTLibraryDispatcher default callMQTTProperty_getTypeWith: propertyCode
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTProperty class >> initializeAfterLoad [
	"Define layout of the MQTTProperty structure"

	self
		members: #(identifier (byte integer2 integer4 (data value)))
		types: #(int32 (int8 int16 int32 ((MQTTLenString MQTTLenString))))
]

{ #category : 'Factory' }
MQTTProperty class >> maximumPacketSize [
	"Answer a new initialized instance of this
	 'maximum packet size' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_MAXIMUM_PACKET_SIZE
]

{ #category : 'Factory' }
MQTTProperty class >> maximumQos [
	"Answer a new initialized instance of this
	 'maximum qos' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_MAXIMUM_QOS
]

{ #category : 'Factory' }
MQTTProperty class >> messageExpiryInterval [
	"Answer a new initialized instance of this
	 'message expiry interval' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_MESSAGE_EXPIRY_INTERVAL
]

{ #category : 'API' }
MQTTProperty class >> nameFor: propertyCode [
	"Answers a printable string description of an MQTT V5 property code.
	 @see MQTTConstants::MQTTPROPERTY_CODE*
	 
	 Arugments:
		propertyCode - <Integer> an MQTT V5 property code.
	 Answers:
		<String> Printable string description of the input property code
		<UndefinedObject> nil if invalid code"

	| str |

	str := OSStringZ address: (MQTTLibraryDispatcher default callMQTTPropertyNameWith: propertyCode).
	^str isNull ifTrue: [nil] ifFalse: [str asString]
]

{ #category : 'Factory' }
MQTTProperty class >> payloadFormatIndicator [
	"Answer a new initialized instance of this
	 'payload format indicator' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR
]

{ #category : 'Factory' }
MQTTProperty class >> reasonString [
	"Answer a new initialized instance of this
	 'reason string' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_REASON_STRING
]

{ #category : 'Factory' }
MQTTProperty class >> receiveMaximum [
	"Answer a new initialized instance of this
	 'receive maximum' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_RECEIVE_MAXIMUM
]

{ #category : 'Factory' }
MQTTProperty class >> requestProblemInformation [
	"Answer a new initialized instance of this
	 'request problem information' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_REQUEST_PROBLEM_INFORMATION
]

{ #category : 'Factory' }
MQTTProperty class >> requestResponseInformation [
	"Answer a new initialized instance of this
	 'request response information' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_REQUEST_RESPONSE_INFORMATION
]

{ #category : 'Factory' }
MQTTProperty class >> responseInformation [
	"Answer a new initialized instance of this
	 'response information' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_RESPONSE_INFORMATION
]

{ #category : 'Factory' }
MQTTProperty class >> responseTopic [
	"Answer a new initialized instance of this
	 'response topic' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_RESPONSE_TOPIC
]

{ #category : 'Factory' }
MQTTProperty class >> retainAvailable [
	"Answer a new initialized instance of this
	 'retain available' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_RETAIN_AVAILABLE
]

{ #category : 'Factory' }
MQTTProperty class >> serverKeepAlive [
	"Answer a new initialized instance of this
	 'server keep alive' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_SERVER_KEEP_ALIVE
]

{ #category : 'Factory' }
MQTTProperty class >> serverReference [
	"Answer a new initialized instance of this
	 'server reference' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_SERVER_REFERENCE
]

{ #category : 'Factory' }
MQTTProperty class >> sessionExpiryInterval [
	"Answer a new initialized instance of this
	 'session expiry interval' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL
]

{ #category : 'Factory' }
MQTTProperty class >> sharedSubscriptionAvailable [
	"Answer a new initialized instance of this
	 'shared subscription available' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_SHARED_SUBSCRIPTION_AVAILABLE
]

{ #category : 'Factory' }
MQTTProperty class >> subscriptionIdentifier [
	"Answer a new initialized instance of this
	 'subscription identifier' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIER
]

{ #category : 'Factory' }
MQTTProperty class >> subscriptionIdentifiersAvailable [
	"Answer a new initialized instance of this
	 'subscription identifiers available' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_SUBSCRIPTION_IDENTIFIERS_AVAILABLE
]

{ #category : 'Factory' }
MQTTProperty class >> topicAlias [
	"Answer a new initialized instance of this
	 'topic alias' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_TOPIC_ALIAS
]

{ #category : 'Factory' }
MQTTProperty class >> topicAliasMaximum [
	"Answer a new initialized instance of this
	 'topic alias maximum' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_TOPIC_ALIAS_MAXIMUM
]

{ #category : 'Factory' }
MQTTProperty class >> userProperty [
	"Answer a new initialized instance of this
	 'user property' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_USER_PROPERTY
]

{ #category : 'Factory' }
MQTTProperty class >> wildcardSubscriptionAvailable [
	"Answer a new initialized instance of this
	 'wildcard subscription available' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_WILDCARD_SUBSCRIPTION_AVAILABLE
]

{ #category : 'Factory' }
MQTTProperty class >> willDelayInterval [
	"Answer a new initialized instance of this
	 'will delay interval' property

	 Answers:
		<MQTTProperty>"

	^self createWith: MQTTPROPERTY_CODE_WILL_DELAY_INTERVAL
]

{ #category : 'Accessing' }
MQTTProperty >> byte [

	^self int8At: #byte
]

{ #category : 'Accessing' }
MQTTProperty >> byte: anObject [

	self int8At: #byte put: anObject
]

{ #category : 'Accessing' }
MQTTProperty >> data [

	^self structAt: #data type: MQTTLenString
]

{ #category : 'Accessing' }
MQTTProperty >> data: anObject [

	self structAt: #data put: anObject
]

{ #category : 'Accessing' }
MQTTProperty >> identifier [

	^self int32At: #identifier
]

{ #category : 'Accessing' }
MQTTProperty >> identifier: anObject [

	self int32At: #identifier put: anObject
]

{ #category : 'Accessing' }
MQTTProperty >> integer2 [

	^self int16At: #integer2
]

{ #category : 'Accessing' }
MQTTProperty >> integer2: anObject [

	self int16At: #integer2 put: anObject asInt16
]

{ #category : 'Accessing' }
MQTTProperty >> integer4 [

	^self int32At: #integer4
]

{ #category : 'Accessing' }
MQTTProperty >> integer4: anObject [

	self int32At: #integer4 put: anObject asInt32
]

{ #category : 'Accessing' }
MQTTProperty >> value [

	^self structAt: #value type: MQTTLenString
]

{ #category : 'Accessing' }
MQTTProperty >> value: anObject [

	self structAt: #value put: anObject
]
