"
(c) Copyright Instantiations Corporation 2005-2018. All Rights Reserved.

DESCRIPTION:
Contains the lz4 binding interface.

RESPONSIBILITY:
Provides the lz4 interface glue and selection of the appropriate platform
functions to call for a given api.
"
Class {
	#name : 'MQTTLibraryDispatcher',
	#superclass : 'Object',
	#instVars : [
		'callEngine'
	],
	#classVars : [
		'Default',
		'IsLibraryInitialized'
	],
	#pools : [
		'MQTTPlatformFunctions',
		'MQTTConstants'
	],
	#category : 'MQTTApp'
}

{ #category : 'Accessing' }
MQTTLibraryDispatcher class >> async [
	"Answer a new synchronous dispatcher instance 
	 
	 Answers:
		<MQTTCallEngine>"

	^self new: MQTTAsynchronousCallEngine new
]

{ #category : 'Accessing' }
MQTTLibraryDispatcher class >> dedicatedThread [
	"Answer a new static future dispatcher instance 
	 which reserves a dedicated OS thread for calls
	 
	 Answers:
		<MQTTLibraryDispatcher>"

	^self new: MQTTStaticFutureCallEngine new
]

{ #category : 'Accessing' }
MQTTLibraryDispatcher class >> default [
	"Access the Singleton default instance.
	 
	 Answers:
		<MQTTLibraryDispatcher>"

	Default isNil ifTrue: [self default: self new].
	^Default
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher class >> default: aDispatcher [
	"Set the Singleton default instance.
	 
	 Arguments:
		aDispatcher - <MQTTLibraryDispatcher>"

	Default := aDispatcher
]

{ #category : 'Setup',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher class >> initializeLibrary [
	"VA Smalltalk has an SSL/Cryptography Library which will load OpenSSL dlls into memory.
	 Therefore, we don't want MQTT-Paho to ever try to load OpenSSL dlls.
	 On the first dispatcher call, we will request VA to initialize the SSL Libraries"

	IsLibraryInitialized == true ifTrue: [^self].
	MQTTVersionInfo statusCheck
		ifFalse: [MQTTException signal: 'No binding to mqtt-paho exists'].
	MQTTClientInitOptions globalInitialize.
	SciSslOpenSSLLibraryDispatcher initializeLibrary
		ifSslErrorDo: [:err | MQTTException signal: err errorHint].
	IsLibraryInitialized := true
]

{ #category : 'Creation' }
MQTTLibraryDispatcher class >> new [
	"Answer a new instance of a library dispatcher
	 
	 Answers:
		<MQTTLibraryDispatcher> new instance"
	
	^self new: MQTTCallEngine default new
]

{ #category : 'Creation' }
MQTTLibraryDispatcher class >> new: anMQTTCallEngine [
	"Answer a new dispatcher instance that uses the initialized call engine
	 
	 Answers:
		<MQTTCallEngine>"

	self initializeLibrary.
	^self basicNew initialize: anMQTTCallEngine
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher class >> resetLibrary [
	"Reset the class variables to nil"
	
	IsLibraryInitialized := false.
	Default := nil
]

{ #category : 'Accessing' }
MQTTLibraryDispatcher class >> sync [
	"Answer a new synchronous dispatcher instance 
	 
	 Answers:
		<MQTTCallEngine>"

	^self new: MQTTSynchronousCallEngine new
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher class >> unbindSharedLibrary [

	PlatformLibrary removeMappingForLogicalName: 'MQTT_PAHO_LIB'
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callEngine: anMQTTCallEngine [
	"Set the initialized call engine"

	callEngine notNil ifTrue: [callEngine release].
	callEngine := anMQTTCallEngine
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_connectWith: handle with: options [

	^callEngine call: MQTTClient_connect with: handle with: options
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_createWith: handle with: serverURI with: clientId with: persistence_type with: persistence_context [

	^callEngine
		call: MQTTClient_create
		with: handle
		with: serverURI asPSZ
		with: clientId asPSZ
		with: persistence_type
		with: persistence_context
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_createWithOptionsWith: handle with: serverURI with: clientId with: persistence_type with: persistence_context with: options [

	^callEngine
		call: MQTTClient_createWithOptions
		with: handle
		with: serverURI asPSZ
		with: clientId asPSZ
		with: persistence_type
		with: persistence_context
		with: options
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_destroyWith: handlePtr [

	^callEngine call: MQTTClient_destroy with: handlePtr
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_disconnectWith: handle with: timeout [

	^callEngine call: MQTTClient_disconnect with: handle with: timeout
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_freeMessageWith: msg [

	^callEngine call: MQTTClient_freeMessage with: msg
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_freeWith: ptr [

	^callEngine call: MQTTClient_free with: ptr
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_getPendingDeliveryTokensWith: handle with: tokens [

	^callEngine call: MQTTClient_getPendingDeliveryTokens with: handle with: tokens
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_getVersionInfo [

	^callEngine call: MQTTClient_getVersionInfo
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_global_initWith: inits [

	^callEngine call: MQTTClient_global_init with: inits
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_isConnectedWith: handle [

	^callEngine call: MQTTClient_isConnected with: handle
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_publishMessageWith: handle with: topicName with: msg with: dt [

	^callEngine
		call: MQTTClient_publishMessage
		with: handle
		with: topicName asPSZ
		with: msg
		with: (dt ifNil: [0])
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_publishWith: handle with: topicName with: payloadlen with: payload with: qos with: retained with: dt [

	^callEngine
		call: MQTTClient_publish
		with: handle
		with: topicName asPSZ
		with: payloadlen
		with: payload
		with: qos
		with: retained
		with: (dt ifNil: [0])
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_receiveWith: handle with: topicName with: topicLen with: message with: timeout [

	^callEngine call: MQTTClient_receive with: handle with: topicName with: topicLen with: message with: timeout
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_setCallbacksWith: handle with: context with: cl with: ma with: dc [

	^callEngine call: MQTTClient_setCallbacks with: handle with: context with: cl with: ma with: dc
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_setDisconnectedWith: handle with: context with: co [

	^callEngine call: MQTTClient_setDisconnected with: handle with: context with: co
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_setPublishedWith: handle with: context with: co [

	^callEngine call: MQTTClient_setPublished with: handle with: context with: co
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_setTraceCallbackWith: callback [

	^callEngine call: MQTTClient_setTraceCallback with: callback
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_setTraceLevelWith: level [

	^callEngine call: MQTTClient_setTraceLevel with: level
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_strerrorWith: code [

	^callEngine call: MQTTClient_strerror with: code
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_subscribeManyWith: handle with: count with: topic with: qos [

	^callEngine call: MQTTClient_subscribeMany with: handle with: count with: topic asPSZ with: qos
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_subscribeWith: handle with: topic with: qos [

	^callEngine call: MQTTClient_subscribe with: handle with: topic asPSZ with: qos
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_unsubscribeManyWith: handle with: count with: topic [

	^callEngine call: MQTTClient_unsubscribeMany with: handle with: count with: topic asPSZ
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_unsubscribeWith: handle with: topic [

	^callEngine call: MQTTClient_unsubscribe with: handle with: topic asPSZ
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_waitForCompletionWith: handle with: dt with: timeout [

	^callEngine call: MQTTClient_waitForCompletion with: handle with: dt with: timeout
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTClient_yield [

	^callEngine call: MQTTClient_yield
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_addWith: props with: prop [

	^callEngine call: MQTTProperties_add with: props with: prop
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_freeWith: properties [

	^callEngine call: MQTTProperties_free with: properties
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_getNumericValueAtWith: props with: propid with: index [

	^callEngine call: MQTTProperties_getNumericValueAt with: props with: propid with: index
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_getNumericValueWith: props with: propid [

	^callEngine call: MQTTProperties_getNumericValue with: props with: propid
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_getPropertyAtWith: props with: propid with: index [

	^callEngine call: MQTTProperties_getPropertyAt with: props with: propid with: index
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_getPropertyWith: props with: propid [

	^callEngine call: MQTTProperties_getProperty with: props with: propid
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_hasPropertyWith: props with: propid [

	^callEngine call: MQTTProperties_hasProperty with: props with: propid
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperties_propertyCountWith: props with: propid [

	^callEngine call: MQTTProperties_propertyCount with: props with: propid
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTProperty_getTypeWith: value [

	^callEngine call: MQTTProperty_getType with: value
]

{ #category : 'Properties',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTPropertyNameWith: value [

	^callEngine call: MQTTPropertyName with: value
]

{ #category : 'Reason Code',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTReasonCode_toStringWith: value [

	^callEngine call: MQTTReasonCode_toString with: value
]

{ #category : 'Client',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> callMQTTResponse_freeWith: response [

	^callEngine call: MQTTResponse_free with: response
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> initialize: anMQTTCallEngine [
	"Initialize this dispatcher
	 
	 Arguments:
		anMQTTCallEngine - <MQTTCallEngine>"
	
	self callEngine: anMQTTCallEngine
]

{ #category : 'Initialize',
  #vaVisibility : 'private' }
MQTTLibraryDispatcher >> release [
	"Release resources.  Inform call engine"
	
	callEngine release
]
