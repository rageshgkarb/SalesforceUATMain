/* -------------------------------------------------------------------------------------------  */
/* C0610 NVM Call Recording Api																	*/
/* -------------------------------------------------------------------------------------------  */
global class NVMAPICallRecordingControl {

    public NVMAPICallRecordingControl(ApexPages.StandardController controller) {
    }

    public static void pauseCallRecording() {
		System.debug('We are trying to pause the call recording');

        NVMApiHelper nvmApi = new NVMAPIHelper();
        
        String accessToken = nvmApi.getBearerToken();        
		System.debug('access token or Bearer Token is ' + accessToken);

        String guid = '';

        guid = NVMAPICallRecordingControl.findCurrentCallGUID();
		System.debug('Current Call Guid' + guid);
        
        if (accessToken.length() > 0 && guid != '') {

			System.debug('Pausing call Recording');
            HTTPRequest req = new HTTPRequest();
        
            req.setEndpoint(nvmApi.getCloud()+'/v0/'+nvmApi.getAccountKey()+'/calls/' + guid);
            req.setMethod('POST');
            
            req.setHeader('Content-Type','application/json');
            req.setHeader('Authorization', 'Bearer '+accessToken);
            
            req.setBody('{ "recordingStatus": "Paused" }');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);   

            System.debug('Call Recording Pause Request result: ' + res.getBody());
			System.debug('Call Recording Paused Successfully');
        }
    }
    
    public static void resumeCallRecording() {
		System.debug('We are trying to resume the call recording');

        NVMApiHelper nvmApi = new NVMAPIHelper();
        
        String accessToken = nvmApi.getBearerToken();        
		System.debug('access token or Bearer Token is ' + accessToken);

        String guid = '';

        guid = NVMAPICallRecordingControl.findCurrentCallGUID();
		System.debug('Current Call Guid ' + guid);
        
        if (accessToken.length() > 0 && guid != '') {
			
			System.debug('Resuming call Recording');

            HTTPRequest req = new HTTPRequest();
        
            req.setEndpoint(nvmApi.getCloud()+'/v0/'+nvmApi.getAccountKey()+'/calls/' + guid);
            req.setMethod('POST');
            
            req.setHeader('Content-Type','application/json');
            req.setHeader('Authorization', 'Bearer '+accessToken);
            
            req.setBody('{ "recordingStatus": "Started" }');
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            System.debug('Call Recording Resume Request result: ' + res.getBody());			
			System.debug('Call Recording Resumed Successfully');
        }
    }
    
    public static String findCurrentCallGUID() {
        Id usr = System.UserInfo.getUserId();
        
        String agentId = [SELECT NVMContactWorld__NVM_Agent_Id__c FROM User WHERE ID = :usr LIMIT 1].NVMContactWorld__NVM_Agent_Id__c;
        
        NVMApiHelper nvmApi = new NVMAPIHelper();
        
        String accessToken = nvmApi.getBearerToken();
        
        String guid = '';
        
        if (accessToken.length() > 0 && agentId != null && agentId != '') {
            HTTPRequest req = new HTTPRequest();
        
            req.setEndpoint(nvmApi.getCloud()+'/v0/'+nvmApi.getAccountKey()+'/agents/' + agentId);
            req.setMethod('GET');
            
            req.setHeader('Content-Type','application/json');
            req.setHeader('Authorization', 'Bearer '+accessToken);
            
			System.debug('Sending Request to find Current Call Guid' + req);
            Http http = new Http();
            HTTPResponse res = http.send(req);
        
            System.debug('Result received for the Current Call guid' + res.getBody());
        
            JSONParser parser = JSON.createParser(res.getBody());
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if (fieldName == 'currentCallGuid') {
                        guid = parser.getText();
                        break;
                    } 
                }
            }         
        } 
        
        return guid;     
    }
}