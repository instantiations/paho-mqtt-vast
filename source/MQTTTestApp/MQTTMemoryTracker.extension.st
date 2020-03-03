Extension {
	#name : 'MQTTMemoryTracker'
}

{ #category : '*MQTTTestApp',
 #vaCategories : ['SUnit'] }
MQTTMemoryTracker class >> sunitFreeMemory [
	
	| refs |
	
	refs := SmartReferences asArray.
	refs do: [:ref | self finalizeOSObject: ref].
	self expungeReferences
]
