//Utility class holds methods that are using throughout this application
public with sharing class UtilityClass {
	public static List<Web_Integration_Log__c> webLogsToUpsert {get; set;}
	
	public static void upsertWebLogs(){
		if (webLogsToUpsert.size() > 0){
			try {
				upsert webLogsToUpsert;
			}catch (Exception e){
				System.debug('*** -- Upsert Exception from UtilityClass.upsertWebLogs() -- ***');
				System.debug('*** -- Error: ' + e + ' -- ***');
				System.debug('*** -- At Line: ' + e.getLineNumber() + ' -- ***');
				return;
			}
		}
	}
	
	public static Web_Integration_Log__c createIntegrationLog(String inType, String inAction){
		Web_Integration_Log__c wl = new Web_Integration_Log__c();
		if ('Request'.equalsIgnoreCase(inType)){
			wl.Request_Action__c = inAction;	
		}else if ('Response'.equalsIgnoreCase(inType)){
			wl.Response_Action__c = inAction;
		}
		try {
			insert wl;
		}catch (Exception e){
			System.debug('*** -- Error in UtilityClass.createIntegrationLog -- ***');
        	System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
		}
		
		return wl;
	}
	
	public static Web_Integration_Log__c getIntegrationLog(String inId){
		Web_Integration_Log__c retWl = [Select w.Request_Status__c, w.Request_Output__c, w.Request_Log_Date_Time__c, 
		w.Request_Body__c, w.Request_Action__c, w.Id From Web_Integration_Log__c w where w.Id = :inId];
		
		return retWl;
	}
	
	public static Web_Integration_Log__c logSystemError(String className, Exception e, String extraInfo){
		Web_Integration_Log__c errorWL = new Web_Integration_Log__c();
		errorWL.Request_Status__c = 'SYSTEM FAILURE';
		String errorMessage = 'Class Name : ' + className + '\n';
		if (e != null){
			errorMessage = errorMessage + 'Exception : ' + e + '\n';
			errorMessage = errorMessage + 'Line Number : ' + e.getLineNumber() + '\n';
		}
		errorMessage = errorMessage + extraInfo;
		errorWL.Request_Body__c = errorMessage;
		errorWL.Request_Log_Date_Time__c = DateTime.now();
		
		try {
			insert errorWL;
		}catch (Exception insertError){
			System.debug('*** -- Error in UtilityClass.logSystemError -- ***');
        	System.debug('*** -- Error: ' + insertError + ' at line ' + insertError.getLineNumber() + '-- ***');
        	errorWL = null;
		}
		
		return errorWL;
		
	}
	
	public static void cloneXMLMessage(String inCurrentName, String inNewName){
		List<XML_Message__c> curRecordList = new List<XML_Message__c>();
		
		curRecordList = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
									x.Element_Name__c, x.Active__c, Service_Name_Element__c,
									Service_Namespace__c, Element_Namespace__c, 
									(Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c,  
									Data_Type__c From XML_Message_Tags__r Order By Message_Order__c ASC) 
									From XML_Message__c x where x.Name = :inCurrentName and x.Active__c = true];
		if (curRecordList.size() == 0){
			return;
		}
		
		XML_Message__c newMsg = new XML_Message__c();
		newMsg.Name = inNewName;
		newMsg.Element_Name__c = curRecordList[0].Element_Name__c;
		newMsg.Element_Namespace__c = curRecordList[0].Element_Namespace__c;
		newMsg.Service_Name_Element__c = curRecordList[0].Service_Name_Element__c;
		newMsg.Service_Namespace__c = curRecordList[0].Service_Namespace__c;
		newMsg.Type__c = curRecordList[0].Type__c;
		
		try {
			insert newMsg;
		}catch (Exception e){
			System.debug('*** -- Insert failed in UtilityClass.cloneXMLMessage -- ***');
			return;
		}
		
		List<XML_Message_Tag__c> tags = curRecordList[0].XML_Message_Tags__r;
		List<XML_Message_Tag__c> newTags = new List<XML_Message_Tag__c>();
		
		for (XML_Message_Tag__c tag : tags){
			XML_Message_Tag__c newTag = new XML_Message_Tag__c();
			newTag.Name = tag.Name;
			newTag.XML_Message__c = newMsg.Id;
			newTag.Field_Label__c = tag.Field_Label__c;
			newTag.Field_API_Name__c = tag.Field_API_Name__c;
			newTag.Message_Order__c = tag.Message_Order__c;
			newTag.Data_Type__c = tag.Data_Type__c;
			newTags.add(newTag);
		}
		try {
			insert newTags;
		}catch (Exception e){
			System.debug('*** -- Insert of new tags failed in UtilityClass.cloneXMLMessage -- ***');
			return;
		}
		
	}
	
	public static void insertNewTag(String inMessageId, String inTagName, String inFieldLabel, String inAPIName,
										Integer inMessageOrder, String inDataType){
		
		List<XML_Message_Tag__c> updateList = new List<XML_Message_Tag__c>();
		
		XML_Message__c xmlMessage = [select Id from XML_Message__c where Id = :inMessageId];
		List<XML_Message_Tag__c> tagList = [select Id, Message_Order__c from XML_Message_Tag__c where 
											XML_Message__c = :inMessageId and Message_Order__c >= :inMessageOrder
											Order By Message_Order__c ASC];
		List<XML_Message_Tag__c> checkTagList = [select Id, Message_Order__c from XML_Message_Tag__c where 
											XML_Message__c = :inMessageId and Message_Order__c = :inMessageOrder];
		XML_Message_Tag__c checkTag;
		if (checkTagList.size() > 0 ){
			checkTag = checkTagList[0];
		}
		
		XML_Message_Tag__c xmlTag = new XML_Message_Tag__c();								
		xmlTag.Name = inTagName;
		xmlTag.XML_Message__c = xmlMessage.Id;
		xmlTag.Field_Label__c = inFieldLabel;
		xmlTag.Field_API_Name__c = inAPIName;
		xmlTag.Message_Order__c = inMessageOrder;
		xmlTag.Data_Type__c = inDataType;
		
		if (checkTag == null){
			try {
				insert xmlTag;
			}catch (Exception e){
				System.debug('*** -- Save of XML Tag Records Failed -- ***');
				System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
			}
		}else {
			
			for (XML_Message_Tag__c x : tagList){
				x.Message_Order__c = x.Message_Order__c + 1;
				updateList.add(x);
			}
			updateList.add(xmlTag);
		}
		
		try {
			upsert updateList;
		}catch (Exception e){
			System.debug('*** -- Save of XML Tag Records Failed -- ***');
			System.debug('*** -- Error: ' + e + ' at line ' + e.getLineNumber() + '-- ***');
		}
												
	}
										
	//Get the picklist values from the object
	public static list<SelectOption> getPicklistValues(SObject obj, String fld)
	{
	      list<SelectOption> options = new list<SelectOption>();
	      // Get the object type of the SObject.
	      Schema.sObjectType objType = obj.getSObjectType(); 
	      // Describe the SObject using its object type.
	      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
	      // Get a map of fields for the SObject
	      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
	      // Get the list of picklist values for this field.
	      list<Schema.PicklistEntry> values =
	         fieldMap.get(fld).getDescribe().getPickListValues();
	      // Add these values to the selectoption list.
	      for (Schema.PicklistEntry a : values)
	      { 
	         options.add(new SelectOption(a.getLabel(), a.getValue())); 
	      }
	      return options;
	}
	
	//Send out an email
	public static void SendEmail(String[] recipients, String subject, String bodyText)
	{
		try
		{
			if(recipients != null && recipients.isEmpty() == false)
			{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = recipients;
			mail.setToAddresses(toAddresses);		
			mail.setSubject(subject);
			mail.setPlainTextBody(bodyText);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
		}
		catch(Exception e)
		{			
		}
	}
}