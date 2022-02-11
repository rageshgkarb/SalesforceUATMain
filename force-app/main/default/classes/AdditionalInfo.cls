// 2012-05-01 P00040 ibb lb  : New class to handle the creation of direct debit webservice calls 

public class AdditionalInfo{ 
                   
	public static void CreateEBSAdditionalInfoWebLog(string inOppId)
	{
		 Web_Integration_Log__c wl = new Web_Integration_Log__c();
 		try {
        wl.OpportunityId__c = inOppId;
        wl.Request_Action__c = 'EBSAdditionalInfoUpdate';
        
        Debug__c log = new Debug__c();
		log = [Select Id, Log__c, Opportunity__c from Debug__c Where Debug__c.Opportunity__c = : inOppId limit 1];
      	wl.Debug_Log__c = log.id;        
        
       
			insert wl;
			log.log__c = log.log__c + '\n Created DirectDebit Weblog ' + wl.id;
			update log;
        }catch (Exception e){
            System.debug('*** -- Error in AdditionalInfo.CreateEBSAdditionalInfoWebLog -- ***');
            System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
        }           
        return;		
	}                
	
	
	public static string sendDirectDebitMessage(string inOppId)
	{
		string message ='F';
		try
		{
		Debug__c log = new Debug__c();
		log = [Select Id, Log__c, Opportunity__c from Debug__c Where Debug__c.Opportunity__c = : inOppId limit 1];
		
		Web_Integration_Log__c wlog = [select w.Id,w.Request_Status__c,w.Request_Output__c, w.OpportunityId__c from Web_Integration_Log__c w 
                            where w.OpportunityId__c = :inOppId and w.Request_Action__c = 'EBSAdditionalInfoUpdate' limit 1];

		Opportunity opp = [select o.id, o.Payment_Type_List__c,Regular_Deposit_Frequency__c,  o.Account_with_IBB__r.External_Account_Number__c, o.Sort_Code__c,o.Account_Number__c,o.Direct_debit_date_day__c   from Opportunity o 
                            where o.id = :inOppId limit 1];           
        
        //load account
        string ibbAccount = opp.Account_with_IBB__r.External_Account_Number__c;       
        	message = sendDirectDebitMessage(log,wlog,opp,ibbAccount );
       
		}catch (Exception e){
			
		}
		
		return message;
	}
	    
                       
    public static string sendDirectDebitMessage(Debug__c log, Web_Integration_Log__c webLog, Opportunity opp,string ibbAccount  ){
    	// custom debug logging 
		Debugger debug = new Debugger();
		string errorMessage = '';
		
        log.Log__c = log.Log__c + '\n' + 'Into sendDirectDebitMessage';
    	    	 
    	String webLogId;
        webLogId = webLog.Id;
        
        String xmlMsgName = 'EBSAdditionalInfoUpdate';
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', webLogId);
        params.put('inId', opp.id);
        params.put('inObjectType', 'Opportunity');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'AdditionalInformationRequest');
        params.put('inAction', 'EBSAdditionalInfoUpdate');
        params.put('inXmlMsgName', xmlMsgName);
        params.put('inXmlResponseMsgName', 'AdditionalInformationResponse');        
        WebLogClass wlClass = new WebLogClass();   
        Map<String, String> values = new Map<String,String>();
        values.put('InformationType','AC');
        
        
        system.debug('************ Sort Code' + opp.Sort_Code__c );
        system.debug('************ Sort Code' + opp.Account_Number__c );
        
        
        if(ibbAccount == null)
        {
        	values.put('AccountNo','');
        }
        else
        {
        values.put('AccountNo',ibbAccount);
        }
                
