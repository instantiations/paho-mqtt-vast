Class {
	#name : 'MQTTTestResource',
	#superclass : 'TestResource',
	#pools : [
		'CfsConstants'
	],
	#category : 'MQTTTestApp'
}

{ #category : 'Support',
  #vaVisibility : 'private' }
MQTTTestResource >> create: aFilename [
	"Utility function used to create a file in the current directory.  Used to ensure that
	a file exists"

	| result |

	result := CfsFileDescriptor open: aFilename oflag: OCREAT.
	result isCfsError
		ifTrue: [^self error: ('Could not create %1%2' bindWith: aFilename with: result printString)].
	result close
]

{ #category : 'Support',
  #vaVisibility : 'private' }
MQTTTestResource >> create: aFilename contents: aByteObject [

	| result bytes dir |

	dir := aFilename asPath directory.
	dir exists ifFalse: [CfsDirectoryDescriptor mkdir: dir asString].
	result := CfsFileDescriptor open: aFilename oflag: OCREAT | OWRONLY | OTRUNC.
	result isCfsError
		ifTrue: [
			result := CfsFileDescriptor open: aFilename oflag: OCREAT | OWRONLY | OTRUNC.
			result isCfsError ifTrue: [^self halt: ('Could not create %1' bindWith: aFilename)]].

	bytes :=
		aByteObject isDBString
			ifTrue: [EsLeadEncodedBytes fromString: aByteObject]
			ifFalse: [aByteObject].

	result
		write: bytes startingAt: 1 nbyte: bytes size;
		flush;
		close
]

{ #category : 'Support',
  #vaVisibility : 'private' }
MQTTTestResource >> currentDirectoryName [

	^CfsDirectoryDescriptor getcwd asPath asString , CfsDirectoryDescriptor pathSeparatorString
]

{ #category : 'Accessing' }
MQTTTestResource >> getTestMosquittoOrgTrustStorePEMFileName [
	"Answer the name of the trust store cert for test.mosquitto.org"

	^(CfsPath fromParts: (Array with: self testDirectory with: 'mosquitto.org.crt')) asString
]

{ #category : 'Support',
  #vaVisibility : 'private' }
MQTTTestResource >> removeTestFiles [

	| files filename |

	files := CfsDirectoryDescriptor opendir: self testDirectory pattern: ('*') mode: FREG.
	files isCfsError ifTrue: [^self].
	[(filename := files readdirName) notNil] whileTrue: [
		CfsFileDescriptor
			remove: (CfsPath fromParts: (Array with: self testDirectory with: filename)) asString].
	files closedir.
	CfsDirectoryDescriptor rmdir: self testDirectory
]

{ #category : 'Startup/Teardown' }
MQTTTestResource >> setUp [

	self
		create: self getTestMosquittoOrgTrustStorePEMFileName
		contents:
			'-----BEGIN CERTIFICATE-----
MIIC8DCCAlmgAwIBAgIJAOD63PlXjJi8MA0GCSqGSIb3DQEBBQUAMIGQMQswCQYD
VQQGEwJHQjEXMBUGA1UECAwOVW5pdGVkIEtpbmdkb20xDjAMBgNVBAcMBURlcmJ5
MRIwEAYDVQQKDAlNb3NxdWl0dG8xCzAJBgNVBAsMAkNBMRYwFAYDVQQDDA1tb3Nx
dWl0dG8ub3JnMR8wHQYJKoZIhvcNAQkBFhByb2dlckBhdGNob28ub3JnMB4XDTEy
MDYyOTIyMTE1OVoXDTIyMDYyNzIyMTE1OVowgZAxCzAJBgNVBAYTAkdCMRcwFQYD
VQQIDA5Vbml0ZWQgS2luZ2RvbTEOMAwGA1UEBwwFRGVyYnkxEjAQBgNVBAoMCU1v
c3F1aXR0bzELMAkGA1UECwwCQ0ExFjAUBgNVBAMMDW1vc3F1aXR0by5vcmcxHzAd
BgkqhkiG9w0BCQEWEHJvZ2VyQGF0Y2hvby5vcmcwgZ8wDQYJKoZIhvcNAQEBBQAD
gY0AMIGJAoGBAMYkLmX7SqOT/jJCZoQ1NWdCrr/pq47m3xxyXcI+FLEmwbE3R9vM
rE6sRbP2S89pfrCt7iuITXPKycpUcIU0mtcT1OqxGBV2lb6RaOT2gC5pxyGaFJ+h
A+GIbdYKO3JprPxSBoRponZJvDGEZuM3N7p3S/lRoi7G5wG5mvUmaE5RAgMBAAGj
UDBOMB0GA1UdDgQWBBTad2QneVztIPQzRRGj6ZHKqJTv5jAfBgNVHSMEGDAWgBTa
d2QneVztIPQzRRGj6ZHKqJTv5jAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUA
A4GBAAqw1rK4NlRUCUBLhEFUQasjP7xfFqlVbE2cRy0Rs4o3KS0JwzQVBwG85xge
REyPOFdGdhBY2P1FNRy0MDr6xr+D2ZOwxs63dG1nnAnWZg7qwoLgpZ4fESPD3PkA
1ZgKJc2zbSQ9fCPxt2W3mdVav66c6fsb7els2W2Iz7gERJSX
-----END CERTIFICATE-----'
]

{ #category : 'Startup/Teardown' }
MQTTTestResource >> tearDown [

	self removeTestFiles
]

{ #category : 'Support',
  #vaVisibility : 'private' }
MQTTTestResource >> testDirectory [

	^(CfsPath fromParts: (Array with: self currentDirectoryName with: 'MQTTSunitTests')) asString
]
