@isTest
global class MockSTCardStoreCallout implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
		//	Create the fake response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/xml');
		response.setBody('<?xml version="1.0" encoding="UTF-8"?><responseblock version="3.67"><requestreference>X8893535</requestreference><response type="STORE"><merchant><merchantname>Islamic Bank of Britain</merchantname><orderreference>EXAMPLE</orderreference></merchant><transactionreference>5-52-245867</transactionreference><billing><payment type="VISA"><active>1</active><issuercountry>US</issuercountry><pan>411111######0211</pan><issuer>SecureTrading Test Issuer1</issuer></payment></billing><timestamp>2013-08-27 12:09:30</timestamp><live>0</live><error><message>Ok</message><code>0</code></error><operation><accounttypedescription>CARDSTORE</accounttypedescription></operation></response></responseblock>');
		response.setStatus('200');
		
		return response;
	}
}