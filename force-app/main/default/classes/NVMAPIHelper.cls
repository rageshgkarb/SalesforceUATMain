/* -------------------------------------------------------------------------------------------  */
/* C0610 NVM Call Recording Api																	*/
/* -------------------------------------------------------------------------------------------  */
public class NVMAPIHelper {

    private String bearerTokenURL = '/v0/oauth2/token';
    
    public String getAccountKey () {
        return NVMContactWorld_Settings__c.getInstance().NVMContactWorld_clientId__c;
    }
    
    public String getAuthenticationToken () { 
        return NVMContactWorld_Settings__c.getInstance().NVMContactWorld_clientSecret__c;
    }
    
    public String getCloud () {
        return NVMContactWorld_Settings__c.getInstance().NVMContactWorld_baseURL__c;
    }
    
    public String getBearerToken () {
    
        HTTPRequest req = new HTTPRequest();
        
        req.setEndpoint(this.getCloud()+this.bearerTokenURL);
        req.setMethod('POST');
        
        Blob headerValue = Blob.valueOf(this.getAccountKey() + ':' + getAuthenticationToken());
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        req.setBody('grant_type=client_credentials');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug(res.getBody());
        
        JSONParser parser = JSON.createParser(res.getBody());
        
        String accessToken = '';
        
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if (fieldName == 'access_token') {
                    accessToken = parser.getText();
                    break;
                } 
            }
        }

        return accessToken;
    }
}