        if(!'Direct Debit: Lump sum'.equalsIgnoreCase(opp.Payment_Type_List__c) &&
         (opp.Sort_Code__c == null || opp.Account_Number__c == null))
        {
        	    	log.Log__c = log.Log__c + '\n' + 'Not sending DD Message';
        	system.debug('Returning from Add DD');
        	return 'S';
        }                
        if(opp.Payment_Type_List__c != 'Direct Debit: Lump sum')
        {
        	values.put('InitialPaymentAmount',''); //if not DD initial payment, don't send to EBS        	
        }
        
        if( 'Yearly'.equalsIgnoreCase(opp.Regular_Deposit_Frequency__c))
        {
        	values.put('FrequencyOfPayments','Annually');        
        }     
         
         string dayofWeek = GetPaymentDayString(opp.Direct_debit_date_day__c);
         if(dayofWeek != null)
         {
         	  	values.put('PreferredDayInMonth',dayofWeek);
         }
         
  		// wlClass.webLogsToUpsert.add(webLog);    	
  		String returnString;
  		if(!Test.IsRunningTest())
  		{
        	 returnString = WebServiceClass.sendRequest(params, wlClass, values, log);
  		}
  		else
  		{
  			returnString='<status>S</status>';
  		}
        
        system.debug('*********** send web message');
        //webLog.Request_Body__c = returnString;       
                
        wlClass.upsertWebLogs();
 
	
        string statusCode=GetStatusCode(returnString);
        string message=GetErrorCodeMessage(returnString);
    
    

          system.debug('*********** responce' + returnString );
         system.debug(statusCode);
           system.debug(message);
         
     errorMessage = 'S';
     webLog.Request_Status__c = LogResult(statuscode,log);
     errorMessage =  	ParseErrorMessage(message);  
	 upsert webLog;
	 upsert log;
  	
    return errorMessage;        
    }
    
    public static string LogResult(string statusCode,Debug__c log )
    {
    	string returnStatus;
    	 if(statuscode == 'S')     
     {
     	returnStatus = 'SUCCESS';
     	log.Log__c = log.Log__c + '\n' + 'Direct Debit call success';   	
     }
     else
     {
     log.Log__c = log.Log__c + '\n' + 'Direct debit update failed';
     returnStatus = 'FAIL';  	 	
    }   
    return  returnStatus;
    }
      
    
    public static string ParseErrorMessage(string message)
    {
    	string returnMessage = 'S';
    	if(message == null)
    	return returnMessage;
    	
    	if(message.contains('invalid')){     	
     		if(message.contains('sortcode'))
     		{     		
     			returnMessage =  'Invalid Sort Code';	
     		}  
     		
     		if(message.contains('accountnumber'))
     		{     		
     			returnMessage = 'Invalid Account Number';	
     		}      
     	}  
     	return returnMessage;
    }
    
    
     public static string GetStatusCode(string output)
    {    
        XmlStreamReader xsr = new XmlStreamReader(output);
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('Status'.equalsIgnoreCase(xsr.getLocalName()))
                {                	
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        return xsr.getText();
                    
                    }
                }               
            }
            xsr.next();
        }
        return '';
    }
    
    public static string GetErrorCodeMessage(string output)
    {    
        XmlStreamReader xsr = new XmlStreamReader(output);
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {              
                if ('ErrorMessage'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters()){
                        return  xsr.getText().toLowerCase().replace(' ', '');
                        
                    }
                }
            }
            xsr.next();
        }
        return '';
    }
    
    public static string GetPaymentDayString(string day){	
    	string returnValue = null;
    	if('MONDAY'.equalsIgnoreCase(day)){
        	returnValue= '1';
        }
        if('TUESDAY'.equalsIgnoreCase(day)){
        	returnValue= '2';
        }
        if('WEDNESDAY'.equalsIgnoreCase(day)){
        	returnValue= '3';
        }
        if('THURSDAY'.equalsIgnoreCase(day)){
        	returnValue= '4';
        }
        if('FRIDAY'.equalsIgnoreCase(day)){
        	returnValue= '5';
         }
         return returnValue;
    }
}