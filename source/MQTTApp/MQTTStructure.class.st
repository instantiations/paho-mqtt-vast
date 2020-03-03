Class {
	#name : 'MQTTStructure',
	#superclass : 'OSStructure',
	#instVars : [
		'dispatcher',
		'ownsMemory'
	],
	#pools : [
		'MQTTConstants'
	],
	#category : 'MQTTApp'
}

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> buildInstanceFromAddress: anAddress takeOwnership: takeOwnership [
	"Build a new instance of this mqtt structure from the provided
	 address.
	 
	 Note: Every time a new instance is created, there is a check to see if the expunged references
	 count exceeds the max size.  If so, then the refs are freed and removed
	 
	 Argument:
		anAddress - <Integer>
		takeOwnership -  takeOwnership - <Boolean> true if instance will own native memory, false otherwise
	 Answers:
		<MQTTStructure subclass> - Concrete Mqtt Structure"

	^(self address: anAddress)
		ownsMemory: takeOwnership;
		yourself
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> buildInstanceFromStaticAddress: anAddress [
	"PRIVATE: Do not use this directly.  This is an internal creational method that
	 constructs the new instance for static memory referencing.
	 
	 Note: Every time a new instance is created, there is a check to see if the expunged references
	 count exceeds the max size.  If so, then the refs are freed and removed
	 
	 Arguments:
		anAddress - <Integer> address
		takeOwnership -  takeOwnership - <Boolean> true if instance will own native memory, false otherwise
	 Answers:	
		<MQTTStructure subclass> - Concrete Mqtt Structure"

	^(self address: anAddress)
		basicOwnsMemory: false;
		yourself
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> calloc [
	"Protect against non-memory tracked leaks"
	
	self shouldNotImplement
]

{ #category : 'Creation' }
MQTTStructure class >> create [

	^self create: MQTTLibraryDispatcher default
]

{ #category : 'Creation' }
MQTTStructure class >> create: dispatcher [

	^self create: dispatcher version: MQTTVERSION_DEFAULT
]

{ #category : 'Creation' }
MQTTStructure class >> create: dispatcher version: version [

	^self
		initialize: (
			(self createSmartReferenceTo: (self privateCalloc: fixedSize reftype: EsReftypePointer))
				dispatcher: dispatcher;
				yourself)
		version: version
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> createSmartReferenceTo: anAddress [
	"Create a new smart reference to the provided address @anAddress.
	 This new instance WILL own the memory at the address and is expected
	 to free the native memory either when #free is explicitly called OR when
	 finalization is performed by the garbage collector.
	 
	 Additionally, multiple calls to free (while should be avoided) will have no
	 ill-effect since cleanup after the first call to free will prevent any additional
	 calls to free from attempting to free native memory.

	 POST-CONDITION:  New structure instance si with memoryOwner = true.
	 si will exist in the FinalizeSet.
	 
	 Argument:
		anAddress - <Integer> address
	 Answers:
		<MQTTStructure subclass> - Concrete Structure"

	^self buildInstanceFromAddress: anAddress takeOwnership: true
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> createStaticReferenceTo: anAddress [
	"Create a new static reference to the provided address @anAddressOrErrorObject.
	 This new instance WILL NOT own the memory at the address.  While not required
	 except for intercepting cleanup hooks, callers may safley call #free on static refs
	 with no-ill effect.  Since they are not memory owners (i.e. smart references) then
	 they will never attempt to free native memory.  In fact, static references don't have
	 memory owners in smalltalk since it is memory that only belongs to MQTT.
	 
	 Static References are used to refer to static memory in MQTT. 
	 These could be represented just as safley as 'weak references' but they would unnecessarily 
	 clutter up the Reference Table.  Since static references don't have a memory owner in 
	 Smalltalk (not associated with a smart reference), then there is no need
	 to keep track of them explicitly

	 POST-CONDITION:  New structure instance si with memoryOwner = false.
	 si will NOT exist in the References Table.
	 
	 Argument:
		anAddress - <Integer> address
	 Answers:
		<MQTTStructure subclass> - Concrete Mqtt Structure"

	^self buildInstanceFromStaticAddress: anAddress
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> createWeakReferenceTo: anAddress [
	"Create a new weak reference to the provided address @anAddress.
	 This new instance WILL NOT own the memory at the address.  While not required
	 except for intercepting cleanup hooks, callers may safley call #free on weak refs
	 with no-ill effect.  Since they are not memory owners (i.e. smart references) then
	 they will never attempt to free native memory.
	 
	 Weak references are still tracked by the memory tracking functionality of the structure.
	 This is for the purposes of updating all 'weak references' to 'smart references' that
	 are freed.  In this case, the weak references should not be allowed to refer to the (now freed)
	 memory address and possibly perform operations on garbage or re-allocated memory.  All
	 weak references will run the non-native cleanup hooks found in #free and the address will
	 be nild.  Any attempt to perform an operation with a dangling weak reference will result
	 in a smalltalk exception.   While still undesireable...at least native memory is untouched.
	 
	 Weak refs are often created for temporary means...they can be discarded and you don't
	 really need to worry about keeping track of them and calling free.

	 POST-CONDITION:  New structure instance si with memoryOwner = false.
	 si will exist in the References Table.
	 
	 Argument:
		anAddress - <Integer> address
	 Answers:
		<MQTTStructure subclass> - Concrete mqtt Structure"

	^self buildInstanceFromAddress: anAddress takeOwnership: false
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTStructure class >> initialize: anInstance version: aVersion [
	"Initialize the instance this struct to default values
	 
	 Arguments:
		anInstance - <MQTTTaggedStructure>
		aVersion - <Integer>
	 Answers:
		<MQTTTaggedStructure> anInstance"

	^anInstance
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure class >> memoryTracker [
	"Answer the mqtt native memory tracker
	 
	 Answers:	
		<MQTTMemoryTracker>"
	
	^MQTTMemoryTracker
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTStructure class >> resetForImageStartup [
	"Image is starting up and classes may need to
	 clean out state"
]

{ #category : 'Memory Management' }
MQTTStructure class >> smartReferenceCount: anMQTTStructure [
	"Answer the number of smart refs to the address
	 in @anMQTTStructure.  Multiple smart refs to the same address
	 can exist due to reference counting APIS in MQTT
	 
	 This is essentially equivalent to asking what the MQTT reference
	 count is for an 'allocated' memory address.  For a static reference
	 this would answer 0 since there isn't an associated smalltalk smart
	 reference (ownsMemory = true).
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<Integer> - number of smart references"

	^self memoryTracker smartReferenceCount: anMQTTStructure
]

{ #category : 'Memory Management' }
MQTTStructure class >> smartReferenceFor: anMQTTStructure [
	"Answer the FIRST <MQTTStructure> smart ref that
	 is associated with the address
	 from @anMQTTStructure (which may be any kind of reference)

	 Based on how OSPtr determine equality, 2 different
	 instances with same address will be equal but because
	 the finalize set is identity based...we must iterate
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<MQTTStructure> - FIRST smart reference whose address = @anMQTTStructure address
		<UndefinedObject> - no match"
	
	^self memoryTracker smartReferenceFor: anMQTTStructure
]

{ #category : 'Memory Management' }
MQTTStructure class >> smartReferencesFor: anMQTTStructure [
	"Answer a <SequenceableCollection> of
	 <MQTTStructure> smart reference associated
	 with the address referred to by @anMQTTStructure.
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<SequenceableCollection of <MQTTStructure>>
			smart references (ownsMemory = true) with address = @anMQTTStructure address"

	^self memoryTracker smartReferencesFor: anMQTTStructure 
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTStructure class >> startUp [
	"Handle image startup procedures"

	self withAllSubclassesDo: [:structClass |
		structClass resetForImageStartup.
		structClass basicAllInstances do: [:structInst | structInst resetForImageStartup]]
]

{ #category : 'Memory Management' }
MQTTStructure class >> weakReferenceCount: anMQTTStructure [
	"Answer the number of weak refs to the address
	 in @anMQTTStructure
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<Integer> - number of weak references"

	^self memoryTracker weakReferenceCount: anMQTTStructure
]

{ #category : 'Memory Management' }
MQTTStructure class >> weakReferencesFor: anMQTTStructure [
	"Answer a <SequenceableCollection> of
	 <MQTTStructure> weak reference associated
	 with the address referred to by @anMQTTStructure.
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<SequenceableCollection of <MQTTStructure>>
			weak references (ownsMemory = false) with address = @anMQTTStructure address"

	^self memoryTracker weakReferencesFor: anMQTTStructure
]

{ #category : 'Memory Management' }
MQTTStructure >> asWeakReference [
	"Create a new reference with 'weak reference'
	 semantics.  See the class side comments in
	 #createWeakReferenceTo: for details.
	 
	 Note: Undefined references will simply anwer
	 themeselves

	 Answers:
		<MQTTStructure subclass> - Concrete Mqtt Structure"

	self isUndefined ifTrue: [^self].
	^self class createWeakReferenceTo: self address
]

{ #category : 'Memory Management' }
MQTTStructure >> basicFree [
	"Free the storage for the receiver.

	 This message is invalid for immediate (non-pointer) objects
	 and for objects whose data element is stored in Smalltalk memory.
	"
	<primitive: VMprOSObjectFree>
	^self primitiveFailed
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','Memory Management'],
  #vaVisibility : 'private' }
MQTTStructure >> basicOwnsMemory: aBoolean [
	"PRIVATE: Set aBoolean which describes if this instance accepts ownership
	 of the native memory.  This bypasses memory tracking procedures from
	 #ownsMemory and is meant for create static references
	 
	 This is used in isolated places within the framework to handle special
	 freeing situations
	 
	 Arguments:
		<Boolean> true if this instances accepts ownership, false otherwise"

	ownsMemory := false
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure >> cleanUp [
	"This is a hook for subclasses to cleanup non-native types of data.
	 
	 This hook is called under the following conditions:
	 STATIC REF: Only when a caller explicitly calls free...these refs do
	 not use finalizers so the GC will never call it.
	 
	 WEAK REF: When the caller explicilty calls free or during a GC
	 finalization.  At this point it has been removed from memory tracking
	 but has not been marked undefined yet.  Native memory from its
	 associated smart refs have not been freed yet and the ref still has 
	 a valid memory address.
	 
	 SMART REF: When the caller explicity calls free or during a GC
	 finalization.  For smart refs (who free native memory), the native
	 memory will be freed AFTER this call and the ref still has a valid
	 memory address."
]

{ #category : 'Utility',
  #vaVisibility : 'private' }
MQTTStructure >> copyToOSMemory: aByteObject length: aLength [
	"Copy the contents of @aByteObject up to @aLength
	 to os memory
	 
	 Arguments:
		aByteObject - <ByteArray | String>
		aLength - <Integer>
	 Answers:
		<OSObject>"

	^aByteObject isString
		ifTrue: [
			aByteObject
				memcpyFrom: 0
				to: aLength - 1
				into: (OSStringZ calloc: aLength + 1) "+1 for Null-Term"
				startingAt: 0]
		ifFalse: [
			aByteObject memcpyFrom: 0 to: aLength - 1 into: (OSUInt8 calloc: aLength) startingAt: 0]
]

{ #category : 'Memory Management' }
MQTTStructure >> destroy [
	"@see MQTTStructure>>free"

	self free
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTStructure >> dispatcher [
	"Answer the library dispatcher
	 
	 Answers:
		<MQTTLibraryDispatcher>"
	
	^dispatcher
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTStructure >> dispatcher: aLibraryDispatcher [
	"Set the library dispatcher
	 
	 Arguments:
		aLibraryDispatcher - <MQTTLibraryDispatcher>"
	
	dispatcher := aLibraryDispatcher
]

{ #category : 'Memory Management' }
MQTTStructure >> free [
	"If this instance owns the memory, then remove it from the finalization list.
	 Always mark this instance as undefined.
	 Free the native memory associated with this Mqtt structure ONLY IF this instance owns the memory.
	 This could be called either programmatically or during finalization from a GC.
	 
	 For unowned memory references, we remove them from the reference tracking list
	 
	 POSTCONDITION:  This instance is undefined and ownsMemory is false"

	ownsMemory
		ifTrue: [
			self memoryTracker removeSmartReference: self.
			self isUndefined
				ifFalse: [
					self cleanUp.
					self memoryTracker removeAndFreeWeakReferencesTo: self.
					self isNull ifFalse: [self nativeFree]].
			ownsMemory := false]
		ifFalse: [
			self memoryTracker removeWeakReference: self.
			self cleanUp].
	self makeUndefined
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure >> freeOSArray: anOSObject length: length [
	"Free the incoming array OSObject.  Typically an OSObjectPointer or
	 array OSPtr"
	
	anOSObject indirectionLevel > 1 ifTrue: [0 to: length - 1 do: [:idx | (anOSObject at: idx) free]].
	anOSObject free
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure >> freeRef [
	"A special version of free that is meant only to be called because
	 a memory owner has been freed and all references (non-memory owners)
	 are also being freed"

	self cleanUp.
	self makeUndefined
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure >> makeVirtual [
	
	reference := nil.
	ownsMemory := false.
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure >> memoryTracker [
	"Answer the mqtt native memory tracker
	 
	 Answers:	
		<MQTTMemoryTracker>"
	
	^self class memoryTracker
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTStructure >> nativeFree [
	"Free native memory associated with this structure, if required.
	 You should not attempt to free any static memory so some subclasses
	 may take no action.  However, because it's such an important concept,
	 subclasses are required to implement this, even if its a no-op
	 
	 IMPORTANT: This is only meant to be called internally by
	 MQTTStructure>>free."
	
	super free
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTStructure >> osStringAt: anIntegerOrSymbol [
	"Answer the null terminated string buffer
	 as an OSObject
	 
	 Answers:
		<OSStringZ>"
	
	^OSStringZ address: (self pointerAt: anIntegerOrSymbol)
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','Memory Management'],
  #vaVisibility : 'private' }
MQTTStructure >> ownsMemory [
	"PRIVATE: Answer a aBoolean which describes if this instance has ownership
	 of the native memory.  Instances that do not own the memory should not
	 be able to free the memory.
	 
	 NOTE: Instances that do not accept ownership can still safley call free.  However,
	 internally, these instances will know not to call the native free function
	 
	 Answers:
		<Boolean> true if this instances has ownership, false otherwise"
	
	^ownsMemory
]

{ #category : 'Accessing',
 #vaCategories : ['Accessing','Memory Management'],
  #vaVisibility : 'private' }
MQTTStructure >> ownsMemory: aBoolean [
	"PRIVATE: Set aBoolean which describes if this instance accepts ownership
	 of the native memory
	 Instances that do not own the memory (weak) should not
	 be able to free the memory.  
	 
	 Arguments:
		<Boolean> true if this instance is a smart ref, false for weak ref"

	ownsMemory isNil
		ifFalse: [
			^MQTTException signal: 'ownsMemory: accessor can only be called once during creation'].

	(ownsMemory := aBoolean)
		ifTrue: [self memoryTracker trackSmartReference: self]
		ifFalse: [self memoryTracker trackWeakReference: self]
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTStructure >> resetForImageStartup [
	"Image is starting up and existing instances that were saved
	 with an image need to make themeselves undefined and
	 clear out native reference state"
	
	dispatcher := nil.
	ownsMemory := false.   "Don't use accessor"
	self makeUndefined.
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTStructure >> stringAt: anIntegerOrSymbol [
	"Answer the null terminated string buffer
	 as a Smalltalk string
	 
	 Answers:
		<String>"
	
	^(self osStringAt: anIntegerOrSymbol) asString
]

{ #category : 'Accessing',
  #vaVisibility : 'private' }
MQTTStructure >> stringAt: anIntegerOrSymbol put: aString [
	"Copy the smalltalk string into the field
	 
	 Arguments:
		<Integer | Symbol> - field id or index
		<String> nil | String | OSObject"

	| val |

	aString isOSObject ifTrue: [val := aString].
	aString isNil ifTrue: [val := 0].
	aString isString ifTrue: [val := aString copyToOSMemory].
	self pointerAt: anIntegerOrSymbol put: val
]
