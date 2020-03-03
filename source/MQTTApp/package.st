Package {
	#name : 'MQTTApp',
	#vaPrerequisites : ['SciSslSocketInterface'],
	#vaSubApplications : [
	{
		#condition : 'true',
		#subapps : [
			'MQTTAppClient',
			'MQTTAppOptions',
			'MQTTAppPersistence',
			'MQTTAppProperties'
		]
	}
]
}
