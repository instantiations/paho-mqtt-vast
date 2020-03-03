Class {
	#name : 'TestMQTTProperties',
	#superclass : 'MQTTTestCase',
	#pools : [
		'MQTTConstants'
	],
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
TestMQTTProperties >> testAdd [

	| prop props |

	prop := MQTTProperty create.
	props := MQTTProperties create.
	[
		self deny: (props add: prop) description: 'prop must have identifier'.
		prop identifier: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR.
		self assert: (props add: prop)]
			ensure: [props free]
]

{ #category : 'Testing' }
TestMQTTProperties >> testAllocFree [

	100 timesRepeat: [| x |
		x := MQTTProperties create.
		self assert: (MQTTMemoryTracker smartReferenceCount: x) equals: 1.
		x free.
		self assert: (MQTTMemoryTracker smartReferenceCount: x) equals: 0].
]

{ #category : 'Testing' }
TestMQTTProperties >> testGetNumericValue [

	| prop props |

	props := MQTTProperties create.
	prop := MQTTProperty sessionExpiryInterval.
	prop integer2: 256.
	self assert: (props add: prop).
	self assert: (props getNumericValue: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL) = 256.
	props free.

	props := MQTTProperties create.
	prop := MQTTProperty sessionExpiryInterval.
	prop integer4: 65536.
	self assert: (props add: prop).
	self assert: (props getNumericValue: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL) = 65536.
	props free
]

{ #category : 'Testing' }
TestMQTTProperties >> testGetNumericValueAt [

	| prop props |

	props := MQTTProperties create.
	prop := MQTTProperty sessionExpiryInterval.
	prop integer2: 256.
	self assert: prop ownsMemory.
	self assert: (props add: prop).
	self deny: prop ownsMemory.
	self assert: (props getNumericValue: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL at: 0) = 256.

	prop := MQTTProperty sessionExpiryInterval.
	prop integer4: 65536.
	self assert: (props add: prop).
	self assert: (props getNumericValue: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL at: 0) = 256.
	self assert: (props getNumericValue: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL at: 1) = 65536.
	props free.
	self deny: props ownsMemory.
	self assert: props isUndefined
]

{ #category : 'Testing' }
TestMQTTProperties >> testGetProperty [

	| props |

	props := MQTTProperties create.
	[| retrievedProp prop |
		prop := MQTTProperty sessionExpiryInterval.
		prop integer2: 256.
		self assert: (props add: prop).

		retrievedProp := props getProperty: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL.
		self assert: (retrievedProp isKindOf: MQTTProperty).
		self deny: retrievedProp ownsMemory]
			ensure: [props free]
]

{ #category : 'Testing' }
TestMQTTProperties >> testGetPropertyAt [

	| prop props retrievedProp |

	props := MQTTProperties create.
	prop := MQTTProperty sessionExpiryInterval.
	prop integer2: 256.
	self assert: (props add: prop).

	self assert: (props getProperty: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL at: 9) isNil.

	retrievedProp := props getProperty: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL at: 0.
	self assert: (retrievedProp isKindOf: MQTTProperty).
	self deny: retrievedProp ownsMemory.

	prop := MQTTProperty sessionExpiryInterval.
	prop integer4: 65536.
	self assert: (props add: prop).
	retrievedProp := props getProperty: MQTTPROPERTY_CODE_SESSION_EXPIRY_INTERVAL at: 1.
	self assert: (retrievedProp isKindOf: MQTTProperty).
	self deny: retrievedProp ownsMemory.

	props free
]

{ #category : 'Testing' }
TestMQTTProperties >> testHasProperty [

	| prop props |

	props := MQTTProperties create.
	self deny: (props hasProperty: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR).
	prop := MQTTProperty payloadFormatIndicator.
	self assert: (props add: prop).
	self assert: (props hasProperty: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR).
	props free
]

{ #category : 'Testing' }
TestMQTTProperties >> testPropertyCount [

	| prop props |

	props := MQTTProperties create.
	self assert: (props propertyCount: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR) = 0.
	prop := MQTTProperty payloadFormatIndicator.
	self assert: (props add: prop).
	self assert: (props propertyCount: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR) = 1.
	prop := MQTTProperty payloadFormatIndicator.
	self assert: (props add: prop).
	self assert: (props propertyCount: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR) = 2.
	props free
]
