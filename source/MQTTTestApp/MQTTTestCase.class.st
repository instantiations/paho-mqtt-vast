Class {
	#name : 'MQTTTestCase',
	#superclass : 'TestCase',
	#pools : [
		'MQTTConstants'
	],
	#category : 'MQTTTestApp'
}

{ #category : 'Testing' }
MQTTTestCase class >> isAbstract [
	"Override to true if a TestCase subclass is Abstract and should not have
	 TestCase instances built from it"

	^self sunitName = #MQTTTestCase
	
]

{ #category : 'Support' }
MQTTTestCase >> convertToUTF8: aString [

	^EsAbstractCodePageConverter current
		convert: aString
		fromCodePage: EsAbstractCodePageConverter currentCodePage
		toCodePage: EsAbstractCodePageConverter current class utf8CodePage
]

{ #category : 'Support' }
MQTTTestCase >> startTracing: aLevel on: aStream [

	| prevTraceHandler |

	prevTraceHandler := nil.
	MQTTClient isTracing
		ifTrue: [
			prevTraceHandler := MQTTClient classPool
				at: 'TraceHandler'
				ifAbsent: [self assert: false].
			MQTTClient stopTracing].
	MQTTClient startTracing: aLevel on: aStream.
	^prevTraceHandler
]

{ #category : 'Support' }
MQTTTestCase >> startTracingOn: aStream [

	^self startTracing: nil on: aStream
]

{ #category : 'Support' }
MQTTTestCase >> stopTracing: prevTracer [

	MQTTClient stopTracing.
	prevTracer notNil ifTrue: [MQTTClient traceHandler: prevTracer].
]

{ #category : 'Startup/Teardown' }
MQTTTestCase >> tearDown [

	MQTTMemoryTracker sunitFreeMemory
]
