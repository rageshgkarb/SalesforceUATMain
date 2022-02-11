/* --------------------------------------------------------------------------- */
/* C0115    New class for EBSAction methods                                    */
/* --------------------------------------------------------------------------- */

public without sharing class IBBEBSActionMethods
{	
	public static Case theCase {get;set;}
    public static string theQuery {get;set;}
    public static string theSubQuery {get;set;}
    public static List<EBSActionConfig__c> theConfigs {get;set;}
    public static string theActionType {get;set;}
    public static string theCaseId {get;set;}
    public static string theXMLRequest {get;set;}
    public static string theXMLResponse {get;set;}
    public static Map<string, EBSActionConfig__c> theActionMap {get;set;}
    public static Map<string, string> theResponseMap {get;set;}
    public static string theResponseCode {get;set;}
    public static string theResponseDescription {get;set;}
    public static boolean SuccessfulResponse {get;set;}
	
	
	@future (callout=true)
	public static void ExecuteRequest(string caseId)
	{
        theCaseId = caseId;
        GetTheActionType ();
        GetTheConfigs ();
        GenerateTheQuery ();
        BuildTheMessage();
		
		 try
        {
            SendRequest();
            SuccessfulResponse  = true;
        }
        catch (Exception ex)
        {
            theResponseCode = '80';
            theResponseDescription = ex.getMessage();
            SuccessfulResponse  = false;
        }
        
        if (SuccessfulResponse)
        {
            ParseTheResponse();
            system.debug('response: ' + SuccessfulResponse);

            if (SuccessfulResponse)
            {
                ProcessTheResponse();
            }
        }
	}
	
	
	public static void GetTheActionType ()
    {
        List<Case> cases = [SELECT id,
                                   EBS_Action_Type__c
                            FROM   Case
                            WHERE   id = :theCaseId LIMIT 1];
        theActionType = cases[0].EBS_Action_Type__c;
    }
	
	 public static void GetTheConfigs ()
    {
        theConfigs = new List<EBSActionConfig__c>();
        //theActionMap = new Map<string, 
        theConfigs = [SELECT    Name,
                                APIField__c,
                                DataDirection__c,
                                DataLabel__c,
                                DataType__c,
                                EBSActionType__c
                      FROM      EBSActionConfig__c
                      WHERE     EBSActionType__c = :theActionType
                      ORDER BY  DataDirection__c];
        
        if (theConfigs.Size() > 0)
        {
            theSubQuery = '';
            for (EBSActionConfig__c config : theConfigs)
            {
                theSubQuery = theSubQuery + ', ' + config.APIField__c;
                
            }
        }
    }
    
    public static void GenerateTheQuery ()
    {
        theQuery = 'SELECT    Id ';
        theQuery = theQuery + ', EBS_Action_Status__c'; 
        theQuery = theQuery + ', CaseNumber'; 
        theQuery = theQuery + (string.IsBlank(theSubQuery) ? '' : theSubQuery);
        theQuery = theQuery + ' FROM Case WHERE id = \'' + theCaseId + '\'';
        
        Case[] caseList = Database.Query(theQuery);
        theCase = caseList[0];
 
    }
	
	 public static void BuildTheMessage ()
    {
        string xmlRequest = IBBXMLMethods.BuildEnvelope ('EBSAction',
                                                        'http://IBB.Salesforce.EBSActions',
                                                        'EBSAction',
                                                        null,
                                                        'EBSAction',
                                                        theCase.Id);
               
        xmlRequest = xmlRequest + '<ActionType>' + theActionType + '</ActionType>';
        xmlRequest = xmlRequest + '<EBSUserID>' + GetTheEBSUser() + '</EBSUserID>';
        xmlRequest = xmlRequest + '<SourceID>SFDC</SourceID>';
        xmlRequest = xmlRequest + '<CaseReference>' + theCase.CaseNumber + '</CaseReference>';
        xmlRequest = xmlRequest + '<ActionRequestAttributes>';
        
        boolean firstResponse = true;
        system.debug ('The configs ' + theConfigs);
        for (EBSActionConfig__c config : theConfigs)
        {
            system.debug (config.APIField__c);
            if (config.DataDirection__c == 'Response' && firstResponse)
            {
                
                xmlRequest = xmlRequest + '</ActionRequestAttributes><ActionResponseAttributes>';
                firstResponse = false;
            }
            xmlRequest = xmlRequest + '<ActionAttribute><ActionLabel>';    
            xmlRequest = xmlRequest +  config.DataLabel__c;
            xmlRequest = xmlRequest + '</ActionLabel>';
            xmlRequest = xmlRequest + '<ActionValue>';
            System.debug ('this is the field value ' + String.valueOf(theCase.get(config.APIField__c)));
            xmlRequest = xmlRequest + StripNull(String.ValueOf(theCase.get(config.APIField__c)));
            xmlRequest = xmlRequest + '</ActionValue>';
            xmlRequest = xmlRequest + '</ActionAttribute>';
            
            
        }
        xmlRequest = xmlRequest + (firstResponse == true ? '' : '</ActionResponseAttributes>');
        xmlRequest = xmlRequest + BuildMessageFooter();
        theXmlRequest = xmlRequest;
        system.debug ( 'This is the message ' + xmlRequest);
    }
	
	public static void SendRequest ()
    {
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        HttpResponse res;
        
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null)
        {
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'http://80.194.71.201:80/InboundBrokerService/GenericInboundBroker.asmx';
        
        if (ws != null)
        {
            endPoint = ws.Value__c;
        }
        
        tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
        giSoap.timeout_x = httpTimeout;
        giSoap.endpoint_x = endPoint;
            //This is the line that calls the WebService
        theXMLResponse = giSoap.BrokerInboundRequest(theXMLRequest);
        system.debug ( 'the xml response ' + theXMLResponse);
        
    }
    
	
	public static void ParseTheResponse()
    {
        theResponseMap = new Map<string, string>();
        XmlStreamReader xsr = new XmlStreamReader(theXMLResponse);
        string theTag;
        string theValue;
        while (xsr.hasNext())
        {
              if (xsr.getEventType() == XmlTag.START_ELEMENT)
              {
                  if ('MESSAGEID'.EqualsIgnoreCase(xsr.getLocalName()))
                  {
                      theTag = xsr.getLocalName();
                      xsr.next();
                      if (xsr.isCharacters())
                      {
                          theResponseMap.put (theTag, xsr.getText());
                      }
                  }
                  else if ('RESPONSECODE'.EqualsIgnoreCase(xsr.getLocalName()))
                  {
                      theTag = xsr.getLocalName();
                      xsr.next();
                      if (xsr.isCharacters())
                      {
                          theResponseMap.put (theTag, xsr.getText());
                          theResponseCode = xsr.getText();
                      }
                  }
                  else if ('RESPONSEDESCRIPTION'.EqualsIgnoreCase(xsr.getLocalName()))
                  {
                      theTag = xsr.getLocalName();
                      xsr.next();
                      if (xsr.isCharacters())
                      {
                          theResponseMap.put (theTag, xsr.getText());
                          theResponseDescription = xsr.getText();
                      }
                  }
              }
              xsr.next();
        }
        
        if (theResponseCode == '0')
        {
            SuccessfulResponse = true;
            theCase.EBS_Action_Response_Code__c = 'SUCCESS';
            theCase.EBS_Action_Response_Description__c = 'SUCCESS';
        }
        else
        {
            SuccessfulResponse = false;
            theCase.EBS_Action_Response_Code__c = 'FAILED';
            theCase.EBS_Action_Response_Description__c = theResponseDescription;
        }
        
        
        if (SuccessfulResponse)
        {
            xsr = new XmlStreamReader(theXMLResponse);
            boolean hasResponses = false;
            while (xsr.hasNext())
            {
                if (xsr.getEventType() == XmlTag.START_ELEMENT && 
                    'ActionResponseAttributes'.EqualsIgnoreCase(xsr.getLocalName()))
                {
                    system.debug ( 'Here 1');
                    hasResponses = true;
                }
                else if (xsr.getEventType() == xmlTag.START_ELEMENT && 
                    hasResponses == true)
                {
                    system.debug ( 'Here 2');
                    if ('ActionLabel'.EqualsIgnoreCase(xsr.getLocalName()))
                    {
                        system.debug ( 'Here 3');
                        
                        xsr.next();
                        if (xsr.IsCharacters())
                        {
                            system.debug ( 'The Action Label ' + xsr.getText());
                            theTag = xsr.getText();
                        }
                    }
                    else if ('ActionValue'.EqualsIgnoreCase(xsr.getLocalName()))
                    {
                        system.debug ( 'Here 3');
                        xsr.next();
                        if (xsr.IsCharacters())
                        {
                            system.debug ( 'the Action Value ' + xsr.getText());
                            theResponseMap.put (theTag, xsr.getText());
                        }
                    }   
                }
                
                
                xsr.next();
            }
        }
        
        system.debug ( 'The ResponseMap ' + theResponseMap);  
    }
    
    public static void ProcessTheResponse ()
    {
        for (EBSActionConfig__c config : theConfigs)
        {
            if (config.DataDirection__c == 'Response')
            {
                try
                {
                    system.debug('Process Request ....');
                    theCase.put (config.APIField__c, theResponseMap.get (config.DataLabel__c));
                    theCase.EBS_Action_Status__c = 'Complete';
                }
                catch (Exception ex)
                {
                    theCase.EBS_Action_Status__c = 'Failed';
                    system.debug ('This is the exception ' + ex.getMessage());
                }
            }
        }
        System.debug ( 'this is theCase ' + theCase);
        update theCase;
        
    }
    
    public static string GetTheEBSUser ()
    {
        string rtv;
        string SFDCUserId = UserInfo.getUserId();
        User usr =[SELECT Id,
                          EBSUSerID__c
                   FROM   User
                   WHERE  Id = :SFDCUserId];
                   
        rtv = usr.EBSUserId__c;
        return rtv;
    }
	
	public static String StripNull (String inValue)
    {
        system.debug ('This is inValue ' + inValue);
        if (inValue == 'null' || invalue == null)
        {
            system.debug ( 'Returning blank');
                return '';
        }
        else
        {
            return inValue;
        }
    }
	
	public static string BuildMessageFooter ()
    {
        string rtv;
        rtv = '</EBSAction>\n';
        rtv = rtv + '</EBSAction>\n';
        rtv = rtv + '</soap:Body>\n';
        rtv = rtv + '</soap:Envelope>\n';
        return rtv;
    }
}