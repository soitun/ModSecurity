### Test for XML operator rules

### Validate Scheme
# OK
{
	type => "rule",
	comment => "validateSchema (validate ok)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateSchema $ENV{CONF_DIR}/SoapEnvelope.xsd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 1\).*Target value: "\[XML document tree\]".*Successfully validated payload against Schema/s, 1 ],
		-debug => [ qr/XML parser error|validation failed|Failed to load/, 1 ],
		-error => [ qr/XML parser error|validation failed|Failed to load/, 1 ],
	},
	match_response => {
		status => qr/^200$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
				xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
				xmlns:tns="http://www.bluebank.example.com/axis/getBalance.jws"
				xmlns:types="http://www.bluebank.example.com/axis/getBalance.jws/encodedTypes"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsd="http://www.w3.org/2001/XMLSchema">
						<soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
								<q1:getInput xmlns:q1="http://DefaultNamespace">
										<id xsi:type="xsd:string">12123</id>
								</q1:getInput>
						</soap:Body>
				</soap:Envelope>
			),
		),
	),
},
# Failed validation
{
	type => "rule",
	comment => "validateSchema (validate failed)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateSchema $ENV{CONF_DIR}/SoapEnvelope.xsd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 1\).*Target value: "\[XML document tree\]".*element is not expected/s, 1 ],
		-debug => [ qr/XML parser error|Failed to load/, 1 ],
		-error => [ qr/XML parser error|Failed to load/, 1 ],
	},
	match_response => {
		status => qr/^403$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
				xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
				xmlns:tns="http://www.bluebank.example.com/axis/getBalance.jws"
				xmlns:types="http://www.bluebank.example.com/axis/getBalance.jws/encodedTypes"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsd="http://www.w3.org/2001/XMLSchema">
						<soap:xBody soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
								<q1:getInput xmlns:q1="http://DefaultNamespace">
										<id xsi:type="xsd:string">12123</id>
								</q1:getInput>
						</soap:xBody>
				</soap:Envelope>
			),
		),
	),
},
# Bad XML
{
	type => "rule",
	comment => "validateSchema (bad XML)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateSchema $ENV{CONF_DIR}/SoapEnvelope.xsd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 0\).*XML parser error/s, 1 ],
		-debug => [ qr/Failed to load/, 1 ],
		-error => [ qr/Failed to load/, 1 ],
	},
	match_response => {
		status => qr/^403$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<soap:Envelop xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
				xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
				xmlns:tns="http://www.bluebank.example.com/axis/getBalance.jws"
				xmlns:types="http://www.bluebank.example.com/axis/getBalance.jws/encodedTypes"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsd="http://www.w3.org/2001/XMLSchema">
						<soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
								<q1:getInput xmlns:q1="http://DefaultNamespace">
										<id xsi:type="xsd:string">12123</id>
								</q1:getInput>
						</soap:Body>
				</soap:Envelope>
			),
		),
	),
},
# Bad schema
{
	type => "rule",
	comment => "validateSchema (bad schema)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateSchema $ENV{CONF_DIR}/SoapEnvelope-bad.xsd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 1\).*Target value: "\[XML document tree\]".*Failed to parse the XML resource.*Failed to load Schema/s, 1 ],
	},
	match_response => {
		status => qr/^200$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
				xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"
				xmlns:tns="http://www.bluebank.example.com/axis/getBalance.jws"
				xmlns:types="http://www.bluebank.example.com/axis/getBalance.jws/encodedTypes"
				xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xmlns:xsd="http://www.w3.org/2001/XMLSchema">
						<soap:Body soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
								<q1:getInput xmlns:q1="http://DefaultNamespace">
										<id xsi:type="xsd:string">12123</id>
								</q1:getInput>
						</soap:Body>
				</soap:Envelope>
			),
		),
	),
},

# Validate DTD
# OK
{
	type => "rule",
	comment => "validateDTD (validate ok)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateDTD $ENV{CONF_DIR}/SoapEnvelope.dtd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 1\).*Target value: "\[XML document tree\]".*Successfully validated payload against DTD/s, 1 ],
		-debug => [ qr/XML parser error|validation failed|Failed to load/, 1 ],
		-error => [ qr/XML parser error|validation failed|Failed to load/, 1 ],
	},
	match_response => {
		status => qr/^200$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<!DOCTYPE Envelope SYSTEM "SoapEnvelope.dtd">
				<Envelope>
						<Body>
								<getInput>
										<id type="string">12123</id>
								</getInput>
						</Body>
				</Envelope>
			),
		),
	),
},
# Failed validation
{
	type => "rule",
	comment => "validateDTD (validate failed)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateDTD $ENV{CONF_DIR}/SoapEnvelope.dtd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 1\).*Target value: "\[XML document tree\]".*content does not follow the DTD/s, 1 ],
		-debug => [ qr/XML parser error|Failed to load/, 1 ],
		-error => [ qr/XML parser error|Failed to load/, 1 ],
	},
	match_response => {
		status => qr/^403$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<!DOCTYPE Envelope SYSTEM "SoapEnvelope.dtd">
				<Envelope>
						<xBody>
								<getInput>
										<id type="string">12123</id>
								</getInput>
						</xBody>
				</Envelope>
			),
		),
	),
},
# Bad XML
{
	type => "rule",
	comment => "validateDTD (bad XML)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateDTD $ENV{CONF_DIR}/SoapEnvelope.dtd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 0\).*XML parser error/s, 1 ],
		-debug => [ qr/Failed to load/, 1 ],
		-error => [ qr/Failed to load/, 1 ],
	},
	match_response => {
		status => qr/^403$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<!DOCTYPE Envelope SYSTEM "SoapEnvelope.dtd">
				<Envelop>
						<Body>
								<getInput>
										<id type="string">12123</id>
								</getInput>
						</Body>
				</Envelope>
			),
		),
	),
},
# Bad DTD
{
	type => "rule",
	comment => "validateDTD (bad DTD)",
	conf => qq(
		SecRuleEngine On
		SecRequestBodyAccess On
		SecDebugLog $ENV{DEBUG_LOG}
		SecDebugLogLevel 9
		SecRule REQUEST_HEADERS:Content-Type "^text/xml\$" \\
		        "phase:1,t:none,t:lowercase,nolog,pass,ctl:requestBodyProcessor=XML"
		SecRule REQBODY_PROCESSOR "!^XML\$" nolog,pass,skipAfter:12345
		SecRule XML "\@validateDTD $ENV{CONF_DIR}/SoapEnvelope-bad.dtd" \\
		        "phase:2,deny,id:12345"
	),
	match_log => {
		debug => [ qr/XML: Initialising parser.*XML: Parsing complete \(well_formed 1\).*Target value: "\[XML document tree\]".*Failed to load DTD/s, 1 ],
	},
	match_response => {
		status => qr/^200$/,
	},
	request => new HTTP::Request(
		POST => "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}/test.txt",
		[
			"Content-Type" => "text/xml",
		],
		normalize_raw_request_data(
			q(
				<?xml version="1.0" encoding="utf-8"?>
				<!DOCTYPE Envelope SYSTEM "SoapEnvelope.dtd">
				<Envelope>
						<Body>
								<getInput>
										<id type="string">12123</id>
								</getInput>
						</Body>
				</Envelope>
			),
		),
	),
},