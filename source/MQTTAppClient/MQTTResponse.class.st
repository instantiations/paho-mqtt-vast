Class {
	#name : 'MQTTResponse',
	#superclass : 'MQTTStructure',
	#category : 'MQTTAppClient'
}

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTResponse class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		version: 1;
		reasonCode: MQTTREASONCODE_SUCCESS;
		reasonCodeCount: 0;
		reasonCodes: nil;
		properties: nil;
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTResponse class >> initializeAfterLoad [

	self
		members: #(version reasonCode reasonCodeCount reasonCodes properties)
		types: #(int32 int32 int32 int32 pointer)
]

{ #category : 'Accessing' }
MQTTResponse >> properties [

	^self pointerAt: #properties type: MQTTProperties
]

{ #category : 'Accessing' }
MQTTResponse >> properties: aMQTTProperties [

	self pointerAt: #properties put: aMQTTProperties
]

{ #category : 'Accessing' }
MQTTResponse >> reasonCode [

	^self int32At: #reasonCode
]

{ #category : 'Accessing' }
MQTTResponse >> reasonCode: anObject [

	self int32At: #reasonCode put: anObject
]

{ #category : 'Accessing' }
MQTTResponse >> reasonCodeCount [

	^self int32At: #reasonCodeCount
]

{ #category : 'Accessing' }
MQTTResponse >> reasonCodeCount: anObject [

	self int32At: #reasonCodeCount put: anObject
]

{ #category : 'Accessing' }
MQTTResponse >> reasonCodes [

	^self int32At: #reasonCodes
]

{ #category : 'Accessing' }
MQTTResponse >> reasonCodes: anObject [

	self int32At: #reasonCodes put: anObject
]

{ #category : 'Accessing' }
MQTTResponse >> version [

	^self int32At: #version
]

{ #category : 'Accessing' }
MQTTResponse >> version: anObject [

	self int32At: #version put: anObject
]
