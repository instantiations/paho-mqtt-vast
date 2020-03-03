"
From MQTTProperties.h

/**
 * The data for a length delimited string
 */
typedef struct
{
	int len; /**< the length of the string */
	char* data; /**< pointer to the string data */
} MQTTLenString;
"
Class {
	#name : 'MQTTLenString',
	#superclass : 'MQTTStructure',
	#category : 'MQTTAppProperties'
}

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTLenString class >> initializeAfterLoad [
	"Define layout of the MQTTLenString structure"

	self members: #(len data) types: #(int32 pointer)
]

{ #category : 'Accessing' }
MQTTLenString >> data [

	^self pointerAt: #data
]

{ #category : 'Accessing' }
MQTTLenString >> data: anObject [

	self pointerAt: #data put: anObject
]

{ #category : 'Accessing' }
MQTTLenString >> len [

	^self int32At: #len
]

{ #category : 'Accessing' }
MQTTLenString >> len: anObject [

	self int32At: #len put: anObject
]
