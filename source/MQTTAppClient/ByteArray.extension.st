Extension {
	#name : 'ByteArray'
}

{ #category : '*MQTTAppClient',
 #vaCategories : ['MQTT-Paho'] }
ByteArray >> asMQTTMessage [
	"Answer a new mqtt message with myself as the payload
	 
	 Answers:
		<ByteArray>"

	^MQTTMessage payload: self
]
