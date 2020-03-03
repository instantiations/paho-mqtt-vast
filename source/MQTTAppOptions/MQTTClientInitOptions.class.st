Class {
	#name : 'MQTTClientInitOptions',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppOptions'
}

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientInitOptions class >> globalInitialize [
	"Private: This is meant to be called by the application startUp method"

	| default |

	MQTTVersionInfo statusCheck ifFalse: [^self].
	default := self create: (MQTTLibraryDispatcher basicNew initialize: MQTTCallEngine default new).
	[
		default do_openssl_init: false.
		default dispatcher callMQTTClient_global_initWith: default]
			ensure: [default free]
]

{ #category : 'Accessing' }
MQTTClientInitOptions class >> id [
	"Answer the struct_id for this structure
	 
	 Answers:
		<String> 4 bytes"
	
	^'MQTG'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTClientInitOptions class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		do_openssl_init: false;
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientInitOptions class >> initializeAfterLoad [

	self members: #(struct_id struct_version do_openssl_init) types: #('int8[4]' int32 int32)
]

{ #category : 'Accessing' }
MQTTClientInitOptions class >> version [
	"Answer the identifier for this struct type
	 
	 Answers:
		<Integer>"

	^0
]

{ #category : 'Accessing' }
MQTTClientInitOptions >> do_openssl_init [

	^self int32At: #do_openssl_init
]

{ #category : 'Accessing' }
MQTTClientInitOptions >> do_openssl_init: anObject [

	self int32At: #do_openssl_init put: anObject
]
