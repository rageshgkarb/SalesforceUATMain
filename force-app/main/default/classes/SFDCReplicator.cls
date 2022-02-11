// 2012-03-19 jba/pjc - Add asset_relationship.relationship_to_Primary_app update to ProcessJAR
/* --------------------------------------------------------------------------------------------- */
/* C00103 New methods for DeleteAccount and ReplaceAccount messages                              */
/* --------------------------------------------------------------------------------------------- */

global class SFDCReplicator {

    webservice static String testComms(String inTestString){
        System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }

    webservice static String processCustomers(String inCustomerList){
    
        boolean usetheSFDCID = false;
        String returnString;
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('UseSFDCID');
        if (ws != null)
        {
            if (ws.Value__c == 'YES')
            {
                usetheSFDCID = true;
            }
        }
        
        if (usetheSFDCID == true)
        {
            Schema.Sobjectfield externalIdField;
            RecordType personRecType = [select id 
                                        from recordType 
                                        where ispersontype=true 
                                        and sobjectType='account' limit 1];
            
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
                                            and x.Name = 'ReplicateNewCustomer' 
                                            and x.Active__c = true];
            
            List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
            Map<String, String> fieldMap = new Map<String, String>();
            Map<String, String> fieldToTypeMap = new Map<String, String>();
            try 
            {
                Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
                Schema.SObjectType whichObject = objectMap.get('Account');
                Schema.Describesobjectresult r = whichObject.getDescribe();
                Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
                
            }
            catch (Exception objE)
            {
                //System.debug('*** -- Error processing objects in XMLMethods.processResponseString -- ***');
                //System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
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
                decodedString = EncodingUtil.urlDecode(inCustomerList, 'UTF-8');
                //('*** -- DECODED STRING -- ***');
                //System.debug('*** -- ' + decodedString + ' -- ***');
            }
            catch (Exception decodeEx)
            {
                //System.debug('*** -- Error in processCustomers decoding string -- ***');
                //System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
                return 'FAILED TO DECODE WITH ' + decodeEx;
            }
            
            XmlStreamReader xsr = new XmlStreamReader(decodedString);
            //Check how many records we're processing
            integer customerCount = 0;
            while (xsr.hasNext())
            {
            
                if (xsr.getEventType() == XmlTag.START_ELEMENT)
                {
                    if ('ADDNEWCUSTOMERALLINFORMATION'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        customerCount++;
                    }
                }
                xsr.next();
            }
            
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
            List<ReplicateAccount> repAccounts = new List<ReplicateAccount>();
            
            List<SFDCIDReplicateAccount> sfdcidRepAccounts = new List<SFDCIDReplicateAccount>();
            SFDCIDReplicateAccount sfdcidRepAccount;
            List<ReplicationMessage> failRepMsgsToProcess = new List<ReplicationMessage>();

            Map<string, SFDCIDReplicateAccount> sfdcidRepMap = new Map<string, SFDCIDReplicateAccount>();
            Map<string, SFDCIDReplicateAccount> ebsidRepMap = new Map<string, SFDCIDReplicateAccount>();

            ReplicateAccount repAccount;
            SObject theObject;
           
            while (xsr.hasNext())
            {
                if (xsr.getEventType() == XmlTag.START_ELEMENT)
                {
                    //System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                    if ('ADDNEWCUSTOMERALLINFORMATION'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        //System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                        //Create the new sObject
                        theObject = new Account(RecordTypeId = personRecType.Id);
                        repAccount = new ReplicateAccount();
                        
                        sfdcidRepAccount = new SFDCIDReplicateAccount();
                    }
                    else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                    {
            
                        if (repAccount != null)
                        {
                            xsr.next();
                            if (xsr.isCharacters())
                            {
                                System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                                repAccount.messageId = xsr.getText();
                            }
                        }   
                    }
                    else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName()))
                    {
            
                        if (repAccount != null)
                        {
                            xsr.next();
                            if (xsr.isCharacters())
                            {
                                //System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                                repAccount.messageType = xsr.getText();
                            }
                        }   
                    }
                    else if ('SFDCID'.equalsIgnoreCase(xsr.getLocalName()))
                    {
            
                        if (sfdcidRepAccount != null)
                        {
                            xsr.next();
                            if (xsr.isCharacters())
                            {
                                //System.debug('*** -- FOUND SFDCID = ' + xsr.getText() + ' -- ***');
                                sfdcidRepAccount.SFDCID = xsr.getText();
                                
                            }
                        }   
                    }
                    else 
                    {
                        fieldName = xsr.getLocalName();
                        //System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                        if ('EBSID'.equalsIgnoreCase(xsr.getLocalName()))
                        {
                            if (sfdcidRepAccount != null)
                            {
                                xsr.next();
                                if (xsr.isCharacters())
                                {
                                    //System.debug('*** -- FOUND EBSID = ' + xsr.getText() + ' -- ***');
                                    sfdcidRepAccount.EBSID = xsr.getText();
                                    fieldValue = xsr.getText();
                                }
                            }   
                        }
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
                    if ('ADDNEWCUSTOMERALLINFORMATION'.equalsIgnoreCase(xsr.getLocalName()))
                    {
                        //system.debug('EBSID ' + fieldMap.get('EBSID'));
                        //system.debug('EBS_ID__c ' + fieldMap.get('EBS_ID__c'));
                        for (String s : fieldMap.keySet())
                        {
                            //System.debug('*** -- About to pull ' + s + ' -- ***');
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
                                        //system.debug ('Setting the object target field value A ' + strTargetValue);
                                        //system.debug ('Setting the object target field value B ' + TargetField);
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
                                    //System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
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
                                            //System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                            //System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                            return dateSplitEx + ' with date ' + targetValue;
                                        }
                                    }
                                    if (dtTargetValue != null)
                                    {
                                        //System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
                                    }
                                    if (targetField != null && dtTargetValue != null)
                                    {
                                        theObject.put(targetField, dtTargetValue);
                                    }
                                }
                            }
                            targetValue = null;
                        }
                        
                        repAccount.acc = (Account)theObject;
                        repAccounts.add(repAccount);
                        
                        ReplicateAccount rpAcc = new ReplicateAccount();
                        rpAcc = repAccount;
 
                        sfdcidRepAccount.replAccount = rpAcc;
                      
                        if (!sfdcidRepMap.ContainsKey(sfdcidRepAccount.SFDCID))
                        {
                            sfdcidRepAccounts.Add(sfdcidRepAccount);
                            sfdcidRepMap.put(sfdcidRepAccount.SFDCID, sfdcidRepAccount);
                            if (!ebsidRepMap.ContainsKey(sfdcidRepAccount.EBSID))
                            {
                                ebsidRepMap.put(sfdcidRepAccount.EBSID, sfdcidRepAccount);
                            }
                            system.debug ( 'A - the sfdcidRepAccounts ' + sfdcidRepAccounts);
                        }
                        else
                        {
                            if (!ebsidRepMap.ContainsKey(sfdcidRepAccount.EBSID))
                            {
                                sfdcidRepAccounts.Add(sfdcidRepAccount);
                                ebsidRepMap.put(sfdcidRepAccount.EBSID, sfdcidRepAccount);
                            }
                            else
                            {
                                ReplicationMessage rpMsg = new ReplicationMessage();
                                rpMsg.MessageId = sfdcidRepAccount.replAccount.MessageID;
                                rpMsg.Result = 'DUPLICATE Record';
                                failRepMsgsToProcess.Add(rpMsg);
                            }

                        }
                        system.debug ( 'B - the sfdcidRepAccounts ' + sfdcidRepAccounts);
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
        
            //At this point we should have a list of ReplicateAccounts ready to process
            // These are to hold the response messages
            List<ReplicationMessage> repMsgList = new List<ReplicationMessage>();
            List<ReplicationMessage> repFailedMsgList = new List<ReplicationMessage>();
            List<ReplicationMessage> repListToProcess = new List<ReplicationMessage>();
            List<ReplicationMessage> repFailedListToProcess = new List<ReplicationMessage>();

            /*  
            Trying to update the correct record, rules are:
            Should update the existing account if the SFDCID on message exists on an Account
            If doesn't exist, still update if the EBSID exists on an Account
            Raise error however if the SFDCID exists but the EBS supplied EBSID is different to the on SFDC
            Only if exists on neither should an insert occur
            Also the SFDCID needs to be dropped from the in-memory Account object to be upserted
            as it cannot be set nor inserted        
            */
            
            // List of Message SFDCIDs
            List<string> SFDCIDs = new List<string>();
            List<string> EBSIDs = new List<string>();

            List<SFDCIDReplicateAccount> ExistSFDCIDRepAccounts = new List<SFDCIDReplicateAccount>();
            List<SFDCIDReplicateAccount> ExistEBSIDRepAccounts = new List<SFDCIDReplicateAccount>();            
            
            // Get the List of Message SFDCIDs to query against SFDC Accounts
            
            /* CPDR01 */
            system.debug ( 'This is sfdcidRepAccounts ' + sfdcidRepAccounts);
            /* CPDR01 */
            for (SFDCIDReplicateAccount sra : sfdcidRepAccounts)
            {
                SFDCIDs.Add(SetEscaped(sra.SFDCID));
            }
            system.debug ( 'This is SFDCIDs ' + SFDCIDs);
 
            // Get the List of SFDCIDs on existing Accounts
            
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

            String theQuery = DataHelper_PreHPP.GenerateFields(fldObjMapValues );

            // Finalize query string
            theQuery +=  ' FROM Account WHERE SFDC_ID__c in  ' + SFDCIDs ;
            
            /* CPDR01 */
            system.debug ( 'This is the query ' + theQuery);
 
            List<Account> AccountsWithSFDCIDs = Database.query(theQuery);
 
            // Put all the found SFDCIDs in a list of Objects ready to be updated   
            
            Map<string, Account> failedIndexesMap = new Map<string, Account>();  
            integer failedIndexes = 0;
            List<Account> AccountsWithGoodSFDCIDs = new List<Account>();
            if ( AccountsWithSFDCIDs.Size() > 0 )
            {  
                 
                integer i = 0;                        
                for (Account acc : AccountsWithSFDCIDs)
                {
                    SFDCIDReplicateAccount rpAcc = new SFDCIDReplicateAccount();
                   
                    rpAcc = sfdcidRepMap.get(acc.SFDC_ID__c);
                    // Check that the EBSID against the account we've retrieved is blank or the same
                    // as that we've been given
                    //system.debug('This is the data to compare SFDC ID ' + acc.SFDC_ID__c + ' SFDC EBS ID ' + acc.EBS_ID__c + ' EBS EBS ID ' + rpAcc.ReplAccount.acc.EBS_ID__c);
                    if ( String.IsEmpty(rpAcc.ReplAccount.acc.EBS_ID__c) || 
                            rpAcc.ReplAccount.acc.EBS_ID__c == acc.EBS_ID__c ||
                            String.IsEmpty(acc.EBS_ID__c))
                    {
                        rpAcc.AccountId = acc.Id;
                        ExistSFDCIDRepAccounts.Add(rpAcc);
                        AccountsWithGoodSFDCIDs.Add(acc);
                        system.debug('Added to ExistSFDCID list ' + acc.SFDC_ID__c);
                    }
                    else
                    {
                        ReplicationMessage repMsg = new ReplicationMessage();
                        repMsg.messageId = rpAcc.ReplAccount.messageId;
                        repMsg.Result = 'FAILED'; 
                        repMsg.ResultMessage = 'Salesforce SFDC ID and EBS ID combination ' + acc.SFDC_ID__c + ' - ' + acc.EBS_ID__c + ' does not match EBS SFDC ID and EBS ID ' + rpAcc.SFDCID + ' - ' + rpAcc.ReplAccount.acc.EBS_ID__c  ;
                        repFailedMsgList.Add(repMsg);
                        //repListToProcess.Add(repMsg);   
                        // Mark this account record to be removed from processing list
                        system.debug ( 'SFDC ID ' + acc.SFDC_ID__c + ' This one added to failed one ' + i);
                        failedIndexesMap.put(acc.SFDC_ID__c, acc);
                        failedIndexes++;             
                    }
                    
                    sfdcidRepMap.remove(rpAcc.SFDCID);
                    i++;
                }
                
                for (ReplicationMessage r : repFailedMsgList)
                {
                
                    repListToProcess.add(r);
                }
            }
            
                   
           
            //// Get the EBSID list for those not found by SFDCID
            
            for (SFDCIDReplicateAccount sra : sfdcidRepAccounts)
            {
                try
                {
                    SFDCIDReplicateAccount rpAcc = sfdcidRepMap.get(sra.SFDCID);
                   
                    if (sfdcidRepMap.get(sra.SFDCID) != null)
                    {
                        EBSIDs.Add(SetEscaped(sra.EBSID));
                    }
                    
                }
                catch (Exception ex)
                {
                    
                }
            }
            List<Account> AccountsWithEBSIDs  ;        
            // Get the Accounts for the list of EBSIDs, if any
            //system.debug('what is the size of the EBSIDs ' + EBSIDs.Size());
            if ( EBSIDs.Size() > 0)
            {
                 String theQuery2 = DataHelper_PreHPP.GenerateFields(fldObjMapValues );
    
                 // Finalize query string
                 theQuery2 +=  ' FROM Account WHERE EBS_ID__c in  ' + EBSIDs ;
                
                 
                 AccountsWithEBSIDs = Database.query(theQuery2);
                      
                 if ( AccountsWithEBSIDs.Size() > 0)
                 {                                 
                     for (Account acc : AccountsWithEBSIDs)
                     {
                          SFDCIDReplicateAccount rpAcc = new SFDCIDReplicateAccount();
                          rpAcc = ebsidRepMap.get(acc.EBS_ID__c);
                          ExistEBSIDRepAccounts.Add(rpAcc); 
                          // Remove the ones we've processed from the map
                          sfdcidRepMap.Remove(rpAcc.SFDCID); 
                          ebsidRepMap.Remove(rpAcc.EBSID); 
                     }
                 }
            }
           
           
            // Get those to insert now
            List<Account> AccountsToInsert = new List<Account>();
            for (SFDCIDReplicateAccount sra : sfdcidRepAccounts)
            {
                try
                {
                    // There should only be Insertable replication records left 
                    // in this map by now as we have removed SFDCID matches, 
                    // EBSID matches and SFDC/EBS coherence failures  as we have processed them
                    
                    SFDCIDReplicateAccount rpAcc = sfdcidRepMap.get(sra.SFDCID);
                    
                    if ( rpAcc != null)
                    {
                        AccountsToInsert.Add(rpAcc.replAccount.acc);
                        sfdcidRepMap.Remove(sra.SFDCID);
                        ReplicationMessage repMsg = new ReplicationMessage();
                        repMsg.messageId = rpAcc.replAccount.messageId;
                        system.debug('Message ID ' + repMsg.messageId);
                        repMsgList.add(repMsg); 
                    }
                }
                catch (Exception ex)
                {
                    system.debug('Failed to add account somewhere ' + ex.getMessage());
                }
            }
            
            
 
            // Process the Existing SFDCID List first
            // Here is the Account List 
            // AccountsWithSFDCIDs ; ExistSFDCIDRepAccounts
           
            //List<Account> AccountsWithGoodSFDCIDs = new List<Account>();
            for (integer i = 0; i < ExistSFDCIDRepAccounts.Size() ; i++)
            {
               system.debug('Good SFDCID ' + i + ' ' + ExistSFDCIDRepAccounts[i].SFDCID);
               system.debug('What is acc stuff ? ' + failedIndexesMap.get(ExistSFDCIDRepAccounts[i].SFDCID));
               //if (failedIndexesMap.get(ExistSFDCIDRepAccounts[i].SFDCID) == null)
               //{
              //      system.debug('Good SFDCID B ' + i + ' ' + ExistSFDCIDRepAccounts[i].SFDCID);
               //     Account goodAcc = new Account();
               //     goodAcc = 
                   for (string x : fieldList)
                   {
                      AccountsWithGoodSFDCIDs[i].put(x, ExistSFDCIDRepAccounts[i].ReplAccount.acc.get(x));  
                   }
                   ReplicationMessage repMsg = new ReplicationMessage();
                       
                   repMsg.messageId = ExistSFDCIDRepAccounts[i].ReplAccount.messageId;
                   repMsgList.add(repMsg); 
                   
                   //goodAcc = AccountsWithSFDCIDs[i];
                   //AccountsWithGoodSFDCIDs.Add(goodAcc);
               //}
            }
            system.debug('Size of AccountsWithGoodSFDCIDs ' + AccountsWithGoodSFDCIds.Size());
            
            for (integer i = 0; i < ExistEBSIDRepAccounts.Size(); i++)
            {
                for (string x : fieldList)
                {
                    AccountsWithEBSIDs[i].put(x, ExistEBSIDRepAccounts[i].ReplAccount.acc.get(x));
                }
                
                ReplicationMessage repMsg = new ReplicationMessage();
                repMsg.messageId = ExistEBSIDRepAccounts[i].ReplAccount.messageId;
                system.debug('EBS Update Message id ' + repMsg.messageId);
                repMsgList.add(repMsg);               
            }
            
            Database.SaveResult[] SFDCInsertResults;
            if (AccountsToInsert != null && AccountsToInsert.Size() > 0 )
            {
                for (Account a : AccountsToInsert )
                {
                    system.debug('SFDC Insert '  + a.SFDC_ID__c + ' ' + a.EBS_ID__c);
                }
                SFDCInsertResults = Database.Insert(AccountsToInsert, false);
            }
            
            Database.SaveResult[] SFDCExistsUPResults;
            if (AccountsWithGoodSFDCIDs!= null && AccountsWithGoodSFDCIDs.Size() > 0)
            {
                for (Account a :AccountsWithGoodSFDCIDs)
                {
                    system.debug('SFDC Update ' + a.Id + ' ' + a.SFDC_ID__c + ' ' + a.EBS_ID__c);
                }
                SFDCExistsUPResults = Database.Update(AccountsWithGoodSFDCIDs, false);
            }
            
            Database.SaveResult[] EBSExistsUPResults;
            if (AccountsWithEBSIDs != null && AccountsWithEBSIDs.Size() > 0)
            {
                 for (Account a:AccountsWithSFDCIDs)
                {
                    system.debug('EBS Update ' + a.Id + ' ' + a.SFDC_ID__c + ' ' + a.EBS_ID__c);
                }
                EBSExistsUPResults = Database.Update(AccountsWithEBSIDs, false);
            }
            
            integer existSFDC = 0;
            //debug
            for(integer a = 0; a < repMsgList.Size(); a++)
            {
                system.debug('The replication message for ' + a + ' ' + repMsgList[a]);
                try
                {
                    system.debug('What is the replication message A ' + repMsgList.get(a) );
                    ReplicationMessage repMsg = repMsgList.get(a);
                    system.debug('What is the replication message B ' + repMsg );
                    
                    
                }
                catch(Exception ex)
                {
                    system.debug('Throw Exception ' + ex.getMessage());
                }
            }
            
            if (SFDCExistsUPResults != null && SFDCExistsUPResults.size() > 0)
            {
                integer i = 0;
                for ( existSFDC = 0 ; existSFDC < SFDCExistsUPResults.size() ; existSFDC++)
                {
                    Database.SaveResult du = SFDCExistsUPResults.get(i);
                    ReplicationMessage repMsg = repMsgList.get(existSFDC);
                    if (du.isSuccess())
                    {
                        repMsg.result = 'SUCCESS';
                    }
                    else 
                    {
                        repMsg.result = 'FAILED';
                        List<Database.Error> dbErr = du.getErrors();
                        Database.Error e = dbErr[0];
                        repMsg.resultMessage = e.getMessage();  
                    }
                    repListToProcess.add(repMsg);
                    i++;
                }
                
                
            }
            
            integer existEBS = 0;
            if (EBSExistsUPResults != null && EBSExistsUPResults.size() > 0)
            {
                integer i = 0;
                for (existEBS = existSFDC ; existEBS < EBSExistsUPResults.size() + existSFDC ; existEBS++)
                {
                    Database.SaveResult du = EBSExistsUPResults.get(i);
                    ReplicationMessage repMsg = repMsgList.get(existEBS);
                    if (du.isSuccess())
                    {
                        repMsg.result = 'SUCCESS';
                    }
                    else 
                    {
                        repMsg.result = 'FAILED';
                        List<Database.Error> dbErr = du.getErrors();
                        Database.Error e = dbErr[0];
                        repMsg.resultMessage = e.getMessage();  
                    }
                    repListToProcess.add(repMsg);
                    i++;
                }
                
            }
            
            integer insertSFDC = 0;
            if (SFDCInsertResults != null && SFDCInsertResults.size() > 0)
            {
                integer i = 0;
                for (insertSFDC = (existSFDC + existEBS) ; insertSFDC < SFDCInsertResults.size() + (existSFDC + existEBS) ; insertSFDC++)
                {
                    Database.SaveResult du = SFDCInsertResults.get(i);
                    ReplicationMessage repMsg = repMsgList.get(insertSFDC);
                    if (du.isSuccess())
                    {
                        repMsg.result = 'SUCCESS';
                    }
                    else 
                    {
                        repMsg.result = 'FAILED';
                        List<Database.Error> dbErr = du.getErrors();
                        Database.Error e = dbErr[0];
                        repMsg.resultMessage = e.getMessage();  
                    }
                    repListToProcess.add(repMsg);
                    i++;
                }
                
            }
            
            
           
            returnString = buildReturnString(repListToProcess);
 
        }
        else
        {
            Schema.Sobjectfield externalIdField;
            RecordType personRecType = [select id from recordType where ispersontype=true and sobjectType='account' limit 1];
            
            //Get the XML Message to use for processing the incoming XML
            XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                            x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                            Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                            (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                            From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                            From XML_Message__c x where x.Type__c = 'Inbound' and x.Name = 'ReplicateNewCustomer' 
                                            and x.Active__c = true];
            
            List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
            Map<String, String> fieldMap = new Map<String, String>();
            Map<String, String> fieldToTypeMap = new Map<String, String>();
            try {
                Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
                Schema.SObjectType whichObject = objectMap.get('Account');
                Schema.Describesobjectresult r = whichObject.getDescribe();
                Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
                
            }catch (Exception objE){
                System.debug('*** -- Error processing objects in XMLMethods.processResponseString -- ***');
                System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
                return 'FAILED';
            }
            
            for (XML_Message_Tag__c xmlTag : tagList){
                fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
                fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
            }
            
            String fieldName;
            String fieldValue;
            Map<String, String> mapFieldsToValues = new Map<String, String>();
            String decodedString;
            try {
                decodedString = EncodingUtil.urlDecode(inCustomerList, 'UTF-8');
                System.debug('*** -- DECODED STRING -- ***');
                System.debug('*** -- ' + decodedString + ' -- ***');
            }catch (Exception decodeEx){
                System.debug('*** -- Error in processCustomers decoding string -- ***');
                System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
                return 'FAILED TO DECODE WITH ' + decodeEx;
            }
            
            XmlStreamReader xsr = new XmlStreamReader(decodedString);
            //Check how many records we're processing
            integer customerCount = 0;
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    if ('ADDNEWCUSTOMERALLINFORMATION'.equalsIgnoreCase(xsr.getLocalName())){
                        customerCount++;
                    }
                }
                xsr.next();
            }
            
            System.debug('*** -- We have received ' + customerCount + ' customers -- ***');
            
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
            List<ReplicateAccount> repAccounts = new List<ReplicateAccount>();
            ReplicateAccount repAccount;
            SObject theObject;
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                    if ('ADDNEWCUSTOMERALLINFORMATION'.equalsIgnoreCase(xsr.getLocalName())){
                        System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                        //Create the new sObject
                        theObject = new Account(RecordTypeId = personRecType.Id);
                        repAccount = new ReplicateAccount();
                    }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
            
                        if (repAccount != null){
                            xsr.next();
                            if (xsr.isCharacters()){
                                System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                                repAccount.messageId = xsr.getText();
                            }
                        }   
                    }else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName())){
            
                        if (repAccount != null){
                            xsr.next();
                            if (xsr.isCharacters()){
                                System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                                repAccount.messageType = xsr.getText();
                            }
                        }   
                    }else {
                        fieldName = xsr.getLocalName();
                        System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    }
                }else if (xsr.getEventType() == XmlTag.CHARACTERS){
                        System.debug('*** -- WE HAVE A CHARACTER ELEMENT -- ***');
                        if (xsr.getText() != null){
                            fieldValue = xsr.getText();
                            System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                        }                   
                }else if (xsr.getEventType() == XmlTag.END_ELEMENT){
                    System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                    if ('ADDNEWCUSTOMERALLINFORMATION'.equalsIgnoreCase(xsr.getLocalName())){
                        
                        for (String s : fieldMap.keySet()){
                            System.debug('*** -- About to pull ' + s + ' -- ***');
                            targetField = fieldMap.get(s);
                            fieldDataType = fieldToTypeMap.get(s);
                            targetValue = mapFieldsToValues.get(s);
                            
                            if ('STRING'.equalsIgnoreCase(fieldDataType)){
                                if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                    strTargetValue = targetValue;
                                    if (targetField != null && strTargetValue != null){
                                        theObject.put(targetField, strTargetValue);
                                    }
                                }   
                            }else if ('INTEGER'.equalsIgnoreCase(fieldDataType)){
                                if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                    System.debug('*** -- targetValue For Integer= ' + targetValue + ' -- ***');
                                    try {
                                        intTargetValue = Integer.valueOf(targetValue);
                                    }catch (Exception e){
                                        intTargetValue = 0;
                                    }
                                    System.debug('*** -- targetValue = ' + intTargetValue + ' -- ***');
                                    if (targetField != null && intTargetValue != null){
                                        theObject.put(targetField, intTargetValue);
                                    }
                                }
                            }else if ('DOUBLE'.equalsIgnoreCase(fieldDataType)){
                                if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                    try {
                                        dblTargetValue = Double.valueOf(targetValue);
                                    }catch (Exception e){
                                        dblTargetValue = 0;
                                    }
                                    System.debug('*** -- targetValue = ' + dblTargetValue + ' -- ***');
                                    if (targetField != null && dblTargetValue != null){
                                        theObject.put(targetField, dblTargetValue);
                                    }
                                }
                            }else if ('DATE'.equalsIgnoreCase(fieldDataType)){
                                if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                    System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
                                    String[] dateSplit = targetValue.split('-');
                                    if (dateSplit != null && dateSplit.size() == 3){
                                        try {
                                            integer yr = integer.valueOf(dateSplit[0]);
                                            integer mth = integer.valueOf(dateSplit[1]);
                                            integer d = integer.valueOf(dateSplit[2]);
                                            dtTargetValue = Date.newInstance(yr, mth, d);
                                        }catch (Exception dateSplitEx){
                                            System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                            System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                            return dateSplitEx + ' with date ' + targetValue;
                                        }
                                    }
                                    if (dtTargetValue != null){
                                        System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
                                    }
                                    if (targetField != null && dtTargetValue != null){
                                        theObject.put(targetField, dtTargetValue);
                                    }
                                }
                            }
                            targetValue = null;
                        }
                        repAccount.acc = (Account)theObject;
                        repAccounts.add(repAccount);
                    }else {
                        mapFieldsToValues.put(fieldName, fieldValue);
                        fieldName = null;
                        fieldValue = null;
                    }
                }
                System.debug('*** -- XSR NEXT -- ***');
                xsr.next();
            }
        
            //At this point we should have a list of ReplicateAccounts ready to process
            List<Account> accsToUpsert = new List<Account>();
            List<ReplicationMessage> repMsgList = new List<ReplicationMessage>();
            List<ReplicationMessage> repListToProcess = new List<ReplicationMessage>();
            List<ReplicationMessage> failRepMsgsToProcess = new List<ReplicationMessage>();
            List<Database.Upsertresult> upResults = new List<Database.Upsertresult>();
            Map<String, String> noDupesCheck = new Map<String, String>();
            
            for (ReplicateAccount ra : repAccounts){
                Account acc = ra.acc;
                ReplicationMessage repMsg = new ReplicationMessage();
                repMsg.messageId = ra.messageId;
                if (!noDupesCheck.containsKey(acc.EBS_ID__c)){
                    accsToUpsert.add(acc);
                    noDupesCheck.put(acc.EBS_ID__c, acc.EBS_ID__c);
                    repMsgList.add(repMsg); 
                }else {
                    repMsg.result = 'FAILED';
                    repMsg.resultMessage = 'Duplicate ID in List : ' +  acc.EBS_ID__c;
                    failRepMsgsToProcess.add(repMsg);
                }
            }
            
                //upResults = Database.upsert(accsToUpsert, false);
                //externalIdField = Account.Fields.EBS_ID__c;
                externalIdField = Account.Fields.SFDC_ID__c;
                upResults = Database.upsert(accsToUpsert, externalIdField, false);
            
            if (upResults.size() > 0){
                for (integer i = 0 ; i < upResults.size() ; i++){
                    Database.Upsertresult du = upResults.get(i);
                    ReplicationMessage repMsg = repMsgList.get(i);
                    if (du.isSuccess()){
                        repMsg.result = 'SUCCESS';
                    }else {
                        repMsg.result = 'FAILED';
                        List<Database.Error> dbErr = du.getErrors();
                        Database.Error e = dbErr[0];
                        repMsg.resultMessage = e.getMessage();  
                    }
                    repListToProcess.add(repMsg);
                }
                for (ReplicationMessage r : failRepMsgsToProcess){
                    repListToProcess.add(r);
                }
            }
            
            //String returnString = buildReturnString(repListToProcess);
            returnString = buildReturnString(repListToProcess);
        }
        
        return returnString;
    }
    
    webservice static String processAccounts(String inAccountList){
        Schema.Sobjectfield externalIdField;
        //Get the XML Message to use for processing the incoming XML
        XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                        Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                        From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                        From XML_Message__c x where x.Type__c = 'Inbound' and x.Name = 'ReplicateCustomerAccount' 
                                        and x.Active__c = true];
        
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldToTypeMap = new Map<String, String>();
        try {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get('Account_with_IBB__c');
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
        }catch (Exception objE){
            System.debug('*** -- Error processing objects in XMLMethods.processResponseString -- ***');
            System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
            return 'FAILED';
        }
        
        for (XML_Message_Tag__c xmlTag : tagList){
            fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
            fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
        }
        
        String fieldName;
        String fieldValue;
        Map<String, String> mapFieldsToValues = new Map<String, String>();
        String decodedString;
        try {
            decodedString = EncodingUtil.urlDecode(inAccountList, 'UTF-8');
            System.debug('*** -- DECODED STRING -- ***');
            System.debug('*** -- ' + decodedString + ' -- ***');
        }catch (Exception decodeEx){
            System.debug('*** -- Error in processCustomers decoding string -- ***');
            System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }
        
        XmlStreamReader xsr = new XmlStreamReader(decodedString);
        //Check how many records we're processing
        integer ocaCount = 0;
        List<String> accountTypeList = new List<String>();
        List<String> customerList = new List<String>();
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('OPENCUSTOMERACCOUNT'.equalsIgnoreCase(xsr.getLocalName())){
                    ocaCount++;
                }else if ('ACCOUNTTYPE'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.getEventType() == xmlTag.CHARACTERS){
                        accountTypeList.add(xsr.getText()); 
                    }
                }else if ('CUSTOMER'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.getEventType() == xmlTag.CHARACTERS){
                        customerList.add(xsr.getText());
                    }
                }
            }
            xsr.next();
        }
        
        System.debug('*** -- We have received ' + ocaCount + ' accounts -- ***');
        System.debug('*** -- We have ' + accountTypeList.size() + ' types of products -- ***');
        System.debug('*** -- We have ' + customerList.size() + ' different customers -- ***');
        
        //List<IBB_Product__c> ibbProducts = [select Id from IBB_Product__c where EBS_Deal_Account_Type__c in :accountTypeList];
        List<IBB_Product__c> ibbProducts = [Select i.Name, i.Id, i.EBS_Deal_Account_Type__c, i.Account_Type__c From IBB_Product__c i];
        //Map<String, String> ibbProdMap = new Map<String, String>();
        //if (ibbProducts.size() > 0){
        //  for (IBB_Product__c p : ibbProducts){
        //      ibbProdMap.put(p.EBS_Deal_Account_Type__c, p.Id);
        //  }
        //}
        List<Account> customers = [select Id, EBS_ID__c from Account where EBS_ID__c in :customerList];
        Map<String, String> customerMap = new Map<String, String>();
        if (customers.size() > 0){
            for (Account a : customers){
                customerMap.put(a.EBS_ID__c, a.Id);
            }
        }
        
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
        List<ReplicateOCA> repAccounts = new List<ReplicateOCA>();
        List<Asset_Relationship__c> arsToInsert = new List<Asset_Relationship__c>();
        ReplicateOCA repOCA;
        SObject theObject;
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                if ('OPENCUSTOMERACCOUNT'.equalsIgnoreCase(xsr.getLocalName())){
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    //Create the new sObject
                    theObject = new Account_with_IBB__c();
                    repOCA = new ReplicateOCA();
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repOCA != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                            repOCA.messageId = xsr.getText();
                        }
                    }   
                }else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repOCA != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                            repOCA.messageType = xsr.getText();
                        }
                    }   
                }else {
                    fieldName = xsr.getLocalName();
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                }
            }else if (xsr.getEventType() == XmlTag.CHARACTERS){
                    System.debug('*** -- WE HAVE A CHARACTER ELEMENT -- ***');
                    if (xsr.getText() != null){
                        fieldValue = xsr.getText();
                        System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                    }                   
            }else if (xsr.getEventType() == XmlTag.END_ELEMENT){
                System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                if ('OPENCUSTOMERACCOUNT'.equalsIgnoreCase(xsr.getLocalName())){
                    
                    for (String s : fieldMap.keySet()){
                        System.debug('*** -- About to pull ' + s + ' -- ***');
                        targetField = fieldMap.get(s);
                        fieldDataType = fieldToTypeMap.get(s);
                        targetValue = mapFieldsToValues.get(s);
                        
                        if ('STRING'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                strTargetValue = targetValue;
                                if (targetField != null && strTargetValue != null){
                                    theObject.put(targetField, strTargetValue);
                                }
                            }   
                        }else if ('INTEGER'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                System.debug('*** -- targetValue For Integer= ' + targetValue + ' -- ***');
                                try {
                                    intTargetValue = Integer.valueOf(targetValue);
                                }catch (Exception e){
                                    intTargetValue = 0;
                                }
                                System.debug('*** -- targetValue = ' + intTargetValue + ' -- ***');
                                if (targetField != null && intTargetValue != null){
                                    theObject.put(targetField, intTargetValue);
                                }
                            }
                        }else if ('DOUBLE'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                try {
                                    dblTargetValue = Double.valueOf(targetValue);
                                }catch (Exception e){
                                    dblTargetValue = 0;
                                }
                                System.debug('*** -- targetValue = ' + dblTargetValue + ' -- ***');
                                if (targetField != null && dblTargetValue != null){
                                    theObject.put(targetField, dblTargetValue);
                                }
                            }
                        }else if ('DATE'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
                                String[] dateSplit = targetValue.split('-');
                                if (dateSplit != null && dateSplit.size() == 3){
                                    try {
                                        integer yr = integer.valueOf(dateSplit[0]);
                                        integer mth = integer.valueOf(dateSplit[1]);
                                        integer d = integer.valueOf(dateSplit[2]);
                                        dtTargetValue = Date.newInstance(yr, mth, d);
                                    }catch (Exception dateSplitEx){
                                        System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                        System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                        return dateSplitEx + ' with date ' + targetValue;
                                    }
                                }
                                if (dtTargetValue != null){
                                    System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
                                }
                                if (targetField != null && dtTargetValue != null){
                                    theObject.put(targetField, dtTargetValue);
                                }
                            }
                        }
                        targetValue = null;
                    }
                    //We now need to update some of the fields manually that can't be handled in code
                    Account_with_IBB__c theAccountWithIBB = (Account_with_IBB__c)theObject;
                    if (theAccountWithIBB.Name != null && theAccountWithIBB.EBS_ID__c == null){
                        theAccountWithIBB.EBS_ID__c = theAccountWithIBB.Name;
                    }
                    for (IBB_Product__c p : ibbProducts){
                        if (p.Account_Type__c == theAccountWithIBB.RepAccountType__c && p.EBS_Deal_Account_Type__c == theAccountWithIBB.RepDealAccountType__c){
                            theAccountWithIBB.IBB_Product__c = p.Id;
                        }
                    }
                    /*
                    if (theAccountWithIBB.RepAccountType__c != null){
                        theAccountWithIBB.IBB_Product__c = ibbProdMap.get(theAccountWithIBB.RepAccountType__c);
                    }
                    */
                    if (theAccountWithIBB.Primary_Customer_EBS_ID__c != null){
                        theAccountWithIBB.Primary_SFDC_Account__c = customerMap.get(theAccountWithIBB.Primary_Customer_EBS_ID__c);
                    }
                    //We now need to create an Asset_Relationship__c record to match the account with it's Primary Account Holder
                    Asset_Relationship__c newARC = new Asset_Relationship__c();
                    newARC.Account_with_IBB__c = theAccountWithIBB.Id;
                    newARC.Customer_EBS_ID__c = theAccountWithIBB.Primary_Customer_EBS_ID__c;
                    newARC.EBS_ID__c = theAccountWithIBB.EBS_ID__c + theAccountWithIBB.Primary_Customer_EBS_ID__c;
                    newARC.Prospect_Customer__c = customerMap.get(theAccountWithIBB.Primary_Customer_EBS_ID__c);
                    newARC.Primary_Account_Holder__c = true;
                    arsToInsert.add(newARC);
                    
                    System.debug('*** -- EBS ID in AccountWithIBB = ' + theAccountWithIBB.EBS_ID__c + ' -- ***');
                    repOCA.accWithIBB = theAccountWithIBB;
                    repAccounts.add(repOCA);
                }else {
                    mapFieldsToValues.put(fieldName, fieldValue);
                    fieldName = null;
                    fieldValue = null;
                }
            }
            System.debug('*** -- XSR NEXT -- ***');
            xsr.next();
        }
        
        //At this point we should have a list of ReplicateAccounts ready to process
        List<Account_with_IBB__c> accsToUpsert = new List<Account_with_IBB__c>();
        List<ReplicationMessage> repMsgList = new List<ReplicationMessage>();
        List<ReplicationMessage> repListToProcess = new List<ReplicationMessage>();
        List<ReplicationMessage> failRepMsgList = new List<ReplicationMessage>();
        List<Database.Upsertresult> upResults = new List<Database.Upsertresult>();
        Map<String, String> noDupesCheck = new Map<String, String>();
        
        
        for (ReplicateOCA roca : repAccounts){
            Account_with_IBB__c acc = roca.accWithIBB;
            ReplicationMessage repMsg = new ReplicationMessage();
            repMsg.messageId = roca.messageId;
            if (!noDupesCheck.containsKey(acc.EBS_ID__c)){
                accsToUpsert.add(acc);
                noDupesCheck.put(acc.EBS_ID__c, acc.EBS_ID__c); 
                repMsgList.add(repMsg);
            }else {
                repMsg.result = 'FAILED';
                repMsg.resultMessage = 'Duplicate ID in List : ' +  acc.EBS_ID__c;
                failRepMsgList.add(repMsg);
            }
        }
            
            externalIdField = Account_with_IBB__c.Fields.EBS_ID__c;
            upResults = Database.upsert(accsToUpsert, externalIdField, false);
            //upResults = Database.upsert(accsToUpsert, false);

        if (upResults.size() > 0){
            for (integer i = 0 ; i < upResults.size() ; i++){
                Database.Upsertresult du = upResults.get(i);
                ReplicationMessage repMsg = repMsgList.get(i);
                if (du.isSuccess()){
                    repMsg.result = 'SUCCESS';
                }else {
                    repMsg.result = 'FAILED';
                    List<Database.Error> dbErr = du.getErrors();
                    Database.Error e = dbErr[0];
                    repMsg.resultMessage = e.getMessage();  
                }
                repListToProcess.add(repMsg);
            }
            for (ReplicationMessage r : failRepMsgList){
                repListToProcess.add(r);
            }
        }
        
        try {
            insert arsToInsert;
        }catch (DMLException dmlEx){
            System.debug('*** -- Unable to insert Primary Customer Asset Relationships -- ***');
        }
        
        String returnString = buildReturnString(repListToProcess);
        
        return returnString;
        
    }
    
    webservice static String processJAR(String inJARList){
        Map<String, Account> accMap = new Map<String, Account>();
        Map<String, Account_with_IBB__c> accWithIBBMap = new Map<String, Account_with_IBB__c>();
        Map<String, Asset_Relationship__c> arMap = new Map<String, Asset_Relationship__c>();
        List<Asset_Relationship__c> existingARList = new List<Asset_Relationship__c>();
        String fieldName;
        String fieldValue;
        Map<String, String> mapFieldsToValues = new Map<String, String>();
        String decodedString;
        try {
            decodedString = EncodingUtil.urlDecode(inJARList, 'UTF-8');
            System.debug('*** -- DECODED STRING -- ***');
            System.debug('*** -- ' + decodedString + ' -- ***');
        }catch (Exception decodeEx){
            System.debug('*** -- Error in processCustomers decoding string -- ***');
            System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }
        
        XmlStreamReader xsr = new XmlStreamReader(decodedString);
        //Check how many records we're processing and pull out the relevant Account IDs (to get Account_with_IBB__c objects)
        //and the relevant JoiningCustomer IDs (to get the Account objects)
        integer jarCount = 0;
        List<String> accIds = new List<String>();
        List<String> joiningCustomerIds = new List<String>();
        List<String> jarExternalIds = new List<String>();
        String jarExId;
        
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('ADDJOINTRELATIONSHIP'.equalsIgnoreCase(xsr.getLocalName())){
                    jarCount++;
                }else if ('ACCTNO'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.getEventType() == XmlTag.CHARACTERS){
                        accIds.add(xsr.getText());
                        jarExId = xsr.getText();
                    }
                }else if ('JOININGCUSTOMER'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.getEventType() == XmlTag.CHARACTERS){
                        joiningCustomerIds.add(xsr.getText());
                        if (jarExId != null){
                            jarExId = jarExId + xsr.getText();
                        }
                        System.debug('*** -- External IDs - adding ' + jarExId + ' -- ***');
                        jarExternalIds.add(jarExId);
                        jarExId = null;
                    }
                }
            }
            xsr.next();
        }
        
        //Build a list of existing Asset_Relationship__c records in case we need to delete any
        //using the list of Joining Customer IDs - the key in the map will be JoiningCustomer ID + _ + AccountWithIBB ID
        existingARList = [Select a.Relationship_To_Primary_Applicant1__c, a.Customer_EBS_ID__c, a.Account_with_IBB_Number__c, 
                            a.EBS_ID__c From Asset_Relationship__c a where a.EBS_ID__c in : jarExternalIds];
        
        for (Asset_Relationship__c ar : existingARList){
            System.debug('*** -- Putting ' + ar.EBS_ID__c + ' -- ***');
            arMap.put(ar.EBS_ID__c, ar);
        }
        
        System.debug('*** -- We have received ' + jarCount + ' JARs -- ***');
        System.debug('*** -- We have found ' + existingARList.size() + ' existing AR records-- ***');
        System.debug('*** -- Which hold ' + accIds.size() + ' AcctNo IDs -- ***');
        System.debug('*** -- And ' + joiningCustomerIds.size() + ' JoiningCustomer IDs -- ***');
        
        //Now we need a map of Account_with_IBB__c objects and Account objects
        List<Account> accList = [select Id, EBS_ID__c, Relationship_To_Primary_Applicant__c from Account where EBS_ID__c in :joiningCustomerIds];
        List<Account_with_IBB__c> accWithIBBList = [select Id, Name from Account_with_IBB__c where Name in :accIds];
        
        if (accList.size() == 0 || accWithIBBList.size() == 0){
            System.debug('*** -- No Accounts or Account_with_IBBs found - Exiting... -- ***');
            //We now need to return a correctly formed error
            
        }
        
        for (Account a : accList){
            accMap.put(a.EBS_ID__c, a);
        }
        for (Account_with_IBB__c a : accWithIBBList){
            accWithIBBMap.put(a.Name, a);
        }       
        
        
        //Do the work
        xsr = new XmlStreamReader(decodedString);
        String targetField;
        String targetValue;
        String fieldDataType;
        String strTargetValue;
        integer intTargetValue;
        Date dtTargetValue;
        double dblTargetValue;
        List<Asset_Relationship__c> objectsToUpsert = new List<Asset_Relationship__c>();
        List<Account> accountsToUpdate = new List<Account>();
        List<ReplicateJAR> repJars = new List<ReplicateJAR>();
        ReplicateJAR repJar;
        Boolean doDelete = false;
        String keyAccount;
        String keyCustomer;
        String keyRelationship;
        Asset_Relationship__c theObject;
        String workingAccNo;
        String workingCustNo;
        Account theAccount;
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                System.debug('*** -- WE HAVE A START ELEMENT - ' + xsr.getLocalName() + '-- ***');
                if ('ADDJOINTRELATIONSHIP'.equalsIgnoreCase(xsr.getLocalName())){
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    //Create the new sObject
                    repJAR = new ReplicateJAR();
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repJAR != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                            repJAR.messageId = xsr.getText();
                        }
                    }   
                }else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repJAR != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                            repJAR.messageType = xsr.getText();
                        }
                    }   
                }else if ('REPLICATIONTYPE'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repJAR != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND REPLICATIONTYPE = ' + xsr.getText() + ' -- ***');
                            repJAR.replicationType = xsr.getText();
                            if ('*DELETE'.equalsIgnoreCase(xsr.getText())){
                                doDelete = true;
                                System.debug('*** -- doDelete is ' + doDelete + ' -- ***');
                            }else {
                                System.debug('*** -- ABOUT TO CREATE OBJECT -- ***');
                                try {
                                    theObject = new Asset_Relationship__c();
                                }catch (Exception e){
                                    System.debug('*** -- ERROR: ' + e + ' -- ***');
                                }
                                if (theObject == null) System.debug('*** -- OBJECT NOT CREATED -- ***');
                            }
                        }
                    }   
                }else if ('ACCTNO'.equalsIgnoreCase(xsr.getLocalName())){
                    System.debug('*** -- doDelete = ' + doDelete + ' -- ***');
                    if (theObject != null) System.debug('*** -- Object is there -- ***');
                    
                    if (!doDelete){
                        if (theObject != null){
                            xsr.next();
                            if (xsr.isCharacters()){
                                System.debug('*** -- FOUND ACCTNO = ' + xsr.getText() + ' -- ***');
                                keyAccount = xsr.getText();
                                workingAccNo = keyAccount;
                                Account_with_IBB__c aw = accWithIBBMap.get(xsr.getText());
                                if (aw != null){
                                    System.debug('*** -- Found Account With IBB ' + aw.Id + ' -- ***');
                                    if (aw != null) theObject.Account_with_IBB__c = aw.Id;
                                    
                                } 
                            }
                        }   
                    }else {
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND ACCTNO = ' + xsr.getText() + ' -- ***');
                            keyAccount = xsr.getText();
                            workingAccNo = keyAccount;
                        }
                    }
                }else if ('JOININGCUSTOMER'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (!doDelete){
                        if (theObject != null){
                            xsr.next();
                            if (xsr.isCharacters()){
                                System.debug('*** -- FOUND JOININGCUSTOMER = ' + xsr.getText() + ' -- ***');
                                keyCustomer = xsr.getText();
                                workingCustNo = keyCustomer;
                                Account a = accMap.get(xsr.getText());
                                theAccount = accMap.get(xsr.getText());
                                if (a != null){
                                    System.debug('*** -- Found theAccount ' + a.Id + ' -- ***');
                                    theObject.Prospect_Customer__c = a.Id;
                                    theObject.Customer_EBS_ID__c = xsr.getText();
                                } 
                            }
                        }
                    }else {
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND JOININGCUSTOMER = ' + xsr.getText() + ' -- ***');
                            keyCustomer = xsr.getText();
                            theAccount = accMap.get(xsr.getText());
                        }
                    }   
                }else if ('JOINTRELATIONSHIP'.equalsIgnoreCase(xsr.getLocalName())){
                    if (!doDelete){
                        if (theObject != null){
                            xsr.next();
                            if (xsr.isCharacters()){
                                System.debug('*** -- FOUND JOINTRELATIONSHIP = ' + xsr.getText() + ' -- ***');
                                keyRelationship = xsr.getText();
                                if (theAccount != null){
                                    System.debug('*** -- Found theAccount ' + theAccount.Id + ' -- ***');
                                    theAccount.Relationship_To_Primary_Applicant__c = xsr.getText(); 
                                    theObject.Relationship_To_Primary_Applicant1__c = xsr.getText();                               
                                } 
                            }
                        }   
                    }else {
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND JOINTRELATIONSHIP = ' + xsr.getText() + ' -- ***');
                            keyRelationship = xsr.getText();
                        }   
                    }
                }               
            }else if (xsr.getEventType() == XmlTag.END_ELEMENT){
                System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                if ('ADDJOINTRELATIONSHIP'.equalsIgnoreCase(xsr.getLocalName())){
                    if (doDelete){
                        String keyLookupString = keyAccount + keyCustomer;
                        System.debug('*** -- keyLookupString = ' + keyLookupString + ' -- ***');
                        repJar.relationship = keyRelationship;
                        theObject = (Asset_Relationship__c)arMap.get(keyLookupString);
                        if (theObject == null) System.debug('*** -- No Object found to delete -- ***');
                    }else {
                        String externalIdString = keyAccount + keyCustomer;
                        if (theObject != null) theObject.EBS_ID__c = externalIdString;
                    }
                    repJar.ar = theObject;
                    repJar.acc = theAccount;
                    repJars.add(repJar);
                    doDelete = false;
                    keyCustomer = null;
                    keyAccount = null;
                    keyRelationship = null;
                    theObject = null;
                }
            }
            System.debug('*** -- XSR NEXT -- ***');
            xsr.next();
        }
        
        //At this point we should have a list of ReplicateAccounts ready to process
        List<Asset_Relationship__c> arToInsert = new List<Asset_Relationship__c>();
        List<Account> accToUpdate = new List<Account>();
        List<Asset_Relationship__c> arToDelete = new List<Asset_Relationship__c>();
        List<ReplicationMessage> updateRepMsgList = new List<ReplicationMessage>();
        List<ReplicationMessage> deleteRepMsgList = new List<ReplicationMessage>();
        List<ReplicationMessage> repListToProcess = new List<ReplicationMessage>();
        List<ReplicationMessage> delRepListToProcess = new List<ReplicationMessage>();
        List<ReplicationMessage> failRepMsgList = new List<ReplicationMessage>();
        List<Database.SaveResult> insertResults = new List<Database.SaveResult>();
        List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
        List<Database.Deleteresult> deleteResults = new List<Database.Deleteresult>();
        Map<String, String> noDupesCheck = new Map<String, String>();
        
        //We are going to have to do two loops for the replication messages
        //one for INSERTS and one for DELETES
        // *** DELETE FIRST ***
        for (ReplicateJAR rj : repJars){
            Asset_Relationship__c ar = rj.ar;
            Account acc = rj.acc;
            if ('*DELETE'.equalsIgnoreCase(rj.replicationType)){
                ReplicationMessage repMsg = new ReplicationMessage();
                repMsg.messageId = rj.messageId;
                if (ar == null){
                    repMsg.result = 'FAILED';
                    repMsg.resultMessage = 'DELETE: JAR Not Found : ' + rj.relationship;
                    failRepMsgList.add(repMsg);
                }else {
                    arToDelete.add(ar);
                    deleteRepMsgList.add(repMsg);
                }
            }
        }
        System.debug('*** -- About to delete ' + arToDelete.size() + ' Asset Relationships -- ***');
        deleteResults = Database.delete(arToDelete, false);
        if (deleteResults.size() > 0){
            for (integer i = 0 ; i < deleteResults.size() ; i++){
                Database.DeleteResult dr = deleteResults.get(i);
                ReplicationMessage repMsg = deleteRepMsgList.get(i);
                if (dr.isSuccess()){
                    System.debug('*** -- Asset Relationship Delete for ' + dr.getId() + ' was a success -- ***');
                    repMsg.result = 'SUCCESS';
                }else {
                    System.debug('*** -- Asset Relationship Delete FAILED -- ***');
                    repMsg.result = 'FAILED';
                    List<Database.Error> dbErr = dr.getErrors();
                    Database.Error e = dbErr[0];
                    repMsg.resultMessage = e.getMessage();  
                }
                delRepListToProcess.add(repMsg);
                for (ReplicationMessage r : failRepMsgList){
                    delRepListToProcess.add(r);
                }
            }
        }
        
        // *** UPDATE NEXT ***
        failRepMsgList = new List<ReplicationMessage>();
        for (ReplicateJAR rj : repJars){
            Asset_Relationship__c ar = rj.ar;
            if(ar != null){
                System.debug('*** -- WE HAVE AN ASSET RECORD -- ***');
            }
            Account acc = rj.acc;
            if (!'*DELETE'.equalsIgnoreCase(rj.replicationType)){
                System.debug('*** -- ADD ASSET RECORD TO INSERT LIST-- ***');
                ReplicationMessage repMsg = new ReplicationMessage();
                repMsg.messageId = rj.messageId;
                if (acc == null){
                    repMsg.result = 'FAILED';
                    if (acc == null) repMsg.resultMessage = 'UPDATE: ACC Not Found : ' + rj.relationship;
                    failRepMsgList.add(repMsg);
                }else {
                    arToInsert.add(ar);
                    if (!noDupesCheck.containsKey(acc.Id)){
                        accToUpdate.add(acc);
                        noDupesCheck.put(acc.Id, acc.Id);   
                    }
                    updateRepMsgList.add(repMsg);   
                }
                
            }
        }
        
        System.debug('*** -- About to insert ' + arToInsert.size() + ' Asset Relationships -- ***');
        for (Asset_Relationship__c arCheck : arToInsert){
            System.debug('*** -- arCheck -- ***');
            if (arCheck == null) System.debug('*** -- IS NULL -- ***');
            if (arCheck != null) System.debug('*** -- IS AN OBJECT -- ***');
        }
        insertResults = Database.insert(arToInsert, false);

        if (insertResults.size() > 0){
            for (integer i = 0 ; i < insertResults.size() ; i++){
                Database.SaveResult inr = insertResults.get(i);
                ReplicationMessage repMsg = updateRepMsgList.get(i);
                if (inr.isSuccess()){
                    System.debug('*** -- Asset Relationship Insert for ' + inr.getId() + ' was a success -- ***');
                    repMsg.result = 'SUCCESS';
                }else {
                    System.debug('*** -- Asset Relationship Insert FAILED -- ***');
                    repMsg.result = 'FAILED';
                    List<Database.Error> dbErr = inr.getErrors();
                    Database.Error e = dbErr[0];
                    repMsg.resultMessage = e.getMessage();  
                }
                repListToProcess.add(repMsg);
            }
        }
        
        List<ReplicationMessage> repListToProcessAcc = new List<ReplicationMessage>();
        if (accToUpdate.size() > 0 && accToUpdate[0] != null){
            System.debug('*** -- About to update ' + accToUpdate.size() + ' Accounts -- ***');
            updateResults = Database.update(accToUpdate, false);
            if (updateResults.size() > 0){
                for (integer i = 0 ; i < updateResults.size() ; i++){
                    Database.SaveResult upr = updateResults.get(i);
                    ReplicationMessage repMsg = updateRepMsgList.get(i);
                    if (upr.isSuccess()){
                        repMsg.result = 'SUCCESS';
                    }else {
                        repMsg.result = 'FAILED';
                        List<Database.Error> dbErr = upr.getErrors();
                        Database.Error e = dbErr[0];
                        repMsg.resultMessage = e.getMessage();  
                    }
                    repListToProcessAcc.add(repMsg);
                }
                for (ReplicationMessage r : failRepMsgList){
                        repListToProcessAcc.add(r);
                }
            }
        }
        
        for (ReplicationMessage r : delRepListToProcess){
            repListToProcessAcc.add(r);
        }
        
        
        String returnString = buildReturnString(repListToProcessAcc);
        
        return returnString;
    }
    
    webservice static String processBalanceUpdates(String inBalanceUpdateList){
        //Get the XML Message to use for processing the incoming XML
        XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                        Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                        From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                        From XML_Message__c x where x.Type__c = 'Inbound' and x.Name = 'ReplicateBalanceRefresh' 
                                        and x.Active__c = true];
        
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldToTypeMap = new Map<String, String>();
        try {
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            Schema.SObjectType whichObject = objectMap.get('Account_with_IBB__c');
            Schema.Describesobjectresult r = whichObject.getDescribe();
            Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
        }catch (Exception objE){
            System.debug('*** -- Error processing objects in XMLMethods.processResponseString -- ***');
            System.debug('*** -- Error: ' + objE + ' at line ' + objE.getLineNumber() + '-- ***');
            return 'FAILED';
        }
        
        for (XML_Message_Tag__c xmlTag : tagList){
            fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
            fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
        }
        
        String fieldName;
        String fieldValue;
        Map<String, String> mapFieldsToValues = new Map<String, String>();
        String decodedString;
        try {
            decodedString = EncodingUtil.urlDecode(inBalanceUpdateList, 'UTF-8');
            System.debug('*** -- DECODED STRING -- ***');
            System.debug('*** -- ' + decodedString + ' -- ***');
        }catch (Exception decodeEx){
            System.debug('*** -- Error in processCustomers decoding string -- ***');
            System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }
        
        XmlStreamReader xsr = new XmlStreamReader(decodedString);
        //Check how many records we're processing
        integer brCount = 0;
        List<String> accountList = new List<String>();
        List<String> customerList = new List<String>();
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('SALESFORCEACCOUNTBALANCEREFRESH'.equalsIgnoreCase(xsr.getLocalName())){
                    brCount++;
                }else if ('ACCTNO'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.getEventType() == xmlTag.CHARACTERS){
                        accountList.add(xsr.getText()); 
                    }
                }
            }
            xsr.next();
        }
        
        System.debug('*** -- We have received ' + brCount + ' balance refreshes -- ***');
        System.debug('*** -- We have ' + accountList.size() + ' accounts to update -- ***');
        
        Map<String, Account_with_IBB__c> accounts = getAccountsWithIBB(accountList);
        
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
        List<ReplicateBalanceUpdate> repBAs = new List<ReplicateBalanceUpdate>();
        ReplicateBalanceUpdate repBA;
        SObject theObject;
        String workingAccNo;
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                if ('SALESFORCEACCOUNTBALANCEREFRESH'.equalsIgnoreCase(xsr.getLocalName())){
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                    //Create the new sObject
                    repBA = new ReplicateBalanceUpdate();
                }else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repBA != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                            repBA.messageId = xsr.getText();
                        }
                    }   
                }else if ('MESSAGETYPE'.equalsIgnoreCase(xsr.getLocalName())){
        
                    if (repBA != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
                            repBA.messageType = xsr.getText();
                        }
                    }   
                }else if ('ACCTNO'.equalsIgnoreCase(xsr.getLocalName())){
                    if (repBA != null){
                        xsr.next();
                        if (xsr.isCharacters()){
                            System.debug('*** -- FOUND ACCTNO = ' + xsr.getText() + ' -- ***');
                            workingAccNo = xsr.getText();
                            theObject = (Account_with_IBB__c)accounts.get(xsr.getText());
                        }
                    }   
                }else {
                    fieldName = xsr.getLocalName();
                    System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
                }
            }else if (xsr.getEventType() == XmlTag.CHARACTERS){
                    System.debug('*** -- WE HAVE A CHARACTER ELEMENT -- ***');
                    if (xsr.getText() != null){
                        fieldValue = xsr.getText();
                        System.debug('*** -- fieldValue = ' + fieldValue + ' -- ***');
                    }                   
            }else if (xsr.getEventType() == XmlTag.END_ELEMENT){
                System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                if ('SALESFORCEACCOUNTBALANCEREFRESH'.equalsIgnoreCase(xsr.getLocalName())){
                    
                    for (String s : fieldMap.keySet()){
                        System.debug('*** -- About to pull ' + s + ' -- ***');
                        targetField = fieldMap.get(s);
                        fieldDataType = fieldToTypeMap.get(s);
                        targetValue = mapFieldsToValues.get(s);
                        
                        if ('STRING'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                strTargetValue = targetValue;
                                if (targetField != null && strTargetValue != null){
                                    if (theObject != null) theObject.put(targetField, strTargetValue);
                                }
                            }   
                        }else if ('INTEGER'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                System.debug('*** -- targetValue For Integer= ' + targetValue + ' -- ***');
                                try {
                                    intTargetValue = Integer.valueOf(targetValue);
                                }catch (Exception e){
                                    intTargetValue = 0;
                                }
                                System.debug('*** -- targetValue = ' + intTargetValue + ' -- ***');
                                if (targetField != null && intTargetValue != null){
                                    if (theObject != null) theObject.put(targetField, intTargetValue);
                                }
                            }
                        }else if ('DOUBLE'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                try {
                                    dblTargetValue = Double.valueOf(targetValue);
                                }catch (Exception e){
                                    dblTargetValue = 0;
                                }
                                System.debug('*** -- targetValue = ' + dblTargetValue + ' -- ***');
                                if (targetField != null && dblTargetValue != null){
                                    if (theObject != null) theObject.put(targetField, dblTargetValue);
                                }
                            }
                        }else if ('DATE'.equalsIgnoreCase(fieldDataType)){
                            if (targetValue != null && targetValue != '' && targetValue.trim().length() > 0){
                                System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
                                String[] dateSplit = targetValue.split('-');
                                if (dateSplit != null && dateSplit.size() == 3){
                                    try {
                                        integer yr = integer.valueOf(dateSplit[0]);
                                        integer mth = integer.valueOf(dateSplit[1]);
                                        integer d = integer.valueOf(dateSplit[2]);
                                        dtTargetValue = Date.newInstance(yr, mth, d);
                                    }catch (Exception dateSplitEx){
                                        System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                        System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                        return dateSplitEx + ' with date ' + targetValue;
                                    }
                                }
                                if (dtTargetValue != null){
                                    System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
                                }
                                if (targetField != null && dtTargetValue != null){
                                    if (theObject != null) theObject.put(targetField, dtTargetValue);
                                }
                            }
                        }
                        targetValue = null;
                    }
                    if (theObject != null) repBA.accWithIBB = (Account_with_IBB__c)theObject;
                    if (theObject == null) repBA.accountNo = workingAccNo;
                    repBAs.add(repBA);
                }else {
                    mapFieldsToValues.put(fieldName, fieldValue);
                    fieldName = null;
                    fieldValue = null;
                }
            }
            System.debug('*** -- XSR NEXT -- ***');
            xsr.next();
        }
    
        //At this point we should have a list of ReplicateBAs ready to process
        List<Account_with_IBB__c> accsToUpdate = new List<Account_with_IBB__c>();
        List<ReplicationMessage> repMsgList = new List<ReplicationMessage>();
        List<ReplicationMessage> failedRepMsgList = new List<ReplicationMessage>();
        List<ReplicationMessage> repListToProcess = new List<ReplicationMessage>();
        List<Database.Saveresult> upResults = new List<Database.Saveresult>();
        Map<String, String> noDupesCheck = new Map<String, String>();
        
        for (ReplicateBalanceUpdate rb : repBAs){
            Account_with_IBB__c accWithIBB = rb.accWithIBB;
            if (accWithIBB != null){
                if (!noDupesCheck.containsKey(accWithIBB.Id)){
                    accsToUpdate.add(accWithIBB);
                    noDupesCheck.put(accWithIBB.Id, accWithIBB.Id);
                }
            }
            ReplicationMessage repMsg = new ReplicationMessage();
            repMsg.messageId = rb.messageId;
            if (accWithIBB == null){
                repMsg.result = 'FAILED';
                repMsg.resultMessage = 'Account Not Found : ' + rb.accountNo;
                failedRepMsgList.add(repMsg);
            }else {
                repMsgList.add(repMsg);
            }
        }
        
            upResults = Database.update(accsToUpdate, false);

        if (upResults.size() > 0){
            for (integer i = 0 ; i < upResults.size() ; i++){
                Database.Saveresult sr = upResults.get(i);
                ReplicationMessage repMsg = repMsgList.get(i);
                if (sr.isSuccess()){
                    repMsg.result = 'SUCCESS';
                }else {
                    repMsg.result = 'FAILED';
                    List<Database.Error> dbErr = sr.getErrors();
                    Database.Error e = dbErr[0];
                    repMsg.resultMessage = e.getMessage();  
                }
                repListToProcess.add(repMsg);
            }
        }
        for (ReplicationMessage r : failedRepMsgList){
            repListToProcess.add(r);
        }
        String returnString = buildReturnString(repListToProcess);
    
        return returnString;
    }
    
    webservice static String processCases(String inCases)
    {
        string messageId;
        string messageType;
        string returnString;
        
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
                                        and x.Name = 'CreateExternalCase' 
                                        and x.Active__c = true];
        
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, String> fieldToTypeMap = new Map<String, String>();
        //try 
        //{
        //    Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        //    Schema.SObjectType whichObject = objectMap.get('Valuation_Report__c');
        //    Schema.Describesobjectresult r = whichObject.getDescribe();
        //    Map<String, Schema.SObjectField> objectFieldMap = r.fields.getMap();
            
        //}
        //catch (Exception objE)
        //{
        //    return 'FAILED';
        //}
        
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
        
       
        String decodedString;
        try 
        {
            decodedString = EncodingUtil.urlDecode(inCases, 'UTF-8');
           
        }
        catch (Exception decodeEx)
        {
           
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }
        
        string fieldName;
        
        XmlStreamReader xsr = new XmlStreamReader(decodedString);
        //Check how many records we're processing
        integer caseCount = 0;
        while (xsr.hasNext())
        {
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                if ('CreateSFDCCase'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    caseCount++;
                }
            }
            xsr.next();
        }    
        System.debug('*** -- We have received ' + caseCount + ' cases -- ***');
        
        //Do the work
        xsr = new XmlStreamReader(decodedString);
    
        
        CaseDirector caseDir = new CaseDirector();
        List<CaseDirector.ExternalCase> cases = new List<CaseDirector.ExternalCase>();
        
       
        CaseDirector.ExternalCase extCase;
        while (xsr.hasNext())
        {
           
            if (xsr.getEventType() == XmlTag.START_ELEMENT)
            {
                System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                if ('CreateSFDCCase'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    System.debug('*** -- FOUND CreateSFDCCase = ' + xsr.getLocalName() + ' -- ***');
                    extCase = new CaseDirector.ExternalCase();
                    System.debug ('Got a new Case  ' + extCase);
                    
                }
                else if ('MESSAGEID'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if (xsr.isCharacters())
                    {
                        System.debug('*** -- FOUND MESSAGID = ' + xsr.getText() + ' -- ***');
                        messageId = xsr.getText();
                        system.debug ('This is the messageId ' + messageId);
                        system.debug ('This is the case ' + extCase);
                        extCase.ExternalCaseReferenceID = messageId;
                        system.debug ( 'We here ' + extCase);
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
                else if ('CUSTNO'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.EBSCustomerID = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.EBSCustomerID + ' -- ***');
                    }
                }
                else if ('CASEDIRECTORCODE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.CaseDirectorCode = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.CaseDirectorCode + ' -- ***');
                    }
                }
                else if ('CASEDESCRIPTION'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.CaseDirectorDescription = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.CaseDirectorDescription + ' -- ***');
                    }
                }
                
                else if ('CASESUBJECT'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.CaseDirectorSubject = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.CaseDirectorSubject + ' -- ***');
                    }
                }
                else if ('CASEUSER'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.EBSUserID = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.EBSUserID + ' -- ***');
                    }
                }
                else if ('CASEPRIORITY'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.CaseDirectorPriority = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.CaseDirectorPriority + ' -- ***');
                    }
                }
                else if ('CASESTATUS'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.CaseDirectorStatus = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.CaseDirectorStatus + ' -- ***');
                    }
                }
                else if ('CASEQUEUE'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    xsr.next();
                    if ( xsr.isCharacters())
                    {
                        extCase.CaseDirectorQueue = xsr.getText();
                        System.debug('*** -- FOUND = ' + extCase.CaseDirectorQueue + ' -- ***');
                    }
                }
                
                else 
                {
                    fieldName = xsr.getLocalName();
                    System.debug('*** -- DEFAULT FOUND = ' + xsr.getLocalName() + ' -- ***');
                    
                }
            }
            else if (xsr.getEventType() == XmlTag.END_ELEMENT)
            {
                System.debug('*** -- WE HAVE AN END ELEMENT -- ***');
                System.debug('*** -- END ELEMENT ' + xsr.getLocalName() + ' -- ***');
                system.debug ( 'This is the case at the end ' + extCase);
                if ('CreateSFDCCase'.equalsIgnoreCase(xsr.getLocalName()))
                {
                   system.debug ('Adding case ' + extCase);
                   cases.Add (extCase);
                }
            }
            else 
            {
                
                    
            }
            
            System.debug('*** -- XSR NEXT -- ***');
            xsr.next();
        }
        system.debug ( 'We here now ? ' + cases);
        caseDir.ExternalCases = cases;
        caseDir.CreateExternalCases ();
        List<ReplicationMessage> repListToProcess = new List<ReplicationMessage>();
        for (CaseDirector.ExternalCaseResponse resp : caseDir.ExternalCaseResponses)
        {
            ReplicationMessage repMsg = new ReplicationMessage();
            repMsg.messageID = resp.CaseMessageID;
            repMsg.result = resp.CaseInsertResult;
            repMsg.resultMessage = resp.CaseInsertResultMessage;
            repListToProcess.add (repMsg);
        }
        
        returnString = buildReturnString(repListToProcess);
        
        system.debug('The Case List ' + inCases);
        system.debug('The returnMessage ' + returnString);
        //returnString = '<BrokerReportResponse><MessageID>' + messageId + '</MessageID>';
        //returnString = returnString + '<MessageType>' + messageType + '</MessageType>';
        //returnString = returnString + '<LenderReference>' + lenderRef+ '</LenderReference>';
        //returnString = returnString + '<NotificationType>' + notificationType + '</NotificationType>';
        //returnString = returnString + '<ResponseStatus>' + returnStatus + '</ResponseStatus>';
        //returnString = returnString + '<GeneralComments>' + returnMsg + '</GeneralComments>';
        //returnString = returnString + '</BrokerReportResponse>';
        return returnString;
    }
    
     /* C00103 */
    webservice static String processDeleteAccounts (String inDeleteAccounts)
    {
        system.debug ( 'This is the request ' + inDeleteAccounts );
        
        string decodedMessage = EncodingUtil.urlDecode (inDeleteAccounts, 'UTF-8');
        
        system.debug ( 'This is the decoded request ' + decodedMessage);
        //integer acctCount = SFDCReplicator_Helper.GetRecordCount('AccountNo', decodedMessage);
        
        // Get the Account Numbers from Message
        // Store the Message IDs in Replication message
        // Get the Account with IBB records from Account Numbers, with the requisite JARS and Opportunities
        // Remove the JARS, update the Opportunity (remove link ) and remove the Account with IBB record
        // Capture results of each transaction and relate to Replication message list
        // assemble the results into reponse message
        
        string rtv = '<ReplicationResponseMessage>';
        
        sfDCReplicator_Helper repProcess = new SFDCReplicator_Helper (decodedMessage, false);
        
        
        for ( SFDCReplicator_Helper.theAccountToUpdate acct : repProcess.theFinalAccountsToUpdateList )
        {
            rtv = rtv + '<ReplicationMessage>';
            rtv = rtv + '<MessageID>' + acct.theRepMsg.messageId + '</MessageID>';
            rtv = rtv + '<Result>' + acct.theRepMsg.result + '</Result>';
            string msg; 
            if (acct.theRepMsg.resultMessage == 'null' || String.IsEmpty (acct.theRepMsg.resultMessage))
            {    
                msg = 'SUCCESS';
            }
            else
            {
                msg = acct.theRepMsg.resultMessage;
            }
            
            rtv = rtv + '<ResultMessage>' + msg + '</ResultMessage>';
            rtv = rtv + '</ReplicationMessage>';
        }
        
        return rtv + '</ReplicationResponseMessage>';
        
        /*
        


        string rtv = '';
        <ReplicationMessage><MessageID>';
        rtv = rtv + '987654321</MessageID><Result>FAILED</Result><ResultMessage>';
        rtv = rtv + 'Record Type ID: this ID value isnt valid for the user</ResultMessage></ReplicationMessage>';
        rtv = rtv + '</ReplicationResponseMessage>';
        return rtv;
        */
    }
    
    webservice static String processReplaceAccounts (String inDeleteAccounts)
    {
        system.debug ( 'This is the request ' + inDeleteAccounts );
        
        string decodedMessage = EncodingUtil.urlDecode (inDeleteAccounts, 'UTF-8');
        
        system.debug ( 'This is the decoded request ' + decodedMessage);
        //integer acctCount = SFDCReplicator_Helper.GetRecordCount('AccountNo', decodedMessage);
        
        // Get the Account Numbers from Message
        // Store the Message IDs in Replication message
        // Get the Account with IBB records from Account Numbers, with the requisite JARS and Opportunities
        // Remove the JARS, update the Opportunity (remove link ) and remove the Account with IBB record
        // Capture results of each transaction and relate to Replication message list
        // assemble the results into reponse message
        
        string rtv = '<ReplicationResponseMessage>';
        
        sfDCReplicator_Helper repProcess = new SFDCReplicator_Helper (decodedMessage, true);
        
        for ( SFDCReplicator_Helper.theAccountToUpdate acct : repProcess.theFinalAccountsToUpdateList )
        {
            rtv = rtv + '<ReplicationMessage>';
            rtv = rtv + '<MessageID>' + acct.theRepMsg.messageId + '</MessageID>';
            rtv = rtv + '<Result>' + acct.theRepMsg.result + '</Result>';
            string msg;
             if (acct.theRepMsg.resultMessage == 'null' || String.IsEmpty (acct.theRepMsg.resultMessage))
            {    
                msg = 'SUCCESS';
            }
            else
            {
                msg = acct.theRepMsg.resultMessage;
            }
            
            rtv = rtv + '<ResultMessage>' + msg + '</ResultMessage>';
            rtv = rtv + '</ReplicationMessage>';
        }
        
        return rtv + '</ReplicationResponseMessage>';
        
        /*
        


        string rtv = '';
        <ReplicationMessage><MessageID>';
        rtv = rtv + '987654321</MessageID><Result>FAILED</Result><ResultMessage>';
        rtv = rtv + 'Record Type ID: this ID value isnt valid for the user</ResultMessage></ReplicationMessage>';
        rtv = rtv + '</ReplicationResponseMessage>';
        return rtv;
        */
    }
    /* C00103 end */
    
    
    /*
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
                //System.debug('*** -- WE HAVE A START ELEMENT -- ***');
                if ('IBBInstructionNotification'.equalsIgnoreCase(xsr.getLocalName()))
                {
                    //System.debug('*** -- FOUND = ' + xsr.getLocalName() + ' -- ***');
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
                        //System.debug('*** -- FOUND MESSAGTYPE = ' + xsr.getText() + ' -- ***');
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
                if ('IBBInstructionNotification'.equalsIgnoreCase(xsr.getLocalName()))
                {
                   
                    for (String s : fieldMap.keySet())
                    {
                        //System.debug('*** -- About to pull ' + s + ' -- ***');
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
                                    //system.debug ('Setting the object target field value A ' + strTargetValue);
                                    //system.debug ('Setting the object target field value B ' + TargetField);
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
                                //System.debug('*** -- targetValue for DATE = ' + targetValue + ' -- ***');
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
                                        //System.debug('*** -- Error splitting date ' + targetValue + ' -- ***');
                                        //System.debug('*** -- Error: ' + dateSplitEx + ' -- ***');
                                        return dateSplitEx + ' with date ' + targetValue;
                                    }
                                }
                                if (dtTargetValue != null)
                                {
                                    //System.debug('*** -- targetValue = ' + dtTargetValue.format() + ' -- ***');
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
               }
                                      
            }
        }
        
        
        if ( bSuccess )
        {
            returnStatus = 'SUCCESS';
            returnMsg = 'Succeeded';
        }
          
        system.debug('The Instruction Notification ' + inInstructionNotification);
        String returnString = '<BrokerNotificationResponse><MessageID>' + messageId + '</MessageID>';
        returnString = returnString + '<MessageType>' + messageType + '</MessageType>';
        returnString = returnString + '<LenderReference>' + lenderRef + '</LenderReference>';
        returnString = returnString + '<NotificationType>' + notificationType + '</NotificationType>';
        returnString = returnString + '<ResponseStatus>' + returnStatus + '</ResponseStatus>';
        returnString = returnString + '<GeneralComments>' + returnMsg + '</GeneralComments>';
        returnString = returnString + '</BrokerNotificationResponse>';
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
                   returnMsg = returnMsg + '; ' + err.Message;
               }
                                      
            }
        }
        
        
        if ( bSuccess )
        {
            returnStatus = 'SUCCESS';
            returnMsg = 'Succeeded';
        }
    
    
        system.debug('The Instruction Report ' + inValuationReport);
        String returnString = '<BrokerReportResponse><MessageID>' + messageId + '</MessageID>';
        returnString = returnString + '<MessageType>' + messageType + '</MessageType>';
        returnString = returnString + '<LenderReference>' + lenderRef+ '</LenderReference>';
        returnString = returnString + '<NotificationType>' + notificationType + '</NotificationType>';
        returnString = returnString + '<ResponseStatus>' + returnStatus + '</ResponseStatus>';
        returnString = returnString + '<GeneralComments>' + returnMsg + '</GeneralComments>';
        returnString = returnString + '</BrokerReportResponse>';
        return returnString;
    }
    */
    
    /*
    public Map<String, Account> getAccountMap (List<String> inEbsIdList)
    {
                List<Account> accList = [Select a.Year_ending_2__c,
                                     a.Year_ending_2_GDI__c,
                                     a.Year_ending_1__c,
                                     a.Year_ending_1_GDI__c,
                                     a.Year_2_Net_Profit__c,
                                     a.Year_2_Gross_Dividend_Income__c,
                                     a.Year_1_Net_Profit__c,
                                     a.Year_1_Gross_Dividend_Income__c,
                                     a.YPSA_Relationship_to_Young_Person__c,
                                     a.Would_you_refer_IBB_to_friends_family__c,
                                     a.Work_Phone_No__pc,
                                     a.Work_Email_Address__pc,
                                     a.Who_last_served_by__c,
                                     a.Where_last_served_by_IBB__c,
                                     a.What_are_your_total_monthly_payments__c,
                                     a.Website,
                                     a.Visa_Expiry_Date__c,
                                     a.VF_Flag__c,
                                     a.UK_Citizen__c,
                                     a.Type_of_Business_Premises__pc,
                                     a.Type_of_Business_Premises_Other__pc,
                                     a.Type,
                                     a.Town_of_Birth__c,
                                     a.Total_Income_Before_Tax__c,
                                     a.Total_Annual_Income_Before_Tax__c,
                                     a.Title__c,
                                     a.Title_Other__c,
                                     a.Time_waited__c,
                                     a.Tick_here_TO_NOT_receive_marketing_info__c,
                                     a.Temp_Date__c,
                                     a.Telephone_Number_from_Lead__c,
                                     a.SystemModstamp,
                                     a.Stocks_and_Shares__c,
                                     a.Status_of_email_address__pc,
                                     a.Staff_Member_who_completed_the_fact_find__c,
                                     a.Solicitors_Street__c,
                                     a.Solicitors_Name__c,
                                     a.Solicitors_Flat_No_House_name__c,
                                     a.Solicitor_Town_City__c,
                                     a.Solicitor_Postcode__c,
                                     a.Solicitor_Phone_number__c,
                                     a.Short_Term__c,
                                     a.Short_Name__c,
                                     a.ShippingStreet,
                                     a.ShippingState,
                                     a.ShippingPostalCode,
                                     a.ShippingCountry,
                                     a.ShippingCity,
                                     a.School_name_security_question__c,
                                     a.School_Name__c,
                                     a.Satisfaction_Level__c,
                                     a.Satisfaction_Indicator__c,
                                     a.Salutation,
                                     a.SFDC_ID__c,
                                     a.Reg_Business_Postcode__pc,
                                     a.Reg_Business_Address_DateMovedTo__pc,
                                     a.Reg_Business_Address_3__pc,
                                     a.Reg_Business_Address_2__pc,
                                     a.Reg_Business_Address_1__pc,
                                     a.Record_Accessed_Date_Time__c,
                                     a.Record_Accessed_By__c,
                                     a.Record_Access_Reason__c,
                                     a.RecordTypeId,
                                     a.R85_Received__c,
                                     a.R105_Received__c,
                                     a.Proof_of_Address__c,
                                     a.Products_Discussed_with_Customer_Prospec__c,
                                     a.Previous_Name__pc,
                                     a.Previous_Customer_Address_House_No__c,
                                     a.Previous_Address_Line_2__c,
                                     a.Prev_Previous_Address_House_No__c,
                                     a.Prev_Prev_Address_Post_Code__pc,
                                     a.Prev_Prev_Address_House_No__pc,
                                     a.Prev_Prev_Address_House_Name__pc,
                                     a.Prev_Prev_Address_Foreign__pc,
                                     a.Prev_Prev_Address_Flat_No__pc,
                                     a.Prev_Prev_Address_DateMovedTo__pc,
                                     a.Prev_Prev_Address_Address_Line_5__pc,
                                     a.Prev_Prev_Address_Address_Line_4__pc,
                                     a.Prev_Prev_Address_Address_Line_3__pc,
                                     a.Prev_Prev_Address_Address_Line_2__pc,
                                     a.Prev_Address_Post_Code__pc,
                                     a.Prev_Address_House_No__pc,
                                     a.Prev_Address_House_Name__pc,
                                     a.Prev_Address_Foreign__pc,
                                     a.Prev_Address_Flat_No__pc,
                                     a.Prev_Address_DateMovedTo__pc,
                                     a.Prev_Address_Address_Line_5__pc,
                                     a.Prev_Address_Address_Line_4__pc,
                                     a.Prev_Address_Address_Line_3__pc,
                                     a.Prev_Address_Address_Line_2__pc,
                                     a.Premier_Status__c,
                                     a.Preferred_contact_method__c,
                                     a.Postcode_ZIP_code__c,
                                     a.Position_Held__pc,
                                     a.Phone,
                                     a.Personal_Loans_Repayments_per_Month__c,
                                     a.PersonTitle,
                                     a.PersonOtherStreet,
                                     a.PersonOtherState,
                                     a.PersonOtherPostalCode,
                                     a.PersonOtherCountry,
                                     a.PersonOtherCity,
                                     a.PersonMobilePhone,
                                     a.PersonMailingStreet,
                                     a.PersonMailingState,
                                     a.PersonMailingPostalCode,
                                     a.PersonMailingCountry,
                                     a.PersonMailingCity,
                                     a.PersonLeadSource,
                                     a.PersonLastCUUpdateDate,
                                     a.PersonLastCURequestDate,
                                     a.PersonHomePhone,
                                     a.PersonEmailBouncedReason,
                                     a.PersonEmailBouncedDate,
                                     a.PersonEmail,
                                     a.PersonContactId,
                                     a.PersonBirthdate,
                                     a.Permission_to_store_data__c,
                                     a.Passport_No__c,
                                     a.Passport_Issue_Place__pc,
                                     a.Passport_Date_of_Issue__c,
                                     a.Parent_Country__c,
                                     a.ParentId,
                                     a.Owner_Lookup__c,
                                     a.OwnerId,
                                     a.Outstanding_balance_on_loan_or_finance__c,
                                     a.Outstanding_balance_on_credit_card__c,
                                     a.Other_Financial_Monthly_Commitments__c,
                                     a.Organisation_Name__pc,
                                     a.Occupation__c,
                                     a.Number_of_judgements__c,
                                     a.NumberOfEmployees,
                                     a.Non_guaranteed_overtime_commission__c,
                                     a.Non_UK_Citizen_Source_of_Wealth__c,
                                     a.Nominated_External_Acc_Sort_Code__c,
                                     a.Nominated_External_Acc_Payment_Ref__c,
                                     a.Nominated_External_Acc_No__c,
                                     a.No_of_months_in_arrears__c,
                                     a.No_of_depenents__c,
                                     a.No_of_children__c,
                                     a.Net_Monthly_Income__c,
                                     a.Nature_of_Business__c,
                                     a.Nationality__c,
                                     a.Name_to_appear_on_Statements__pc,
                                     a.Name_of_mortgage_provider__c,
                                     a.Name,
                                     a.Mothers_Family_Name__c,
                                     a.Mother_s_family_name_security_question__c,
                                     a.Middle_Name__pc,
                                     a.Medium_Term__c,
                                     a.MasterRecordId,
                                     a.Marketing_Consent__c,
                                     a.Marketing_Consent_Obtained__pc,
                                     a.Marital_Status__c,
                                     a.Made_any_arrangements_with_creditors__c,
                                     a.Long_Term__c,
                                     a.Last_customer_transaction__c,
                                     a.LastName,
                                     a.LastModifiedDate,
                                     a.LastModifiedById,
                                     a.LastActivityDate,
                                     a.Knowledge__c,
                                     a.Judgement_amount__c,
                                     a.Joint_Salary__c,
                                     a.Joint_A__c,
                                     a.IsPersonAccount,
                                     a.IsDeleted,
                                     a.IsCustomerPortal,
                                     a.Internet_Enabled__c,
                                     a.Intermediary_Contact__c,
                                     a.Interest_In_Products_and_Services__pc,
                                     a.Industry,
                                     a.If_yes_to_other_income_please_give_value__c,
                                     a.If_retired_what_is_annual_pension__c,
                                     a.If_no_what_is_the_reason__c,
                                     a.If_Other_where__c,
                                     a.If_Dual_Nationality_Passport_No__c,
                                     a.If_Dual_Nationality_Country_of_Origin__c,
                                     a.Id,
                                     a.ID_Serial_No__c,
                                     a.ID_Issue_Date__pc,
                                     a.ID_Evidence__pc,
                                     a.ID_Evidence__c,
                                     a.ID_Document_Serial_No__pc,
                                     a.IBB_Staff_member__pc,
                                     a.How_proffesional_were_the_staff__c,
                                     a.How_often_do_you_review_your_savings__c,
                                     a.How_often_are_you_paid__c,
                                     a.How_long_have_you_had_a_bank_account__c,
                                     a.How_long_have_you_been_in_current_job__c,
                                     a.How_helpful_were_the_staff__c,
                                     a.How_do_you_receive_your_salary__c,
                                     a.How_did_you_hear_about_IBB__c,
                                     a.Home_Telephone_No__c,
                                     a.Home_Details__c,
                                     a.Home_Details_Name_of_Lender__c,
                                     a.Home_Details_Mortgage_Outstanding__c,
                                     a.Home_Details_Estimated_Value__c,
                                     a.Hire_Purchase_Payments_per_Month__c,
                                     a.Have_you_ever_been_refused_finance__c,
                                     a.Have_you_ever_been_declared_bankrupt__c,
                                     a.Have_you_been_made_bankrupt_or_have_CCJs__c,
                                     a.Have_you_any_County_Court_Judgements__c,
                                     a.Have_arrears_or_IV_worsened_in_last_6__c,
                                     a.Has_Applicant_ever_had_a_CCJ_or_bankrupt__c,
                                     a.Happy_for_IBB_to_hold_your_data__c,
                                     a.Guardian_Contact_Detail_Post_Code__pc,
                                     a.Guardian_Contact_Detail_Name__pc,
                                     a.Guardian_Contact_Detail_Address_3__pc,
                                     a.Guardian_Contact_Detail_Address_2__pc,
                                     a.Guardian_Contact_Detail_Address_1__pc,
                                     a.Guaranteed_bonus__c,
                                     a.Gross_Annual_Income__c,
                                     a.Give_circumstances_if_refused_finance__c,
                                     a.Gender__c,
                                     a.FirstName,
                                     a.Fax,
                                     a.Expiry_of_Current_Mortgage__c,
                                     a.Evidence_of_Address__pc,
                                     a.Ever_missed_financial_commitment__c,
                                     a.Ever_had_any_defaults_registered__c,
                                     a.Ever_been_in_arrears_with_any_loans__c,
                                     a.Estimated_value_of_property__c,
                                     a.Estate_agent_street__c,
                                     a.Estate_agent_phone_number__c,
                                     a.Estate_agent_name__c,
                                     a.Estate_agent_flat_no_house_name__c,
                                     a.Estate_agent_Town_City__c,
                                     a.Estate_agent_Postcode__c,
                                     a.Employment_Type__c,
                                     a.Employment_Status__c,
                                     a.Employers_Post_Code__c,
                                     a.Employers_Nature_of_Business__c,
                                     a.Employers_Name__c,
                                     a.Employers_Address_Line_5__c,
                                     a.Employers_Address_Line_4__c,
                                     a.Employers_Address_Line_3__c,
                                     a.Employers_Address_Line_2__c,
                                     a.Employers_Address_Line_1__c,
                                     a.Employer_s_Phone__c,
                                     a.Employer_Post_Code__c,
                                     a.Employer_Name__c,
                                     a.Employer_Country__c,
                                     a.Employer_Address_Line_5__c,
                                     a.Employer_Address_Line_4__c,
                                     a.Employer_Address_Line_3__c,
                                     a.Employer_Address_Line_2__c,
                                     a.Employer_Address_Line_1__c,
                                     a.Employer_Address_House_No__c,
                                     a.EBS_ID__c,
                                     a.EBS_Customer_Status__c,
                                     a.EBS_Account_Balance__c,
                                     a.Dual_Nationality_Passport_No__pc,
                                     a.Dual_Nationality_Country_of_Origin__pc,
                                     a.Document_Issue_Date__c,
                                     a.Do_you_have_savings_elsewhere__c,
                                     a.Do_you_have_home_finance_mortgage__c,
                                     a.Do_you_have_another_income_eg_pension__c,
                                     a.Do_you_have_an_account_with_another_bank__c,
                                     a.Do_you_have_Internet_access__c,
                                     a.Do_you_have_2_years_of_accounts__c,
                                     a.Description,
                                     a.Deposit_Amount__c,
                                     a.Dependent_Children__c,
                                     a.Default_Short_Name__pc,
                                     a.Default_Branch__c,
                                     a.Debt_5_Outstanding_balance__c,
                                     a.Debt_5_Monthly_payment__c,
                                     a.Debt_5_Lender_name__c,
                                     a.Debt_4_Outstanding_balance__c,
                                     a.Debt_4_Monthly_payment__c,
                                     a.Debt_4_Lender_name__c,
                                     a.Debt_3_Outstanding_balance__c,
                                     a.Debt_3_Monthly_payment__c,
                                     a.Debt_3_Lender_name__c,
                                     a.Debt_2_Outstanding_balance__c,
                                     a.Debt_2_Monthly_payment__c,
                                     a.Debt_2_Lender_name__c,
                                     a.Debt_1_Outstanding_balance__c,
                                     a.Debt_1_Monthly_payment__c,
                                     a.Debt_1_Lender_name__c,
                                     a.Days_at_current_and_previous_address__c,
                                     a.Date_survey_conducted__c,
                                     a.Date_of_visa_expiry__c,
                                     a.Date_of_last_transaction__c,
                                     a.Date_of_last_customer_transaction__c,
                                     a.Date_of_judgement__c,
                                     a.Date_of_home_insurance_renewal__c,
                                     a.Date_of_highest_arrears__c,
                                     a.Date_of_car_insurance_renewal__c,
                                     a.Date_of_bankruptcy__c,
                                     a.Date_of_Visa_Expiry__pc,
                                     a.Date_of_Birth__c,
                                     a.Date_moved_to_previous_address__c,
                                     a.Date_moved_to_prev_previous_address__c,
                                     a.Date_moved_to_address__c,
                                     a.Date_last_maintained__c,
                                     a.Date_judgement_repaid__c,
                                     a.Date_discharged__c,
                                     a.Date_current_bank_account_opened__c,
                                     a.Date_arrears_repaid__c,
                                     a.Date_Proof_of_ID_Verified__c,
                                     a.Date_Proof_of_Address_Verified__c,
                                     a.Date_Products_Discussed__c,
                                     a.Date_Moved_To_Current_Address__pc,
                                     a.Date_Fact_Find_Completed__c,
                                     a.Date_Employment_Commenced__c,
                                     a.Date_Customer_Added__c,
                                     a.Date_Converted_to_Customer__c,
                                     a.Customer_happy_to_participate_in_survey__c,
                                     a.Customer_Type__c,
                                     a.Customer_Previous_Address_District__c,
                                     a.Customer_Prev_Previous_Address_District__c,
                                     a.Customer_Number__c,
                                     a.Customer_Default_Branch__c,
                                     a.Customer_Card_Name__pc,
                                     a.Customer_Card_Details__c,
                                     a.Customer_Address_Street__c,
                                     a.Customer_Address_Post_Code__c,
                                     a.Customer_Address_Line_3__c,
                                     a.Customer_Address_Line_1__c,
                                     a.Customer_Address_House_No__c,
                                     a.Customer_Address_District__c,
                                     a.Customer_Address_Country__c,
                                     a.Customer_Address_City__c,
                                     a.Current_bank_detail_is_keep_open__c,
                                     a.Current_amount_outstanding_on_mortgage__c,
                                     a.Current_Bank_Sort_Code__c,
                                     a.Current_Bank_Name__c,
                                     a.Current_Bank_Details_Sort_Code__c,
                                     a.Current_Bank_Details_Name_of_Bank__c,
                                     a.Current_Bank_Details_Keep_Open__c,
                                     a.Current_Bank_Details_Date_Acc_Opened__c,
                                     a.Current_Bank_Details_Account_No__c,
                                     a.Current_Bank_Account_No__c,
                                     a.Current_Address__c,
                                     a.Current_Address_Post_Code__pc,
                                     a.Current_Address_Line_5__pc,
                                     a.Current_Address_Line_4__pc,
                                     a.Current_Address_Line_3__pc,
                                     a.Current_Address_Line_2__pc,
                                     a.Current_Address_House_No__pc,
                                     a.Current_Address_House_Name__pc,
                                     a.Current_Address_Flat_No__pc,
                                     a.Credit_Card_Repayments_Per_Month__c,
                                     a.CreatedDate,
                                     a.CreatedById,
                                     a.Country_of_Residence__c,
                                     a.Country_of_Issue__c,
                                     a.Country_of_Birth__c,
                                     a.Correspondence_Post_Code__pc,
                                     a.Correspondence_All_Accounts__pc,
                                     a.Correspondence_Address_Line_3__pc,
                                     a.Correspondence_Address_Line_2__pc,
                                     a.Correspondence_Address_Line_1__pc,
                                     a.Contact_Method__pc,
                                     a.Contact_By_Telephone__c,
                                     a.Contact_By_Post__c,
                                     a.Contact_By_Email__c,
                                     a.Comments_from_the_customer__c,
                                     a.Colleague_served_by__c,
                                     a.Cheque_book_required__c,
                                     a.Channel_lead_orginated__c,
                                     a.Card_Name__c,
                                     a.Campaign__c,
                                     a.Call_Centre_Application__c,
                                     a.Business_Fax_No__pc,
                                     a.Business_Contact_Name__pc,
                                     a.BillingStreet,
                                     a.BillingState,
                                     a.BillingPostalCode,
                                     a.BillingCountry,
                                     a.BillingCity,
                                     a.Are_you_an_existing_customer__c,
                                     a.Apply_for_Telephone_Banking__c,
                                     a.Apply_for_Online_Banking__c,
                                     a.Any_other_name_known_by_past_present__c,
                                     a.AnnualRevenue,
                                     a.Amount_of_Savings__c,
                                     a.Age1__pc,
                                     a.Address_Type__c,
                                     a.Accountant_name__c,
                                     a.Accountant_Town_City__c,
                                     a.Accountant_Street__c,
                                     a.Accountant_PostCode__c,
                                     a.Accountant_Phone__c,
                                     a.AccountantFlatnoHouse_name_if_applicable__c,
                                     a.Account_correspondence__c,
                                     a.Account_Type__c,
                                     a.Account_Officer__c 
                                 From Account a 
                                 where EBS_ID__c in :inEbsIdList];
        Map<String, Account> accMap = new Map<String, Account>();
        if (accList.size() > 0){
            for (Account a : accList){
                accMap.put(a.EBS_ID__c, a);
            }
        }
        return accMap;
    }
    */
    
    public static Map<String, Account_with_IBB__c> getAccountsWithIBB (List<String> inEBSIdList)
    {
        List<Account_with_IBB__c> accList = [Select a.SystemModstamp,
                                             a.Status_Balance__c,
                                             a.Shadow_Debit__c,
                                             a.Shadow_Credit__c,
                                             a.Reserved_Balance__c,
                                             a.RepDealAccountType__c,
                                             a.RepAccountType__c,
                                             a.Primary_SFDC_Account__c,
                                             a.Primary_Customer_EBS_ID__c,
                                             a.Primary_Customer_Default_Branch__c,
                                             a.OwnerId,
                                             a.Name,
                                             a.Ledger_Balance__c,
                                             a.LastModifiedDate,
                                             a.LastModifiedById,
                                             a.IsDeleted,
                                             a.Id,
                                             a.IBB_Product__c,
                                             a.IBB_Product_Name__c,
                                             a.External_Account_Number__c,
                                             a.EBS_ID__c,
                                             a.EBS_Deal_Account_Type__c,
                                             a.Direct_Debit_Sort_Code__c,
                                             a.Direct_Debit_Bank_Account__c,
                                             a.Date_of_Last_Transaction__c,
                                             a.Created_in_EBS__c,
                                             a.CreatedDate,
                                             a.CreatedById,
                                             a.Cleared_Balance__c,
                                             a.Available_Balance__c,
                                             a.Account_Type__c,
                                             a.Account_Suffix__c,
                                             a.Account_Status__c,
                                             a.Account_Is_Joint__c,
                                             a.Account_Inactive__c,
                                             a.Account_Currency__c,
                                             a.Account_Closed__c,
                                             a.Account_Blocked__c 
                                     From Account_with_IBB__c a 
                                     where a.EBS_ID__c in :inEBSIdList];
        Map<String, Account_with_IBB__c> accMap = new Map<String, Account_with_IBB__c>();
        if (accList.size() > 0){
            for (Account_with_IBB__c acc : accList){
                accMap.put(acc.Name, acc);
            }
        } 
        return accMap;
    }

    public static String buildReturnString(List<ReplicationMessage> inRepList){
        String returnString = '<ReplicationResponseMessage>';
        for (ReplicationMessage repMsg : inRepList){
            returnString = returnString + '<ReplicationMessage>';
            returnString = returnString + '<MessageID>' + repMsg.messageId + '</MessageID>';
            returnString = returnString + '<Result>' + repMsg.result + '</Result>';
            if (repMsg.resultMessage != null){
                returnString = returnString + '<ResultMessage>' + repMsg.resultMessage + '</ResultMessage>';
            }else {
                returnString = returnString + '<ResultMessage/>';
            }
            returnString = returnString + '</ReplicationMessage>';
        }
        
        returnString = returnString + '</ReplicationResponseMessage>';
        system.debug('This is the Rep Response message ' + returnstring);
        return returnString;
    }
    
    public static string SetEscaped(string inStr)
    {
        return '\'' + inStr + '\'';
    }

    public class ReplicateAccount {
        public Account acc {get; set;}
        public String messageId {get; set;}
        public String messageType {get; set;}
        public ReplicationMessage repMsg {get; set;}
    }
    
    public class SFDCIDReplicateAccount
    {
        public string SFDCID {get;set;}
        public string EBSID {get;set;}
        public string AccountId {get;set;}
        public boolean SFDCexists {get;set;}
        public boolean EBSIDexists {get;set;}
        public ReplicateAccount replAccount
        {
            get
            {
                if (replAccount == null)
                {
                    replAccount = new ReplicateAccount();
                }
                return replAccount;
            }
            set;
        }
    }
    
    public class ReplicateBalanceUpdate {
        public Account_with_IBB__c accWithIBB {get; set;}
        public String accountNo {get; set;}
        public String messageId {get; set;}
        public String messageType {get; set;}
        public ReplicationMessage repMsg {get; set;}
        public DateTime updateDateTime {get; set;}
    }
    
    public class ReplicateJAR {
        public Asset_Relationship__c ar {get; set;}
        public Account acc {get; set;}
        public String messageId {get; set;}
        public String messageType {get; set;}
        public ReplicationMessage repMsg {get; set;}
        public String replicationType {get; set;}
        public String relationship {get; set;}
    }

    public class ReplicateOCA {
        public Account_with_IBB__c accWithIBB {get; set;}
        public String messageId {get; set;}
        public String messageType {get; set;}
        public ReplicationMessage repMsg {get; set;}
    }

    public class ReplicationMessage {
        public String sfdcId {get; set;}
        public String messageId {get; set;}
        public String result {get; set;}
        public String resultMessage{get; set;}
    }
    
   

}