"
/** The MQTT V5 subscribe options, apart from QoS which existed before V5. */
typedef struct MQTTSubscribe_options
{
	/** The eyecatcher for this structure. Must be MQSO. */
	char struct_id[4];
	/** The version number of this structure.  Must be 0.
	 */
	int struct_version;
	/** To not receive our own publications, set to 1.
	 *  0 is the original MQTT behaviour - all messages matching the subscription are received.
	 */
	unsigned char noLocal;
	/** To keep the retain flag as on the original publish message, set to 1.
	 *  If 0, defaults to the original MQTT behaviour where the retain flag is only set on
	 *  publications sent by a broker if in response to a subscribe request.
	 */
	unsigned char retainAsPublished;
	/** 0 - send retained messages at the time of the subscribe (original MQTT behaviour)
	 *  1 - send retained messages on subscribe only if the subscription is new
	 *  2 - do not send retained messages at all
	 */
	unsigned char retainHandling;
} MQTTSubscribe_options;
"
Class {
	#name : 'MQTTSubscribeOptions',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppOptions'
}

{ #category : 'Accessing' }
MQTTSubscribeOptions class >> id [
	"Answer the struct_id for this structure
	 
	 Answers:
		<String> 4 bytes"
	
	^'MQSO'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTSubscribeOptions class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		noLocal: 0;
		retainAsPublished: 0;
		retainHandling: 0;
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTSubscribeOptions class >> initializeAfterLoad [

	self
		members: #(struct_id struct_version noLocal retainAsPublished retainHandling)
		types: #('int8[4]' int32 uint8 uint8 uint8)
]

{ #category : 'Accessing' }
MQTTSubscribeOptions class >> version [
	
	^0
]

{ #category : 'Accessing' }
MQTTSubscribeOptions >> noLocal [

	^self uint8At: #noLocal
]

{ #category : 'Accessing' }
MQTTSubscribeOptions >> noLocal: anObject [

	self uint8At: #noLocal put: anObject
]

{ #category : 'Accessing' }
MQTTSubscribeOptions >> retainAsPublished [

	^self uint8At: #retainAsPublished
]

{ #category : 'Accessing' }
MQTTSubscribeOptions >> retainAsPublished: anObject [

	self uint8At: #retainAsPublished put: anObject
]

{ #category : 'Accessing' }
MQTTSubscribeOptions >> retainHandling [

	^self uint8At: #retainHandling
]

{ #category : 'Accessing' }
MQTTSubscribeOptions >> retainHandling: anObject [

	self uint8At: #retainHandling put: anObject
]
