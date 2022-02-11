/*******************************************************************
* Class Name: ARBTestUtils
* Created By: Ragesh G
* Purpose 	: Utility class holds methods that are using throughout this application

********************************************************************/
@isTest

public with sharing class ARBTestUtils {
    
    
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

}