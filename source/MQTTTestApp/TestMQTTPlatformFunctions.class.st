Class {
	#name : 'TestMQTTPlatformFunctions',
	#superclass : 'MQTTTestCase',
	#category : 'MQTTTestApp'
}

{ #category : 'Support',
  #vaVisibility : 'private' }
TestMQTTPlatformFunctions >> getPlatformFunctionAddress: aPlatformFunction [

	| address |

	[address := aPlatformFunction address]
		on: Exception
		do: [:ex |
			Transcript
				show: 'MQTT Lib does not contain function: ' , aPlatformFunction name;
				cr.
			^0].
	^address


]

{ #category : 'Testing' }
TestMQTTPlatformFunctions >> testPlatformFunctions [

	| good |

	"Test each function's binding and report to the transcript what is missing"
	MQTTPlatformFunctions do: [:each | self getPlatformFunctionAddress: each].

	"Test for a common error caused by cutting and pasting."
	good := true.
	MQTTPlatformFunctions
		keysAndValuesDo: [:key :value | ((value name , '*') match: key) ifFalse: [good := false]].
	self should: [good]
]
