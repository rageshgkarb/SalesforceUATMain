global class RestRequest
{
    public Web_Service_Log__c WebLog{get;set;}
    public Boolean LogMessage{get;set;}

    public RestRequest(Id webLogId)
    {
        List<Web_Service_Log__c> logs = [select Request__c,Response__c from Web_Service_Log__c where id=:webLogId limit 2];
        if(logs.size() == 1)
        {
            WebLog = logs[0];
        }
        else
        {
            WebLog = new Web_Service_Log__c();
        }


    }

    public RestRequest (Web_Service_Log__c log)
    {
        WebLog = log;
    }

    public RestRequest ()
    {
        LogMessage = true;
        WebLog = new Web_Service_Log__c();
    }

    public string GetREST(String url)    
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse res = h.send(req);
        String Response = res.getBody();
        
        System.debug(res.toString());
            System.debug(Response);
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
    
        return Response;
    }

    public string PostREST(String url,object postData)    
    {
        system.debug('URL : ' + url);
        system.debug('DATA : ' + postData);

        String Response;    
        try 
        {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setTimeout(120000);

        req.setBody('=' + Json.serialize(postData));
        //req.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
        if (LogMessage) { weblog.request__c = req.getBody();}

        HttpResponse res = h.send(req);
        Response = res.getBody();
        
        System.debug(res.toString());
            System.debug(Response);
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());


            ApexServiceBaseResponse responseData = (ApexServiceBaseResponse )JSON.deserialize(
               response, ApexServiceBaseResponse.class);

            if (LogMessage)
            {
                weblog.Response__c = response;
                weblog.Duration__c = responseData.Calloutduration;
                weblog.MessageType__c = responseData.ServiceName;
                //weblog.Error__c = responseData.Error;
                weblog.MessageId__c = responseData.MessageId;
                weblog.status__c = res.getStatus();
                weblog.StatusCode__c = res.getStatusCode();

                upsert WebLog;
            }

            return Response;
        }
        catch(Exception ex)
        {
            throw ex;
            //save log
            //weblog.Exception__c = ex.getMessage();
            upsert WebLog;
            return Response;
        }
    }

    public string PostREST(ApexServiceBaseRequest postData, String messageId)    
    {
        List<EBS_Message_Data__c> ebsData = EBS_Message_Data__c.getAll().Values();
        for(EBS_Message_Data__c ebs : ebsData)
        {
            if(ebs.name.equalsIgnoreCase('default'))
            {
                postData.Token = ebs.TokenID__c;
                postData.Source= ebs.SourceID__c;
                postData.MessageId= messageId;

                Teller_Settings__c ts = Teller_Settings__c.getValues('Engage Webservice Endpoint');

                return PostREST(ts.Value__c,postData);
            }
        }
        return null;        
    }

    //public string PostREST(object postData)    
    //{
    //    return PostREST('http://80.194.71.201:80/ApexService/api/JsonPost',postData);
    //}
    
    global virtual class ApexServiceBaseResponse
    {        
        public string ServiceName { get; set; }
        public Integer CalloutDuration { get; set; }
        public string Error { get; set; }
        public string LogId { get; set; }
        public String MessageId{get;set;}
        public Boolean Authenticated{get;set;}
    }

    public abstract class ApexServiceBaseRequest
    {
        public String ServiceName { get; set; }
        public String Token { get; set; }
        public String Source { get; set; }
        public String User { get; set; }
        public String MessageId {get; set;}
    }


}