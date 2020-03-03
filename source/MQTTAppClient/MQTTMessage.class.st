Class {
	#name : 'MQTTMessage',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppClient'
}

{ #category : 'Accessing' }
MQTTMessage class >> id [
	"Answer the struct_id for this structure
	 
	 Answers:
		<String> 4 bytes"

	^'MQTM'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTMessage class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		payloadlen: 0;
		payload: nil;
		qos: 0;
		retained: 0;
		dup: 0;
		msgid: 0;
		properties: MQTTProperties new; "copy by value"
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTMessage class >> initializeAfterLoad [

	self
		members: #(struct_id struct_version payloadlen payload qos retained dup msgid properties)
		types: #('int8[4]' int32 int32 pointer int32 int32 int32 int32 MQTTProperties)
]

{ #category : 'Creation' }
MQTTMessage class >> payload: aByteObject [
	"Answer a new message with @aByteObject as the payload
	 
	 Arguments:
		aByteObject - <ByteArray | String>
	 Answers:
		<MQTTClientMessage>"

	^self create
		payload: aByteObject;
		yourself
]

{ #category : 'Creation' }
MQTTMessage class >> payload: aByteObject length: aLength [
	"Answer a new message with @aByteObject as the payload
	 with length @aLength
	 
	 Arguments:
		aByteObject - <ByteArray | String | OSObject>
	 Answers:
		<MQTTClientMessage>"

	^self create
		payload: aByteObject length: aLength;
		yourself
]

{ #category : 'Accessing' }
MQTTMessage class >> version [
	"Answer the identifier for this struct type
	 
	 Answers:
		<Integer>"

	^1
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTMessage >> dup [
	"The dup flag indicates whether or not this message is a duplicate.
	 It is only meaningful when receiving QoS1 messages. When true, the
	 client application should take appropriate action to deal with the
	 duplicate message."
	
	^self int32At: #dup
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTMessage >> dup: anObject [

	self int32At: #dup put: anObject
]

{ #category : 'API' }
MQTTMessage >> isDuplicate [
	"The dup flag indicates whether or not this message is a duplicate.
	 It is only meaningful when receiving QoS1 messages. When true, the
	 client application should take appropriate action to deal with the
	 duplicate message.
	 
	 Answers:
		<Boolean>"
	
	^self dup ~= 0
]

{ #category : 'API' }
MQTTMessage >> isRetained [
	"Answers the retained flag for the 'Last Will and Testament'
	 
	 Answers:
		<Boolean>"
	
	^self retained ~= 0
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> length [
	"Answer the payload length in bytes
	 
	 Answers:
		<Integer>"
	
	^self payloadlen
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> length: aLength [
	"Set the payload length to @aLength
	 
	 Arguments:
		aLength - <Integer>"
	
	self payloadlen: aLength
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> msgid [
	"Answer the message identifier is normally reserved for internal use by the
	 MQTT client and server
	 
	 Answers:
		<Integer>"
	
	^self int32At: #msgid
]

{ #category : 'Accessing' }
MQTTMessage >> msgid: anInteger [
	"Sets the message identifier is normally reserved for internal use by the
	 MQTT client and server
	 
	 Arguments:
		anInteger - <Integer>"
	
	self int32At: #msgid put: anInteger asInteger asInt32
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTMessage >> nativeFree [
	"Free the MQTTCMessage object
	 INTERNAL USE ONLY: External callers need to use #free"

	| msgPtr |

	msgPtr := OSObjectPointer itemType: self class.
	msgPtr at: 0 put: self.
	self dispatcher callMQTTClient_freeMessageWith: msgPtr
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> payload [
	"Answer the raw os-memory payload
	 
	 Answers:
		<OSVoid>"
	
	^OSVoid address: (self pointerAt: #payload)
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> payload: anObject [
	"Answer a new message with @aByteObject as the payload
	 
	 Arguments:
		aByteObject - <ByteArray | String>
	 Answers:
		<MQTTClientMessage>"

	^self payload: anObject length: (anObject isNil ifTrue: [0] ifFalse: [anObject size])
]

{ #category : 'API' }
MQTTMessage >> payload: aByteObject length: aLength [
	"Answer a new message with @aByteObject as the payload
	 with length @aLength
	 
	 Arguments:
		aByteObject - <ByteArray | String | OSObject>
	 Answers:
		<MQTTClientMessage>"

	| osBytes |

	(aByteObject isNil or: [aByteObject isOSObject])
		ifTrue: [osBytes := aByteObject]
		ifFalse: [osBytes := self copyToOSMemory: aByteObject length: aLength].
	self
		pointerAt: #payload put: osBytes;
		payloadlen: (aByteObject isNil ifTrue: [0] ifFalse: [aLength])
]

{ #category : 'API' }
MQTTMessage >> payloadBytes [
	"Answer the payload as a ByteArray
	 
	 Answers:
		<ByteArray>"
	
	^self payload memcpyFrom: 0 to: self length - 1
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTMessage >> payloadlen [

	^self int32At: #payloadlen
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTMessage >> payloadlen: anObject [

	self int32At: #payloadlen put: anObject asInteger asInt32
]

{ #category : 'API' }
MQTTMessage >> payloadString [
	"Answer the payload as a String
	 
	 Answers:
		<String>"
	
	^self payload memcpyStringFrom: 0 to: self length - 1
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> properties [
	"Answers the MQTT V5 properties associated with the message.
	 
	 Answers:
		<MQTTProperties>"
	
	^(self pointerAt: #properties type: MQTTProperties)
		dispatcher: self dispatcher;
		ownsMemory: false;
		yourself
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTMessage >> properties: anMQTTProperties [
	"Answers the MQTT V5 properties associated with the message.
	 
	 Arguments:
		anMQTTProperties - <MQTTProperties>"
	
	self structAt: #properties put: anMQTTProperties
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','API'] }
MQTTMessage >> qos [
	"Answer the quality of service (QoS) assigned to the message.
	 @see setter for more details
	  
	  Answers:
		<Integer>"
	
	^self int32At: #qos
]

{ #category : 'Accessing' }
MQTTMessage >> qos: anInteger [
	"Set the quality of service (QoS) assigned to the message.
		There are three levels of QoS (from MQTTConstants):
			MQTT_QoS0 - Fire and forget - the message may not be delivered
			MQTT_QoS1 - At least once - the message will be delivered, but may be
								delivered more than once in some circumstances.</DD>
			MQTT_QoS2 - Once and one only - the message will be delivered exactly once.
	  
	  Arguments:
		anInteger - <Integer>"
	
	self int32At: #qos put: anInteger
]

{ #category : 'Accessing' }
MQTTMessage >> retained [
	"Answers the retained flag for the 'Last Will and Testament'
	 
	 Answers:
		<Integer>"
	
	^self int32At: #retained
]

{ #category : 'Accessing' }
MQTTMessage >> retained: anObject [
	"Set the retained flag for the 'Last Will and Testament'
	 
	 Arguments:
		anObject - <Object>"
	
	self int32At: #retained put: anObject asInteger asInt32
]
