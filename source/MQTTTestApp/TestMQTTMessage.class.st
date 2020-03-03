Class {
	#name : 'TestMQTTMessage',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
TestMQTTMessage >> testPayloadBytes [

	| m payload |

	payload := 'Sample payload' asByteArray.
	m := MQTTMessage payload: payload.
	[
		self
			assert: (m payload castTo: OSStringZ) asString equals: payload asString;
			assert: m length equals: payload size;
			assert: m payloadString equals: payload asString;
			assert: m payloadBytes equals: payload]
				ensure: [m free]
]

{ #category : 'Testing' }
TestMQTTMessage >> testPayloadString [

	| m payload |

	payload := 'Sample payload'.
	m := MQTTMessage payload: payload.
	[
		self
			assert: (m payload castTo: OSStringZ) asString equals: payload;
			assert: m length equals: payload size;
			assert: m payloadString equals: payload;
			assert: m payloadBytes equals: payload asByteArray]
				ensure: [m free]
]

{ #category : 'Testing' }
TestMQTTMessage >> testProperties [

	| m |

	m := MQTTMessage payload: 'Sample payload'.
	[ | p |
		p := m properties.
		self assert: (p isKindOf: MQTTProperties).
		self assert: m dispatcher = p dispatcher.
		self deny: p ownsMemory description: 'Message owns memory and will free it']
			ensure: [m free]
]
