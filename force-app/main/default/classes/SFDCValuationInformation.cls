// 2012-03-19 jba/pjc - Add asset_relationship.relationship_to_Primary_app update to ProcessJAR

global class SFDCValuationInformation 
{

    webservice static String testComms(String inTestString)
    {
        System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webservice static String processValuationNotification(String inInstructionNotification)
    {
        string messageId;
        string messageType;
        string lenderRef;
        
        string notificationType;
        //Get the XML Message to use for processing the incoming XML
        XML_Message__c xmlMessage = [Select x.Type__c, 
                                        x.Start_Tag__c, 
                                        x.Name, 
                                        x.Id, 
                                        x.End_Tag__c, 
                                        x.Element_Name__c, 
                                        x.Active__c, 
                                        Service_Name_Element__c,
                                        Service_Namespace__c, 
                                        Element_Namespace__c, 
                                        Buffered__c, 
                                            (Select Name, 
                                                    Field_Label__c, 
                                                    Field_API_Name__c, 
                                                    Start_Tag__c, 
                                                    End_Tag__c, 
                                                    Message_Order__c, 
                                                    Data_Type__c  
                                            From XML_Message_Tags__r 
                                            Order By Message_Order__c ASC) 
                                        From XML_Message__c x 
                                        where x.Type__c = 'Inbound' 
                                        and x.Name = 'ValuationNotification' 
                                        and x.Active__c = true];
        
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldToTypeMap = new Map<String, String>();
        try 
        {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get('Valuation_Notification__c');
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
        }
        catch (Exception objE)
        {
            return 'FAILED';
        }
        
        List<string> fieldList = new List<string>();
        //system.debug('Size of TagList ' + tagList.Size());
        for (XML_Message_Tag__c xmlTag : tagList)
        {
            //system.debug('Why Not here ' + tagList);
            fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
            //system.debug ('API field name is ' + xmlTag.Field_API_Name__c);
            if (!String.isEmpty(xmlTag.Field_API_Name__c)) 
            {
                fieldList.Add(xmlTag.Field_API_Name__c);
            }
            fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
        }
        
        String fieldName;
        String fieldValue;
        Map<String, String> mapFieldsToValues = new Map<String, String>();
        String decodedString;
        try 
        {
            decodedString = EncodingUtil.urlDecode(inInstructionNotification, 'UTF-8');
           
        }
        catch (Exception decodeEx)
        {
           
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }
        
        XmlStreamReader xsr = new XmlStreamReader(decodedString);
        //Check how many records we're processing
               
        //System.debug('*** -- We have received ' + customerCount + ' customers -- ***');
        
        //Do the work
        xsr = new XmlStreamReader(decodedString);
        String targetField;
        String targetValue;
        String fieldDataType;
        String strTargetValue;
        integer intTargetValue;
        Date dtTargetValue;
        double dblTargetValue;
        List<SObject> objectsToUpsert = new List<SObject>();
       
     
        SObject theObject;
        string valRepId ;
        while (xsr.hasNext())
        {
            
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                if ('IBBInstructionNotification'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    //Create the new sObject
                    theObject = new Valuation_Notification__c();
                    
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                        messageId = xsr.getText();
                    }
                
                }
                else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
    
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                        messageType = xsr.getText();
                    }

                }
                else if ('LENDERREFERENCE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    system.debug ('Checking LenderReference ' );
    
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                        lenderRef = xsr.getText();
                        system.debug ('Checking LenderReference ' + lenderRef );
                        List<Valuation_Report__c> valReps = [Select Id
                                                             From Valuation_Report__c
                                                             Where LenderReference__c = :lenderRef];
                        if ( valReps.Size() > 0 )
                        {
                            valRepId = valReps[0].Id;
                            system.debug ('What is the Valuation Report Id AAAAA ? ' + valRepId);
                        }
                        
                    }

                }
                else if ('NOTIFICATIONTYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
    
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        //System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                        notificationType = xsr.getText();
                    }

                }
                else 
                {
                    fieldName = xsr.getLocalName();
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    
                }
            }
            else if (xsr.getEventType() == XmlTag.CHARACTERS)
            {
                System.debug('*** -- WE HAVE A CHARACTER ELEMENT -- ***');
                if (xsr.getText() != null)
                {
                    fieldValue = xsr.getText();
                    //System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                }                   
            }
            else if (xsr.getEventType() == XmlTag.END_ELEMENT)
            {
                System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                if ('IBBInstructionNotification'.equalsIgnoreCase(xsr.getLocalName()))
                {
                   
                    for (String s : fieldMap.keySet())
                    {
                        System.debug('*** -- About to pull ' + s + ' -- ***');
                        targetField = fieldMap.get(s);
                        fieldDataType = fieldToTypeMap.get(s);
                        targetValue = mapFieldsToValues.get(s);
                        
                        if ('STRING'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                strTargetValue = targetValue;
                                if (targetField != null && strTargetValue != null)
                                {
                                    system.debug ('Setting the object target field value A ' + strTargetValue);
                                    system.debug ('Setting the object target field value B ' + TargetField);
                                    theObject.put(targetField, strTargetValue);
                                }
                            }   
                        }
                        else if ('INTEGER'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                //System.debug('*** -- targetValue For Integer= ' + targetValue + ' -- ***');
                                try 
                                {
                                    intTargetValue = Integer.valueOf(targetValue);
                                }
                                catch (Exception e)
                                {
                                    intTargetValue = 0;
                                }
                                //System.debug('*** -- targetValue = ' + intTargetValue + ' -- ***');
                                if (targetField != null && intTargetValue != null)
                                {
                                    theObject.put(targetField, intTargetValue);
                                }
                            }
                        }
                        else if ('DOUBLE'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                try 
                                {
                                    dblTargetValue = Double.valueOf(targetValue);
                                }
                                catch (Exception e)
                                {
                                    dblTargetValue = 0;
                                }
                                //System.debug('*** -- targetValue = ' + dblTargetValue + ' -- ***');
                                if (targetField != null && dblTargetValue != null)
                                {
                                    theObject.put(targetField, dblTargetValue);
                                }
                            }
                        }
                        else if ('DATE'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
                                targetValue = targetValue.Substring (0, 10);
                                String[] dateSplit = targetValue.split('-');
                                if (dateSplit != null && dateSplit.size() == 3)
                                {
                                    try 
                                    {
                                        integer yr = integer.valueOf(dateSplit[0]);
                                        integer mth = integer.valueOf(dateSplit[1]);
                                        integer d = integer.valueOf(dateSplit[2]);
                                        dtTargetValue = Date.newInstance(yr, mth, d);
                                    }
                                    catch (Exception dateSplitEx)
                                    {
                                        System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                        System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                        return dateSplitEx + ' with date ' + targetValue;
                                    }
                                }
                                if (dtTargetValue != null)
                                {
                                    System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
                                }
                                if (targetField != null && dtTargetValue != null)
                                {
                                    theObject.put(targetField, dtTargetValue);
                                }
                            }
                        }
                        targetValue = null;
                    }
                    system.debug ('What is the Valuation Report Id ? ' + valRepId);
                    theObject.put('Valuation_Report__c', valRepId);
 
                }
                else 
                {
                
                    mapFieldsToValues.put(fieldName, fieldValue);
                   
                    fieldName = null;
                    fieldValue = null;
                }
            }
            //System.debug('*** -- XSR NEXT -- ***');
            xsr.next();
        }
        system.debug ('What is the Valuation Report Id ? ' + valRepId);
                 theObject.put('Valuation_Report__c', valRepId);
        Database.SaveResult[] notificationInsertResults;
        objectsToUpsert.Add(theObject);
        
        notificationInsertResults = Database.Insert( objectsToUpsert, false);
        
        boolean bSuccess = true;
        string returnMsg = '';
        string returnStatus = '';
        for(Database.SaveResult du : notificationInsertResults)
        {
            if (!du.isSuccess())
            {
               bSuccess = false;
               returnStatus = 'FAILED'; 

               List<Database.Error> dbErrs = du.getErrors();
               for (Database.Error err: dbErrs)
               {
                   returnMsg = returnMsg + '; ' + err.Message;
                   system.debug ( 'The Notification Error Message ' + err.Message);
               }
                                      
            }
        }
        
        
        if ( bSuccess )
        {
            returnStatus = 'SUCCESS';
            returnMsg = 'Succeeded';
        }
        
        system.debug ('The notification returnMsg ' + returnMsg);
          
        system.debug('The Instruction Notification ' + inInstructionNotification);
        String returnString = '<BrokerNotificationResponse><MessageID>' + messageId + '</MessageID>';
        returnString = returnString + '<MessageType>' + messageType + '</MessageType>';
        returnString = returnString + '<LenderReference>' + lenderRef + '</LenderReference>';
        returnString = returnString + '<NotificationType>' + notificationType + '</NotificationType>';
        returnString = returnString + '<ResponseStatus>' + returnStatus + '</ResponseStatus>';
        returnString = returnString + '<GeneralComments>' + returnMsg + '</GeneralComments>';
        returnString = returnString + '</BrokerNotificationResponse>';
        
        system.debug('The return Notification Message ' + returnString);
        return returnString;
    }
    
    webservice static String processValuationReport(String inValuationReport)
    {
        string messageId;
        string messageType;
        string lenderRef;
        
        string notificationType;
        //Get the XML Message to use for processing the incoming XML
        XML_Message__c xmlMessage = [Select x.Type__c, 
                                        x.Start_Tag__c, 
                                        x.Name, 
                                        x.Id, 
                                        x.End_Tag__c, 
                                        x.Element_Name__c, 
                                        x.Active__c, 
                                        Service_Name_Element__c,
                                        Service_Namespace__c, 
                                        Element_Namespace__c, 
                                        Buffered__c, 
                                            (Select Name, 
                                                    Field_Label__c, 
                                                    Field_API_Name__c, 
                                                    Start_Tag__c, 
                                                    End_Tag__c, 
                                                    Message_Order__c, 
                                                    Data_Type__c  
                                            From XML_Message_Tags__r 
                                            Order By Message_Order__c ASC) 
                                        From XML_Message__c x 
                                        where x.Type__c = 'Inbound' 
                                        and x.Name = 'ValuationReport' 
                                        and x.Active__c = true];
        
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldToTypeMap = new Map<String, String>();
        try 
        {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get('Valuation_Report__c');
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
        }
        catch (Exception objE)
        {
            return 'FAILED';
        }
        
        List<string> fieldList = new List<string>();
        //system.debug('Size of TagList ' + tagList.Size());
        for (XML_Message_Tag__c xmlTag : tagList)
        {
            //system.debug('Why Not here ' + tagList);
            fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
            //system.debug ('API field name is ' + xmlTag.Field_API_Name__c);
            if (!String.isEmpty(xmlTag.Field_API_Name__c)) 
            {
                fieldList.Add(xmlTag.Field_API_Name__c);
            }
            fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
        }
        
        String fieldName;
        String fieldValue;
        Map<String, String> mapFieldsToValues = new Map<String, String>();
        String decodedString;
        try 
        {
            decodedString = EncodingUtil.urlDecode(inValuationReport, 'UTF-8');
           
        }
        catch (Exception decodeEx)
        {
           
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }
        
        XmlStreamReader xsr = new XmlStreamReader(decodedString);
        //Check how many records we're processing
               
        //System.debug('*** -- We have received ' + customerCount + ' customers -- ***');
        
        //Do the work
        xsr = new XmlStreamReader(decodedString);
        String targetField;
        String targetValue;
        String fieldDataType;
        String strTargetValue;
        integer intTargetValue;
        Date dtTargetValue;
        double dblTargetValue;
        List<SObject> objectsToUpsert = new List<SObject>();
       
     
        SObject theObject;
       
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                //System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                if ('IBBInstructionReport'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    //System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    //Create the new sObject
                    
                    
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                        messageId = xsr.getText();
                    }
                
                }
                else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
    
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        //System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                        messageType = xsr.getText();
                    }

                }
                else if ('LENDERREFERENCE'.equalsIgnoreCase(xsr.getLocalName()))
                {
    
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        System.debug('*** -- FOUND LENDERREFERENCE= ' + xsr.getText() + ' -- ***');
                        lenderRef = xsr.getText();
                        theObject = DataHelper.GetValuationReportFromOppName (lenderRef)[0];
                    }

                }
                else if ('NOTIFICATIONTYPE'.equalsIgnoreCase(xsr.getLocalName()))
                {
    
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        //System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                        notificationType = xsr.getText();
                    }

                }
                else 
                {
                    fieldName = xsr.getLocalName();
                    //System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    
                }
            }
            else if (xsr.getEventType() == XmlTag.CHARACTERS)
            {
                //System.debug('*** -- WE HAVE A CHARACTER ELEMENT -- ***');
                if (xsr.getText() != null)
                {
                    fieldValue = xsr.getText();
                    //System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                }                   
            }
            else if (xsr.getEventType() == XmlTag.END_ELEMENT)
            {
                //System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                if ('IBBInstructionReport'.equalsIgnoreCase(xsr.getLocalName()))
                {
                   
                    for (String s : fieldMap.keySet())
                    {
                        System.debug('*** -- About to pull ' + s + ' -- ***');
                        targetField = fieldMap.get(s);
                        fieldDataType = fieldToTypeMap.get(s);
                        targetValue = mapFieldsToValues.get(s);
                        
                        if ('STRING'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                strTargetValue = targetValue;
                                if (targetField != null && strTargetValue != null)
                                {
                                    system.debug ('Setting the object target field value A ' + strTargetValue);
                                    system.debug ('Setting the object target field value B ' + TargetField);
                                    theObject.put(targetField, strTargetValue);
                                }
                            }   
                        }
                        else if ('INTEGER'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                System.debug('*** -- targetValue For Integer= ' + targetValue + ' -- ***');
                                try 
                                {
                                    intTargetValue = Integer.valueOf(targetValue);
                                }
                                catch (Exception e)
                                {
                                    intTargetValue = 0;
                                }
                                //System.debug('*** -- targetValue = ' + intTargetValue + ' -- ***');
                                if (targetField != null && intTargetValue != null)
                                {
                                    theObject.put(targetField, intTargetValue);
                                }
                            }
                        }
                        else if ('DOUBLE'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                try 
                                {
                                    dblTargetValue = Double.valueOf(targetValue);
                                }
                                catch (Exception e)
                                {
                                    dblTargetValue = 0;
                                }
                                System.debug('*** -- targetValue = ' + dblTargetValue + ' -- ***');
                                if (targetField != null && dblTargetValue != null)
                                {
                                    theObject.put(targetField, dblTargetValue);
                                }
                            }
                        }
                        else if ('DATE'.equalsIgnoreCase(fieldDataType))
                        {
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0)
                            {
                                System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
                                String[] dateSplit = targetValue.split('-');
                                if (dateSplit != null && dateSplit.size() == 3)
                                {
                                    try 
                                    {
                                        integer yr = integer.valueOf(dateSplit[0]);
                                        integer mth = integer.valueOf(dateSplit[1]);
                                        integer d = integer.valueOf(dateSplit[2]);
                                        dtTargetValue = Date.newInstance(yr, mth, d);
                                    }
                                    catch (Exception dateSplitEx)
                                    {
                                        System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                        System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                        return dateSplitEx + ' with date ' + targetValue;
                                    }
                                }
                                if (dtTargetValue != null)
                                {
                                    System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
                                }
                                if (targetField != null && dtTargetValue != null)
                                {
                                    theObject.put(targetField, dtTargetValue);
                                }
                            }
                        }
                        targetValue = null;
                    }
                    
 
                }
                else 
                {
                
                    mapFieldsToValues.put(fieldName, fieldValue);
                   
                    fieldName = null;
                    fieldValue = null;
                }
            }
            //System.debug('*** -- XSR NEXT -- ***');
            xsr.next();
        }
        theObject.put('Status__c', 'Valuation Report Received');
        //List<Valuation_Report__c> valReps = DataHelper.GetValuationReportFromOppName (lenderRef); 
        Database.SaveResult[] reportInsertResults;
        objectsToUpsert.Add(theObject);
        
        reportInsertResults = Database.Update( objectsToUpsert, false);
        
        boolean bSuccess = true;
        string returnMsg = '';
        string returnStatus = '';
        for(Database.SaveResult du : reportInsertResults)
        {
            if (!du.isSuccess())
            {
               bSuccess = false;
               returnStatus = 'FAILED'; 

               List<Database.Error> dbErrs = du.getErrors();
               for (Database.Error err: dbErrs)
               {
                   system.debug ('The error Msg ' + err.Message);
                   returnMsg = returnMsg + '; ' + err.Message;
               }
                                      
            }
        }
        
        
        if ( bSuccess )
        {
            returnStatus = 'SUCCESS';
            returnMsg = 'Succeeded';
        }
        system.debug ('The return Msg ' + returnMsg);
    
    
        system.debug('The Instruction Report ' + inValuationReport);
        String returnString = '<BrokerReportResponse><MessageID>' + messageId + '</MessageID>';
        returnString = returnString + '<MessageType>' + messageType + '</MessageType>';
        returnString = returnString + '<LenderReference>' + lenderRef+ '</LenderReference>';
        returnString = returnString + '<NotificationType>' + notificationType + '</NotificationType>';
        returnString = returnString + '<ResponseStatus>' + returnStatus + '</ResponseStatus>';
        returnString = returnString + '<GeneralComments>' + returnMsg + '</GeneralComments>';
        returnString = returnString + '</BrokerReportResponse>';
        system.debug ('The return Message ' + returnString);
        return returnString;
    }
    

    

    public static string SetEscaped(string inStr)
    {
        return '\'' + inStr + '\'';
    }


    
   

}