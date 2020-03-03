"
/**
  * MQTTClient_libraryInfo is used to store details relating to the currently used
  * library such as the version in use, the time it was built and relevant openSSL
  * options.
  * There is one static instance of this struct in MQTTClient.c
  */

typedef struct
{
	const char* name;
	const char* value;
} MQTTClient_nameValue;
"
Class {
	#name : 'MQTTNameValue',
	#superclass : 'MQTTStructure',
	#category : 'MQTTAppClient'
}

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTNameValue class >> initializeAfterLoad [

	self members: #(name value) types: #(pointer pointer)
]

{ #category : 'Accessing' }
MQTTNameValue >> name [

	^self stringAt: #name
]

{ #category : 'Accessing' }
MQTTNameValue >> name: anObject [

	self stringAt: #name put: anObject
]

{ #category : 'Accessing' }
MQTTNameValue >> value [

	^self stringAt: #value
]

{ #category : 'Accessing' }
MQTTNameValue >> value: anObject [

	self stringAt: #value put: anObject
]
