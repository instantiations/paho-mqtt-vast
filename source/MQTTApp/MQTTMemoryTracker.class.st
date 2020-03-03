Class {
	#name : 'MQTTMemoryTracker',
	#superclass : 'Object',
	#classVars : [
		'ExpungeMaxSize',
		'ExpungeableMonitor',
		'SmartReferences',
		'WeakReferences',
		'ExpungeableReferences'
	],
	#category : 'MQTTApp'
}

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> defaultExpungeMaxSize [
	"Answer the default maximum size of the expungeableReferences collection.
	 The is the largest amount this collection can grow before the
	 references are freed"
	
	^32
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> expungeMaxSize [
	"Answer the maximum size of the expungeableReferences collection.
	 The is the largest amount this collection can grow before the
	 references are freed.
	 
	 Default Value: 32"

	ExpungeMaxSize isNil ifTrue: [ExpungeMaxSize := self defaultExpungeMaxSize].
	^ExpungeMaxSize
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> expungeMaxSize: anInteger [
	"Set the maximum size of the expungeableReferences collection.
	 The is the largest amount this collection can grow before the
	 references are freed"
	
	ExpungeMaxSize := anInteger
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> expungeReferences [
	"Clear out references that have been expunged and perform free.  
	 Expunged references are those that have been let go by the finalizer.  
	 Due to unresolved issues on *nix , we must perform actual native free 
	 outside of finalization otherwise a deadlock occurs when the vm sleeps"

	[| refs |
		refs := ExpungeableReferences.
		ExpungeableReferences := OrderedCollection new: self expungeMaxSize.
		refs do: [:ref | self finalizeOSObject: ref]]
			critical
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> expungeReferencesIfRequired [
	"If the Expungeable ref collection size exceeds the max size,
	 then expunge them"
	
	ExpungeableReferences size > self expungeMaxSize
		ifTrue: [self expungeReferences]
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> finalizeAction [
	"Platforms using pthread locking (i.e. *nix platforms) can deadlockd
	 during nativeFree within finalization process when the vm sleeps.
	 Possible similar issues on Windows 'may' exist, so for saftey all
	 platforms will schedule freeing for later outside of finalization"
	
	^#scheduleExpunge:
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> finalizeOSObject: anOSObject [
	"FINALIZATION HOOK"

	(anOSObject isNil or: [anOSObject isUndefined]) ifFalse: [anOSObject free]
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> initializeExpungeableReferenceTracking [
	"Initializes the reference collection for expunged refs that
	 have been let go by the finalizer and are ready to be freed.
	 Every allocation of an MQTTStructure will perform a quick check
	 to see if this colletion should be expunged (based on a max size).
	 The first reference to be expunged by the GC finalizer will initialize
	 a monitor to run in the background in case allocation stops
	 and there are refs still in the collection. @see #scheduleExpunge:"

	self stopExpungeableMonitor.
	ExpungeableReferences := OrderedCollection new: self expungeMaxSize
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> initializeMemoryTracking [
	"Initialize the various components of the memory management feature
	 that is provided to all subclasses."

	self
		initializeSmartReferenceTracking;
		initializeWeakReferenceTracking;
		initializeExpungeableReferenceTracking
]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> initializeSmartReferenceTracking [
	"Initialize the Smart reference finalize set which is used to track all MQTT structures.
	 If not explicitly freed by the user, MQTT structures are scheduled to be freed by the
	 finalizer"

	SmartReferences :=
		EsWeakIdentitySet new
			owner: self;
			finalizeAction: self finalizeAction;
			yourself


]

{ #category : 'Initialization',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> initializeWeakReferenceTracking [
	"Initializes the reference tracking table used for tracking
	 objects that don't ownMemory.  If the memoryOwner is
	 freed, this is the table used to make sure references become
	 undefined and can't make additional calls to freed memory"
	
	WeakReferences := LookupTable new
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> removeAndFreeWeakReferencesTo: anMQTTStructure [
	"Free any references that alias the memory owner @anMQTTStructure.
	 These references will not free the native memory, but it will give
	 them an opportunity to run normal shutdown hooks.
	 
	 It also keeps references from making calls to garbage memory
	 because the memory owner was freed.
	 
	 PRECONDITION: anMQTTStructure isUndefined = false
	 
	 Arguments:
		anMQTTStructure - <MQTTStructure>"

	| refs |

	[
		anMQTTStructure ownsMemory ifFalse: [^self].
		(WeakReferences includesKey: anMQTTStructure address) ifFalse: [^self].
		(self smartReferenceCount: anMQTTStructure) > 0 ifTrue: [^self].
		refs := WeakReferences removeKey: anMQTTStructure address ifAbsent: [^self]]
			critical.
	refs do: [:ref | ref freeRef]
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> removeSmartReference: anMQTTStructure [
	"Remove the anMQTTStructure from tracking.
	 This should be used when anMQTTStructure has been
	 explicitly freed, otherwise the finalizer may attempt
	 to free it again
	 
	 Arguments:
		anMQTTStructure - <MQTTStructure>"
	
	[SmartReferences remove: anMQTTStructure ifAbsent: []] critical
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> removeWeakReference: anMQTTStructure [
	"Remove the reference (non-memory owner) @anMQTTStructure
	 from the reference tracking list
	 
	 Arguments:
		anMQTTStructure - <anMQTTStructure>"

	| address |

	address := self resolveWeakReferenceAddress: anMQTTStructure.
	address isNil ifTrue: [^self].
	[ | refs |
		refs := WeakReferences at: address ifAbsent: [^self].
		refs remove: anMQTTStructure ifAbsent: [].
		refs isEmpty ifTrue: [WeakReferences removeKey: address]]
			critical
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> resolveWeakReferenceAddress: anMQTTStructure [
	"Locate the address in the WeakReferences table for @anMQTTStructure.
	 If @anMQTTStructure is defined...then just answer the <Integer> address,
	 otherwise do a value search in the table until @anMQTTStructure is found
	 and answer the associated <Integer> key. Answer nil if not found
	 
	 Arguments:
		anMQTTStructure - <MQTTStructure>
	 Answers:
		<Integer> address
		<UndefinedObject> not found"

	anMQTTStructure isUndefined
		ifTrue: [
			[
				WeakReferences keysAndValuesDo: [:address :refs |
					(refs includes: anMQTTStructure) ifTrue: [^address]]]
						critical.
			^nil]
		ifFalse: [^anMQTTStructure address]
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> scheduleExpunge: anOSObject [
	"FINALIZATION HOOK
	 If this is a defined <OSObject>, then schedule this ref to be expunged.
	 Start the background process (@ExpungeableMonitor) to clear out expunged
	 references if an existing process doesn't exist.
	 For an explanation of why its done this way, see the comment in
	 #expungeReferences."

	(anOSObject isNil or: [anOSObject isUndefined])
		ifFalse: [
			[
				ExpungeableMonitor isNil ifTrue: [self startExpungeableMonitor].
				ExpungeableReferences add: anOSObject]
					critical]
]

{ #category : 'API' }
MQTTMemoryTracker class >> smartReferenceCount: anMQTTStructure [
	"Answer the number of smart refs to the address
	 in @anMQTTStructure.  Multiple smart refs to the same address
	 can exist.
	 
	 This is essentially equivalent to asking what the MQTT reference
	 count is for an 'allocated' memory address.  For a static reference
	 this would answer 0 since there isn't an associated smalltalk smart
	 reference (ownsMemory = true).
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<Integer> - number of smart references"

	"Must iterate over Array because we need equality check, not identity"
	^[SmartReferences asArray occurrencesOf: anMQTTStructure] critical
]

{ #category : 'API' }
MQTTMemoryTracker class >> smartReferenceFor: anMQTTStructure [
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
	
	"Must iterate because this is an identity set and we need equality"
	^[SmartReferences asArray detect: [:struct | struct = anMQTTStructure] ifNone: [nil]] critical
]

{ #category : 'API' }
MQTTMemoryTracker class >> smartReferencesFor: anMQTTStructure [
	"Answer a <SequenceableCollection> of
	 <MQTTStructure> smart reference associated
	 with the address referred to by @anMQTTStructure.
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<SequenceableCollection of <MQTTStructure>>
			smart references (ownsMemory = true) with address = @anMQTTStructure address"

	"Must iterate because this is an identity set and we need equality"
	^[SmartReferences asOrderedCollection select: [:struct | struct = anMQTTStructure]] critical
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> startExpungeableMonitor [
	"Start a new process which frees expunged references
	 after a delay.  As new refs are created, refs will be expunged
	 only if the expunged collection reached a max size.  This handles
	 the case where no further allocation is occurring and memory
	 needs to be freed"
	
	ExpungeableMonitor :=
		[
			[true] whileTrue: [
				(Delay forSeconds: 60) wait.
				self expungeReferences]]
					newProcessNamed: 'MQTT Reference Expunger'.
	ExpungeableMonitor
		priority: Processor userInterruptPriority;
		resume
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> startUp [
	"Handle image startup procedures"

	self initializeMemoryTracking
]

{ #category : 'Internal',
  #vaVisibility : 'private' }
MQTTMemoryTracker class >> stopExpungeableMonitor [
	"Kill and nil the monitor"
	
	ExpungeableMonitor isNil ifTrue: [^self].
	ExpungeableMonitor terminate.
	ExpungeableMonitor := nil
]

{ #category : 'API' }
MQTTMemoryTracker class >> trackSmartReference: anMQTTStructure [
	"Add anMQTTStructure to the finalize set used
	 for freeing memory if not explictily done.
	 
	 Arguments:
		anMQTTStructure - <MQTTStructure>"
	
	self expungeReferencesIfRequired.
	[SmartReferences add: anMQTTStructure] critical
]

{ #category : 'API' }
MQTTMemoryTracker class >> trackWeakReference: anMQTTStructure [
	"Add the reference (non-memory owner) @anMQTTStructure
	 to the reference tracking list
	 
	 PRECONDITION: anMQTTStructure isUndefined = false
	 
	 Arguments:
		anMQTTStructure - <MQTTStructure>"

	self expungeReferencesIfRequired.
	[
		(WeakReferences
			at: anMQTTStructure address
			ifAbsentPut: [
				EsWeakIdentitySet new
					owner: self;
					finalizeAction: self finalizeAction;
					yourself])
						add: anMQTTStructure]
							critical
]

{ #category : 'API' }
MQTTMemoryTracker class >> weakReferenceCount: anMQTTStructure [
	"Answer the number of weak refs to the address
	 in @anMQTTStructure
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<Integer> - number of weak references"

	^(self weakReferencesFor: anMQTTStructure) size
]

{ #category : 'API' }
MQTTMemoryTracker class >> weakReferencesFor: anMQTTStructure [
	"Answer a <SequenceableCollection> of
	 <MQTTStructure> weak reference associated
	 with the address referred to by @anMQTTStructure.
	 
	 Argument:
		<MQTTStructure> - reference struct
	 Answers:
		<SequenceableCollection of <MQTTStructure>>
			weak references (ownsMemory = false) with address = @anMQTTStructure address"

	^[
		(WeakReferences
			at: (self resolveWeakReferenceAddress: anMQTTStructure)
			ifAbsent: [^OrderedCollection new])
				asOrderedCollection]
					critical
]
