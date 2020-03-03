Class {
	#name : 'TestMQTTLibraryDispatcher',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Not categorized' }
TestMQTTLibraryDispatcher >> testDispatchConsistency [

	| dispatchMethods |

	dispatchMethods := OrderedCollection new.
	MQTTLibraryDispatcher methodsDo: [:m |
		('call*' match: m selector)
			ifTrue: [
				(#('callEngine' 'callEngine:') includes: m selector asString)
					ifFalse: [dispatchMethods add: m]]].
	dispatchMethods do: [:m | | funcName numArgs callPattern |
		funcName :=
			m selector
				copyFrom: 5
				to: (m selector indexOfSubCollection: 'With:' ifAbsent: [m selector size + 1]) - 1.
		numArgs := m selector occurrencesOf: $:.
		callPattern := String new writeStream.
		callPattern nextPutAll: 'callEngine*call:*'.
		numArgs timesRepeat: [callPattern nextPutAll: 'with:*'].
		self assert: (('*' , callPattern contents) match: m sourceString).
		self assert: (m referencesLiteral: funcName asSymbol)]
]
