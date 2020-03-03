Class {
	#name : 'TestMQTTVersionInfo',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
TestMQTTVersionInfo >> testCurrent [

	self
		assert: MQTTVersionInfo current asDictionary
		equals: MQTTVersionInfo getLibraryVersionInfo asDictionary
]

{ #category : 'Testing' }
TestMQTTVersionInfo >> testEmptyLibraryVersionInfo [

	| info |

	info := MQTTVersionInfo new.
	self assert: info version isNil.
	self assert: info productName isNil.
	self assert: (info asDictionary isKindOf: EsOrderedDictionary).
	self assert: info asDictionary isEmpty.
	self shouldnt: [info printString] raise: Exception
]

{ #category : 'Testing' }
TestMQTTVersionInfo >> testGetBindingVersionInfo [

	| info |

	info := MQTTVersionInfo getBindingVersionInfo.
	self assert: info class == MQTTVersionInfo.
	self assert: info version equals: MQTTVersionInfo bindingVersion.
	self assert: info productName equals: 'Eclipse Paho MQTT Client Library'.
	self assert: (info asDictionary isKindOf: EsOrderedDictionary).
	self
		assert: (info asDictionary at: 'Version' ifAbsent: [self assert: false])
		equals: info version.
	self
		assert: (info asDictionary at: 'Product name' ifAbsent: [self assert: false])
		equals: info productName
]

{ #category : 'Testing' }
TestMQTTVersionInfo >> testGetLibraryVersionInfo [

	| info |

	info := MQTTVersionInfo getLibraryVersionInfo.
	self assert: info class == MQTTVersionInfo.
	self assert: info version notNil.
	self assert: info productName notNil.
	self assert: (info asDictionary isKindOf: EsOrderedDictionary).
	self
		assert: (info asDictionary at: 'Version' ifAbsent: [self assert: false])
		equals: info version.
	self
		assert: (info asDictionary at: 'Product name' ifAbsent: [self assert: false])
		equals: info productName
]
