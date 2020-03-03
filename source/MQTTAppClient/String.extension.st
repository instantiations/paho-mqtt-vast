Extension {
	#name : 'String'
}

{ #category : '*MQTTAppClient',
 #vaCategories : ['MQTT-Paho'] }
String >> asMQTTMessage [
	"Answer a new mqtt message with myself as the payload
	 
	 Answers:
		<String>"

	^MQTTMessage payload: self
]
