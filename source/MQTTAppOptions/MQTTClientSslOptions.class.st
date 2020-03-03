"
/**
* MQTTClient_sslProperties defines the settings to establish an SSL/TLS connection using the
* OpenSSL library. It covers the following scenarios:
* - Server authentication: The client needs the digital certificate of the server. It is included
*   in a store containting trusted material (also known as ""trust store"").
* - Mutual authentication: Both client and server are authenticated during the SSL handshake. In
*   addition to the digital certificate of the server in a trust store, the client will need its own
*   digital certificate and the private key used to sign its digital certificate stored in a ""key store"".
* - Anonymous connection: Both client and server do not get authenticated and no credentials are needed
*   to establish an SSL connection. Note that this scenario is not fully secure since it is subject to
*   man-in-the-middle attacks.
*/
typedef struct
{
	/** The eyecatcher for this structure.  Must be MQTS */
	char struct_id[4];
	/** The version number of this structure.  Must be 0, or 1 to enable TLS version selection. */
	int struct_version;

	/** The file in PEM format containing the public digital certificates trusted by the client. */
	const char* trustStore;

	/** The file in PEM format containing the public certificate chain of the client. It may also include
	* the client's private key.
	*/
	const char* keyStore;

	/** If not included in the sslKeyStore, this setting points to the file in PEM format containing
	* the client's private key.
	*/
	const char* privateKey;
	/** The password to load the client's privateKey if encrypted. */
	const char* privateKeyPassword;

	/**
	* The list of cipher suites that the client will present to the server during the SSL handshake. For a
	* full explanation of the cipher list format, please see the OpenSSL on-line documentation:
	* http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT
	* If this setting is ommitted, its default value will be ""ALL"", that is, all the cipher suites -excluding
	* those offering no encryption- will be considered.
	* This setting can be used to set an SSL anonymous connection (""aNULL"" string value, for instance).
	*/
	const char* enabledCipherSuites;

    /** True/False option to enable verification of the server certificate **/
    int enableServerCertAuth;

    /** The SSL/TLS version to use. Specify one of MQTT_SSL_VERSION_DEFAULT (0),
    * MQTT_SSL_VERSION_TLS_1_0 (1), MQTT_SSL_VERSION_TLS_1_1 (2) or MQTT_SSL_VERSION_TLS_1_2 (3).
    * Only used if struct_version is >= 1.
    */
    int sslVersion;

    /**
     * Whether to carry out post-connect checks, including that a certificate
     * matches the given host name.
     * Exists only if struct_version >= 2
     */
    int verify;

    /**
     * From the OpenSSL documentation:
     * If CApath is not NULL, it points to a directory containing CA certificates in PEM format.
     * Exists only if struct_version >= 2
	 */
	const char* CApath;

    /**
     * Callback function for OpenSSL error handler ERR_print_errors_cb
     * Exists only if struct_version >= 3
     */
    int (*ssl_error_cb) (const char *str, size_t len, void *u);

    /**
     * Application-specific contex for OpenSSL error handler ERR_print_errors_cb
     * Exists only if struct_version >= 3
     */
    void* ssl_error_context;

} MQTTClient_SSLOptions;
"
Class {
	#name : 'MQTTClientSslOptions',
	#superclass : 'MQTTTaggedStructure',
	#category : 'MQTTAppOptions'
}

{ #category : 'Accessing' }
MQTTClientSslOptions class >> id [
	"Answer the struct_id for this structure
	 
	 Answers:
		<String> 4 bytes"
	
	^'MQTS'
]

{ #category : 'Creation',
  #vaVisibility : 'private' }
MQTTClientSslOptions class >> initialize: anInstance version: aVersion [

	^(super initialize: anInstance version: aVersion)
		trustStore: nil;
		keyStore: nil;
		privateKey: nil;
		privateKeyPassword: nil;
		enabledCipherSuites: nil;
		enableServerCertAuth: true;
		sslVersion: MQTT_SSL_VERSION_DEFAULT;
		verify: false;
		CApath: nil;
		ssl_error_cb: nil;
		ssl_error_context: nil;
		yourself
]

{ #category : 'Startup/Shutdown',
  #vaVisibility : 'private' }
MQTTClientSslOptions class >> initializeAfterLoad [

	self
		members: #(
			struct_id struct_version trustStore keyStore privateKey privateKeyPassword
			enabledCipherSuites enableServerCertAuth sslVersion verify CApath ssl_error_cb
			ssl_error_context)
		types: #(
			'int8[4]' int32 pointer pointer pointer pointer pointer int32 int32 int32 pointer pointer
			pointer)
]

{ #category : 'Accessing' }
MQTTClientSslOptions class >> version [
	"Answer the identifier for this struct type
	 
	 Answers:
		<Integer>"

	^3
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> CApath [

	^self stringAt: #CApath
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> CApath: aString [

	self stringAt: #CApath put: aString
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> enabledCipherSuites [

	^self stringAt: #enabledCipherSuites
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> enabledCipherSuites: aString [

	self stringAt: #enabledCipherSuites put: aString
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> enableServerCertAuth [

	^self int32At: #enableServerCertAuth
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> enableServerCertAuth: anObject [

	self int32At: #enableServerCertAuth put: anObject
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> keyStore [

	^self stringAt: #keyStore
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> keyStore: aString [

	self stringAt: #keyStore put: aString 
]

{ #category : 'Memory Management',
  #vaVisibility : 'private' }
MQTTClientSslOptions >> nativeFree [
	"Free the MQTTClientWillOptions struct
	 INTERNAL USE ONLY: External callers need to use #free"

	| obj |

	obj := self osStringAt: #trustStore.
	obj notNull
		ifTrue: [
			self trustStore: nil.
			obj free].

	obj := self osStringAt: #keyStore.
	obj notNull
		ifTrue: [
			self keyStore: nil.
			obj free].

	obj := self osStringAt: #privateKey.
	obj notNull
		ifTrue: [
			self privateKey: nil.
			obj free].

	obj := self osStringAt: #privateKeyPassword.
	obj notNull
		ifTrue: [
			self privateKeyPassword: nil.
			obj free].

	obj := self osStringAt: #enabledCipherSuites.
	obj notNull
		ifTrue: [
			self enabledCipherSuites: nil.
			obj free].

	obj := self osStringAt: #CApath.
	obj notNull
		ifTrue: [
			self CApath: nil.
			obj free].

	self basicFree
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> privateKey [

	^self stringAt: #privateKey
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> privateKey: aString [

	self stringAt: #privateKey put: aString 
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> privateKeyPassword [

	^self stringAt: #privateKeyPassword
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> privateKeyPassword: anObject [

	self stringAt: #privateKeyPassword put: anObject
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> ssl_error_cb [

	^self pointerAt: #ssl_error_cb
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> ssl_error_cb: anObject [

	self pointerAt: #ssl_error_cb put: anObject
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> ssl_error_context [

	^self pointerAt: #ssl_error_context
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> ssl_error_context: anObject [

	self pointerAt: #ssl_error_context put: anObject
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> sslVersion [

	^self int32At: #sslVersion
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> sslVersion: anObject [

	self int32At: #sslVersion put: anObject asInteger asInt32
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> trustStore [

	^self stringAt: #trustStore
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> trustStore: aString [

	self stringAt: #trustStore put: aString
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> verify [

	^self int32At: #verify
]

{ #category : 'Accessing' }
MQTTClientSslOptions >> verify: anObject [

	self int32At: #verify put: anObject asInteger asInt32
]
