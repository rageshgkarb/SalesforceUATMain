public with sharing class stSecureTradingUtils 
{
	public stSecureTradingUtils()
	{
		
	}

	public static stSecureTradingResponse postData(String data)
	{
		stSecureTradingResponse stSecureTradingRes;
		
		try
		{
			System.debug('## data : ' + data);
			
			HttpRequest req = new HttpRequest();
	        req.setMethod('POST');
	        
	        System.debug('## endpoint : ' + stCardStoreSettings.endpoint);
			req.setEndpoint(stCardStoreSettings.endpoint);
			
	        req.setHeader('Content-Type', 'text/xml');
	        req.setHeader('Content-Length', String.valueOf(data.length()));
			
			Blob headerValue = Blob.valueOf(stCardStoreSettings.username + ':' + stCardStoreSettings.password);
			System.debug('## headerValue => ' + headerValue);
			
     		String authorizationHeader = 'Basic ' +
     		EncodingUtil.base64Encode(headerValue);
     		System.debug('## authorizationHeader => ' + authorizationHeader);
     		
     		req.setHeader('Authorization', authorizationHeader);
     		req.setBody(data);
     		
     		System.debug('## req => ' + req);
     		System.debug('## req header - Content-Type => ' + req.getHeader('Content-Type'));
     		System.debug('## req header - Content-Length => ' + req.getHeader('Content-Length'));
     		System.debug('## req header - Authorization => ' + req.getHeader('Authorization'));
     		System.debug('## req body => ' + req.getBody());
     		
     		System.debug('## req doc => ' + req.getBodyDocument());
	         
	        Http http = new Http();
	        HttpResponse res = http.send(req);
	        
	        dom.Document resDoc = res.getBodyDocument();
	        System.debug('## resDoc : ' + resDoc.toXmlString());
	        
	        stSecureTradingRes = new stSecureTradingResponse(res);
		}
		catch(Exception e)
		{
			System.debug('Error occured : ' + e.getMessage());			
		}
		
		return stSecureTradingRes;	
	}

}