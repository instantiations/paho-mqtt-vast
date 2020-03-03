"
/**
 * MQTT version 5 property list
 */
typedef struct MQTTProperties
{
  int count;     /**< number of property entries in the array */
  int max_count; /**< max number of properties that the currently allocated array can store */
  int length;    /**< mbi: byte length of all properties */
  MQTTProperty *array;  /**< array of properties */
} MQTTProperties;
"
Class {
	#name : 'MQTTProperties',
	#superclass : 'MQTTStructure',
	#category : 'MQTTAppProperties'
}

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTProperties class >> initializeAfterLoad [
	"Define layout of the MQTTProperties structure"

	self members: #(count max_count length array) types: #(int32 int32 int32 pointer)
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTProperties class >> new [

	"Internal: This is to be used internally for message creation
	 
	 Answers:
		<MQTTProperties>"
	
	^self initialize: super new version: MQTTVERSION_DEFAULT
]

{ #category : 'API' }
MQTTProperties >> add: aProperty [
	"Add a property pointer to the property array.  There is no memory allocation.
	 @aProperty must have an identifier
	 
	 Note: If the property is added to the list, then memory ownership is transferred to
	 the properties list
	 
	 Arguments:
		aProperty - <MQTTProperty> property to add to the list
	 Answers:
		<Boolean> true if added, false if not"

	| res |

	res := self dispatcher callMQTTProperties_addWith: self with: aProperty.
	res == 0
		ifTrue: [
			self memoryTracker
				removeSmartReference: aProperty;
				removeAndFreeWeakReferencesTo: aProperty.
			aProperty basicOwnsMemory: false].
	^res == 0
]

{ #category : 'Accessing' }
MQTTProperties >> array [

	^self pointerAt: #array type: MQTTProperty
]

{ #category : 'Accessing' }
MQTTProperties >> array: anObject [

	self pointerAt: #array put: anObject
]

{ #category : 'Accessing' }
MQTTProperties >> count [

	^self int32At: #count
]

{ #category : 'Accessing' }
MQTTProperties >> count: anObject [

	self int32At: #count put: anObject
]

{ #category : 'API' }
MQTTProperties >> getNumericValue: propertyId [
	"Answers the integer value of a specific property.
	 The property given must be a numeric type.
	 
	 Arguments:
		propertyId - <Integer> property id to check for
	 Answers:
		<Integer> value of the property
		<UndefinedObject> nil on failure"

	| res |

	res := self dispatcher callMQTTProperties_getNumericValueWith: self with: propertyId.
	^res = -9999999 ifTrue: [nil] ifFalse: [res]
]

{ #category : 'API' }
MQTTProperties >> getNumericValue: propertyId at: index [
	"Answers the integer value of a specific property when it's not the only instance.
	 The property given must be a numeric type.
	 
	 Arguments:
		propertyId - <Integer> property id to check for
		index - <Integer> the instance number, starting at 0.
	 Answers:
		<Integer> value of the property
		<UndefinedObject> nil on failure"

	| res |

	res := self dispatcher
		callMQTTProperties_getNumericValueAtWith: self
		with: propertyId
		with: index.
	^res = -9999999 ifTrue: [nil] ifFalse: [res]
]

{ #category : 'API' }
MQTTProperties >> getProperty: propertyId [
	"Answers the property for a specific property.
	 
	 Arguments:
		propertyId - <Integer> property id to check for
	 Answers:
		<MQTTProperty> if found
		<UndefinedObject> nil if not found"

	| prop |

	prop := self dispatcher callMQTTProperties_getPropertyWith: self with: propertyId.
	prop := MQTTProperty createStaticReferenceTo: prop.
	^prop isNull
		ifTrue: [nil]
		ifFalse: [
			prop
				dispatcher: self dispatcher;
				yourself]
]

{ #category : 'API' }
MQTTProperties >> getProperty: propertyId at: index [
	"Answers the property for a specific property when it's not the only instance.
	 
	 Arguments:
		propertyId - <Integer> property id to check for
		index - <Integer>  The instance number, starting at 0.
	 Answers:
		<MQTTProperty> if found
		<UndefinedObject> nil if not found"

	| prop |

	prop := self dispatcher callMQTTProperties_getPropertyAtWith: self with: propertyId with: index.
	prop := MQTTProperty createStaticReferenceTo: prop.
	^prop isNull
		ifTrue: [nil]
		ifFalse: [
			prop
				dispatcher: self dispatcher;
				yourself]
]

{ #category : 'API' }
MQTTProperties >> hasProperty: propertyId [
	"Checks if this property list contains a specific property
	 identified by @propertyId
	 
	 Arguments:
		propertyId - <Integer> property id to check for
	 Answers:
		<Boolean> true if added, false if not"

	^(self dispatcher callMQTTProperties_hasPropertyWith: self with: propertyId) == 1
]

{ #category : 'Accessing' }
MQTTProperties >> length [

	^self int32At: #length
]

{ #category : 'Accessing' }
MQTTProperties >> length: anObject [

	self int32At: #length put: anObject
]

{ #category : 'Accessing' }
MQTTProperties >> max_count [

	^self int32At: #max_count
]

{ #category : 'Accessing' }
MQTTProperties >> max_count: anObject [

	self int32At: #max_count put: anObject
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTProperties >> nativeFree [
	"Free the MQTTProperties object
	 The MQTTProperties_free will free the internals and 0 out
	 the memory of the properties, but not actually free it.
	 So additionally, we need to call native free
	 INTERNAL USE ONLY: External callers need to use #free"
	
	self dispatcher callMQTTProperties_freeWith: self.
	self basicFree
]

{ #category : 'API' }
MQTTProperties >> propertyCount: propertyId [
	"Answers  the number of instances of a property id. Most properties can exist only once.
	 User properties and subscription ids can exist more than once.
	 
	 Arguments:
		propertyId - <Integer> property id to check for
	 Answers:
		<Integer> number of times found, can be 0"

	^self dispatcher callMQTTProperties_propertyCountWith: self with: propertyId
]
