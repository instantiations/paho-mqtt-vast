Class {
	#name : 'TestMQTTProperty',
	#superclass : 'MQTTTestCase',
	#pools : [
		'MQTTConstants'
	],
	#category : 'MQTTTestApp'
}

{ #category : 'Support',
  #vaVisibility : 'private' }
TestMQTTProperty >> camelCaseToSeparateWords: aString [

	| stream words |

	words := WriteStream on: String new.
	stream := ReadStream on: aString.
	[stream atEnd] whileFalse: [
		words nextPut: stream next asLowercase.
		(stream peek notNil and: [stream peek isUppercase]) ifTrue: [words space]].
	^words contents
]

{ #category : 'Testing' }
TestMQTTProperty >> testFactoryMethods [

	(MQTTProperty class methodNamesCategorizedIn: #('Factory') all: true) do: [:selName | | cm
		  propCodeSel propCodeComment propCodePool |
		cm := MQTTProperty class methodDictionary at: selName asSymbol.
		propCodeSel := cm selector.
		propCodeComment := self camelCaseToSeparateWords: propCodeSel.
		propCodePool :=
			'MQTTPROPERTY_CODE_' ,
				((propCodeComment subStrings collect: [:e | e asUppercase]) joinUsing: '_').
		self assert:
			(('*' , $' asString , propCodeComment , $' asString , '*') match: cm sourceString).
		self assert: (('*' , propCodePool , '*') match: cm sourceString)]
]

{ #category : 'Testing' }
TestMQTTProperty >> testGetType [

	self
		assert: (MQTTProperty getType: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR)
			equals: MQTTPROPERTY_TYPE_BYTE;
		assert: (MQTTProperty getType: MQTTPROPERTY_CODE_CONTENT_TYPE)
			equals: MQTTPROPERTY_TYPE_UTF_8_ENCODED_STRING.
	self assert: (MQTTProperty getType: -1) equals: -1
]

{ #category : 'Testing' }
TestMQTTProperty >> testNameFor [

	self
		assert: (MQTTProperty nameFor: MQTTPROPERTY_CODE_PAYLOAD_FORMAT_INDICATOR)
		equals: 'PAYLOAD_FORMAT_INDICATOR'.
	self assert: (MQTTProperty nameFor: -1) isNil
]
