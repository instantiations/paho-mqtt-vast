"
typedef struct
{
	/** The eyecatcher for this structure.  must be MQCO. */
	char struct_id[4];
	/** The version number of this structure.  Must be 0 */
	int struct_version;
	/** Whether the MQTT version is 3.1, 3.1.1, or 5.  To use V5, this must be set.
	 *  MQTT V5 has to be chosen here, because during the create call the message persistence
	 *  is initialized, and we want to know whether the format of any persisted messages
	 *  is appropriate for the MQTT version we are going to connect with.  Selecting 3.1 or
	 *  3.1.1 and attempting to read 5.0 persisted messages will result in an error on create.  */
	int MQTTVersion;
} MQTTClient_createOptions;
"
Class {
	#name : 'MQTTClientCreateOptions',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppOptions'
}

{ #category : 'Accessing' }
MQTTClientCreateOptions class >> id [
	"Answer the identifier for this struct type
	 
	 Answers:
		<String>"

	^'MQCO'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTClientCreateOptions class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		MQTTVersion: MQTTVERSION_DEFAULT;
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientCreateOptions class >> initializeAfterLoad [

	self members: #(struct_id struct_version MQTTVersion) types: #('char8[4]' int32 int32)
]

{ #category : 'Accessing' }
MQTTClientCreateOptions class >> version [
	"Answer the identifier for this struct type
	 
	 Answers:
		<Integer>"

	^0
]

{ #category : 'Accessing' }
MQTTClientCreateOptions >> MQTTVersion [

	^self int32At: #MQTTVersion
]

{ #category : 'Accessing' }
MQTTClientCreateOptions >> MQTTVersion: anInteger [

	self int32At: #MQTTVersion put: anInteger asInteger asInt32
]
