Class {
	#name : 'MQTTVersionInfo',
	#superclass : 'Object',
	#instVars : [
		'dict'
	],
	#category : 'MQTTApp'
}

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTVersionInfo class >> bindingVersion [
	"Answer the current version that the smalltalk binding was coded to
	 
	 Answers:
		<String>"
	
	^'1.3.0'
]

{ #category : 'Accessing' }
MQTTVersionInfo class >> current [
	"Answer the current library version info.
	 This always referes to the native library version
	 retrieved from the shared library.
	 
	 Future: Depending on use, Current could become
	 cached later
	 
	 Answers:
		<MQTTClientVersionInfo>"
	
	^self getLibraryVersionInfo
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTVersionInfo class >> dispatcher [
	"Answer the dispatcher delgate used for platform function call management
	 
	 Answers:
		<MQTTLibraryDispatcher>"
	
	^MQTTLibraryDispatcher default
]

{ #category : 'Factory' }
MQTTVersionInfo class >> getBindingVersionInfo [
	"Answer the smalltalk binding version level info.
	 This just answers the Version level as it would
	 be presented in #getLibraryVersionInfo
	 
	 Answers:
		<MQTTClientVersionInfo>"

	| dict |

	dict :=
		EsOrderedDictionary new
			at: 'Version' put: self bindingVersion;
			at: 'Product name' put: 'Eclipse Paho MQTT Client Library';
			yourself.
	^self new
		dict: dict;
		yourself
]

{ #category : 'Factory' }
MQTTVersionInfo class >> getLibraryVersionInfo [
	"Answer the smalltalk dll version level info.
	 This just answers the Version level as it would
	 be presented in #getLibraryVersionInfo
	 
	 Answers:
		<MQTTClientVersionInfo>"

	| dict nameVals dispatcher nameVal |

	dict := EsOrderedDictionary new.
	dispatcher := self dispatcher.
	nameVals :=
		MQTTNameValue createStaticReferenceTo: self dispatcher callMQTTClient_getVersionInfo.
	nameVals isNull ifTrue: [^nil].
	nameVals dispatcher: dispatcher.
	[(nameVal := nameVals at: 0) isNull or: [nameVal name isEmpty]] whileFalse: [
		dict at: nameVal name put: nameVal value.
		nameVals increment].
	^self new
		dict: dict;
		yourself
]

{ #category : 'Status Check' }
MQTTVersionInfo class >> statusCheck [
	"Answer true if MQTT Paho library is installed and available, false otherwise.
	 
	 Answers:
		<Boolean> true if status check passed, false otherwise"
	
	[MQTTPlatformFunctions::MQTTClient_getVersionInfo address] on: Exception do: [:ex | ^false].
	^true
]

{ #category : 'API' }
MQTTVersionInfo >> asDictionary [
	"Answer a copy of the internal dictionary
	 
	 Answers:
		<EsOrderedDictionary>"

	^self dict copy
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTVersionInfo >> dict [
	"Private: Answer the internal dictionary.
	 Answer an empty dictionary if nil
	 
	 Answers:
		<EsOrderedDictionary>"
	
	^dict ifNil: [EsOrderedDictionary new]
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTVersionInfo >> dict: aDictionary [
	"Private: Set the internal dictionary.
	 
	 Arguments:
		aDictionary - <EsOrderedDictionary>"
	
	dict := aDictionary
]

{ #category : 'Printing',
  #vaVisibility : 'private' }
MQTTVersionInfo >> printOn: aStream [
	"Print any values of the version info
	 after the default printOn behavior
	 
	 Arguments:
		aStream - <Stream>"

	super printOn: aStream.
	aStream cr.
	self asDictionary keysAndValuesDo: [:n :v |
		n printOn: aStream.
		aStream
			space;
			nextPutAll: '->';
			space.
		v printOn: aStream.
		aStream cr]
]

{ #category : 'API' }
MQTTVersionInfo >> productName [
	"Answer the product name
	 
	 Answers:
		<String> product name or nil if not provided"

	^self dict at: 'Product name' ifAbsent: [nil]
]

{ #category : 'API' }
MQTTVersionInfo >> version [
	"Answer the version
	 
	 Answers:
		<String> version or nil if not provided"

	^self dict at: 'Version' ifAbsent: [nil]
]
