Extension {
	#name : 'Integer'
}

{ #category : '*MQTTAppClient',
 #vaCategories : ['MQTT-Paho'] }
Integer >> asMQTTReasonCodeString [
	"Answers a printable string description of an MQTT V5 reason code.
	 
	 Answers:
		<String> - printable string description of the input reason code.
		<UndefinedObject> if code not found"

	| osStr |

	osStr := OSStringZ address: (MQTTLibraryDispatcher default callMQTTReasonCode_toStringWith: self).
	^osStr isNull ifTrue: [nil] ifFalse: [osStr asString]
]
