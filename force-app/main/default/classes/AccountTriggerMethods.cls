/* -------------------------------------------------------------------------------------------------------- */
/* C0684    MCD Tax                                                                                         */
/* -------------------------------------------------------------------------------------------------------- */

public without sharing class AccountTriggerMethods 
{
    /**  Garnet - START  **/
    aLog.Logger logger = new aLog.Logger('AccountTrigger');

    public static void beforeInsert(List<Account> newList, Map<Id, Account> newMap) {
        RiskCalculator.CalculateRiskScores(newList, newMap);
        duplicateCheckBeforeInsert(newList, newMap);
 
    }
    public static void afterInsert(List<Account> newList, Map<Id, Account> newMap) {}
    
    public static void beforeUpdate(List<Account> oldList, Map<Id, Account> oldMap, List<Account> newList, Map<Id, Account> newMap) {        
        RiskCalculator.CalculateRiskScores(oldList, oldMap, newList, newMap);
        duplicateCheckBeforeUpdate(oldList, oldMap, newList, newMap);
        RiskUtils.raiseCaseforOvernight(oldMap, newList);
        
    }
    
    public static void afterUpdate(List<Account> oldList, Map<Id, Account> oldMap, List<Account> newList, Map<Id, Account> newMap) {
        createWebLogsForTaxChanges(oldList, oldMap, newList, newMap);
        updateCaseRiskRating(newList,oldMap,newMap);// Case: 01835247 -  update Risk rating value from account to case 
    }
    
    public static void beforeDelete(List<Account> oldList, Map<Id, Account> oldMap) {}
    public static void afterDelete(List<Account> oldList, Map<Id, Account> oldMap) {}
    public static void afterUndelete(List<Account> newList, Map<Id, Account> newMap) {}
    
    /* -------------------------------------------------------------------------------------------------------- */
    /*                                         Trigger Methods                                                  */
    /* -------------------------------------------------------------------------------------------------------- */
        
    private static void duplicateCheckBeforeInsert(List<Account> newList, Map<Id, Account> newMap)
    {
    logger.Trace('Trigger: Before Insert for Account :' + newList[0].id);
    logger.Trace('Calling Capitalize Account');
    AccountTriggerMethods.Capitalize(newList);
    logger.Trace('Populating District');
    AccountTriggerMethods.populateDistrict(newList);
    
    DuplicateAccount__c mcs = DuplicateAccount__c.getValues('Default'); 
    if(mcs != null  )
    {
        logger.Trace('Duplicate account record type :' + mcs.ExternalRecordType__c);
        system.debug('Record type compare : trigger=' + newList[0].recordtypeId + ' config=' +  mcs.ExternalRecordType__c);
    
    
        //Only check for duplicates if the system is turned on, and the account record type is not the external HPPCAA record type                
        Boolean checkDuplicate = true;
        if(mcs.ExternalRecordType__c != null)
        {
            logger.Trace('Checking external record type ' + mcs.ExternalRecordType__c + ' against account ' + newList[0].recordtypeid);
            if(mcs.ExternalRecordType__c.equalsIgnoreCase(string.valueof(newList[0].recordtypeid)))
            {
                checkDuplicate = false;
            }
        }                
        
        if(mcs.no_allowed__c > -1 && checkDuplicate)
        {                
            try
            {                
                logger.Trace('Checking for duplicate on insert');
                Account a = newList[0];
            
            //we need date of birth and first name.last name for the check
            if( a.date_of_birth__c != null 
                    && a.lastname != null && a.firstname != null)
            {
                if(a.name != null)
                {
                    system.debug('Name to check : ' + a.name);
                    if(a.firstname.EqualsIgnoreCase('New') && a.lastname.equalsIgnoreCase('Account'))
                    {
                        //Liabilities account insert
                        logger.Info('Checking for duplicate');
                        logger.Trace('Account Data:');
                        logger.Trace('Insert: FirstName: ' + a.firstName + ' LastName: ' + a.lastName + ' DOB: ' + a.date_of_birth__c );
                        AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
                    }
                }
                else
                {
                    //HPP CAA internal insert
                    AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
                }    
            }
          }
          catch(Exception ex)
          {
              throw ex;
          }
        }
    }
    aLog.TriggerSave();
    }
    
    private static void duplicateCheckBeforeUpdate(List<Account> oldList, Map<Id, Account> oldMap, List<Account> newList, Map<Id, Account> newMap)
    {
    logger.Trace('Before Update Trigger for account :' + newList[0].id);
    logger.Trace('Calling Capitalize Account');
    AccountTriggerMethods.Capitalize(newList);
    
    DuplicateAccount__c mcs = DuplicateAccount__c.getValues('Default'); 
    if(mcs != null  )
    {
         Boolean checkDuplicate = true;
        if(mcs.ExternalRecordType__c != null)
        {
            if(mcs.ExternalRecordType__c.equalsIgnoreCase(string.valueof(newList[0].recordtypeid)))
            {
                checkDuplicate = false;
                logger.Trace('Skipping duplicate check because config record type ' +mcs.ExternalRecordType__c + ' matches account record type ' + newList[0].recordtypeid );
            }
        }
    
        if(mcs.no_allowed__c > -1 && checkDuplicate)
        {
            try
            {
            Account a = newList[0];
            Account b = oldList[0];
            
            System.debug(a+'**********128****'+b);    
            logger.trace('Checking for a change of lastname, firstname or date of birth');
            
            if(a.firstname != null && b.firstname != null & a.lastname != null && b.lastname != null && a.date_of_birth__c != null && b.date_of_birth__c != null)
            {                        
                if(!a.firstname.equalsIgnoreCase(b.firstname) || !a.lastname.equalsIgnoreCase(b.lastname) || a.date_of_birth__c != b.date_of_birth__c)
                {
                    //Name of date of birth has changed, check that it's not now a duplicate
                    if(b.firstname.EqualsIgnoreCase('New') && b.lastname.equalsIgnoreCase('Account'))
                    {                            
                        logger.Info('Checking for duplicate');
                        logger.Trace('Account Data:');
                        logger.Trace('Before: FirstName: ' + b.firstName + ' LastName: ' + b.lastName + ' DOB: ' + b.date_of_birth__c );
                        logger.Trace('After: FirstName: ' + a.firstName + ' LastName: ' + a.lastName + ' DOB: ' + a.date_of_birth__c );                                
                        AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
                    }
                }
            }
            else
            {
                logger.Trace('No change detected, skipping account duplicate check');
            }
            }
            catch(Exception ex)
            {
                logger.Fatal('Unexpected error',ex);
                throw ex;
            }
        }
    }
    
    AccountTriggerMethods.populateDistrict(trigger.new);
    
    /* C0CPDR */
    //Account ac = trigger.new[0];
    //AccountTriggerMethods.DoTax (ac.id);
    
    /**/
    Trigger_Helper.Audit('Account',trigger.oldMap, trigger.newMap);
    aLog.TriggerSave();
    }
    
    // Case: 01835247 -  update Risk rating value from account to case ; Start
    private static void updateCaseRiskRating(List<Account> newList,Map<Id, Account> oldMap, Map<Id, Account> newMap)
    { 
        system.debug('newMap'+newList);
        List<case> ca = [select id,Risk_Rating__c,AccountId from case where AccountId In :newList AND IsClosed = false];
        system.debug('**************'+ca);
        List<Case> UpdatedCases = new List<Case>();
        for(Account acc: newList){
        system.debug('**'+newMap.get(acc.Id).Risk_Rating__c+'########'+oldMap.get(acc.Id).Risk_Rating__c);
            if(newMap.get(acc.Id).Risk_Rating__c != oldMap.get(acc.Id).Risk_Rating__c){
                system.debug('*****180*********'+ca);
                for(Case c : ca){
                system.debug('case details:'+c);
                    if(c.Risk_Rating__c =='' || c.Risk_Rating__c != acc.Risk_Rating__c){
                        system.debug('Entering update loop');
                        c.Risk_Rating__c = acc.Risk_Rating__c ;  
                        UpdatedCases.add(c);
                    }
                }
            }
        }
        system.debug('Updated case List: '+UpdatedCases);
        if(UpdatedCases.size()>0){
            update UpdatedCases;
        }
    }
    // Case: 01835247 -  update Risk rating value from account to case ; End
    
    private static void createWebLogsForTaxChanges(List<Account> oldList, Map<Id, Account> oldMap, List<Account> newList, Map<Id, Account> newMap)
    {
    /* C0684 */
    
    String caa_Settings;
    
    if(CAA_Settings__c.getInstance('SendMCDOnTaxChanges') != NULL){
        caa_Settings = CAA_Settings__c.getInstance('SendMCDOnTaxChanges').value__c; 
    }
    if (caa_settings == 'YES')
    {
      List<Fields_for_Triggers__c> flds = [SELECT id, API_Field_Name__c FROM Fields_for_Triggers__c WHERE SObject_Name__c = 'Account' and Is_Active__c = true];
      if (flds.Size() > 0)
      {
        Account a = newList[0];
        Account b = oldList[0];
        if (!String.IsBlank(a.EBS_ID__c ) && !String.IsBlank(b.EBS_ID__c))
        {
          SObject aSObject = new Account();
          SObject bSObject = new Account();
          aSObject = a;
          bSObject = b;
          boolean fldChange = false;
          for (Fields_for_Triggers__c fld : flds)
          {
            if (aSObject.get(fld.API_Field_Name__c) != bSObject.get(fld.API_Field_Name__c))
            {
              fldChange = true;
              break;
            }
          
          }
          if (fldChange)
          {
            string weblogid = Teller_Core_Controller.CreateWebLog (a.id, true);
          }
        }
      }
    }
    /* C0684 */
    aLog.TriggerSave();
    }
    /** Garnet - END **/
    
    public static void Capitalize(List<Account> inAccs)
    {
        if(inAccs == null)
        return;
    
         // C0592 - Null check values before passing to function
         for (Account a : inAccs)
         {
             if(a.firstname!=null)
             {
                a.firstname = CapitalizeField(a.firstname);
             }
             if(a.lastname!=null)
             {
                a.lastname= CapitalizeField(a.lastname);
             }
            if (a.middle_name__pc!=null)
            {
                a.middle_name__pc= CapitalizeField(a.middle_name__pc);
            }
            if(a.BillingPostalCode!=null)
            {
                a.BillingPostalCode= UpperCaseField(a.BillingPostalCode);
            }
            if(a.ShippingPostalCode!=null)
            {
                a.ShippingPostalCode=UpperCaseField(a.ShippingPostalCode);
            }
            if(a.PersonMailingPostalCode!=null)
            {
                a.PersonMailingPostalCode= UpperCaseField(a.PersonMailingPostalCode);
            }
         }
    }
    
    public static String UpperCaseField(String obj)
    {
        if(obj == null)return obj;
        
        return obj.toUpperCase();
    }
    
    public static String CapitalizeField(String obj)
    {
        if(obj == null)return obj;
        
        return obj.capitalize();
    }

    public static void CheckDuplicate(Account inAcc, integer noAllowed)
    {
        List<Account> acc = [select firstname, lastname, middle_name__pc, date_of_birth__c from Account
                       where firstname =:inAcc.firstname and lastname =:inAcc.lastname 
                           and middle_name__pc =: inAcc.middle_name__pc
                           and date_of_birth__c =: inAcc.date_of_birth__c
                    ];
                    
                   
                    
        if(acc.size() >  noAllowed)
        {
            inAcc.addError('Duplicate account found.  Could not create account. ');
        }         
    }



      public static void populateDistrict(List<Account> inAccs)
      {
               
            String[] splitAddress;
            String splitChar = '\n';
            for (Account a : inAccs)
            {
                  if (a.BillingStreet != null)
                  {
                        string address = '';
                        if (a.BillingStreet.contains(splitChar))
                        {
                              splitAddress = a.BillingStreet.split(splitChar);
                         
                              a.BillingStreet = splitAddress[0];
                              a.Customer_Address_District__c = splitAddress[1];
                              //a.Customer_Address_Additional__c = splitAddress[2]; 
                              string additional = '';                              
                              
                              system.debug('In populateDistrict 1 ' + a.BillingStreet);
                              system.debug('In populateDistrict 2 ' + a.Customer_Address_district__c);
                              //system.debug('In populateDistrict 3 ' + a.Customer_Address_Additional__c);
                              
                              if(splitAddress.size() > 2)
                              {
                                additional = splitAddress[2];
                                system.debug('In populateDistrict 4 ');
                                for(integer j=0;j<splitAddress.size();j++)
                                {
                                    string addr = splitAddress[j];
                                    addr = addr.replace('\r','');
                                    
                                    address = address + addr + ' ';
                                } 
                                system.debug('In populateDistrict 3a ' + additional);
                                system.debug('In populateDistrict 5 ' + address);
                                a.BillingStreet = a.BillingStreet.replace('\r', '');
                                a.Customer_Address_district__c = a.Customer_Address_district__c.replace('\r', '');
                                a.BillingStreet = a.BillingStreet + ' ' + a.Customer_Address_district__c;
                                a.Customer_Address_district__c = additional;
                                
                                system.debug('In populateDistrict A ' + a.BillingStreet);
                                system.debug('In populateDistrict B ' + a.Customer_Address_District__c );  
                                //integer b = 1 / 0;
                                //a.Customer_Address_District__c = address;
                                integer num = a.BillingStreet.Length();
                                if (num > 32)
                                {
                                    a.BillingStreet = a.BillingStreet.Substring(0,32);
                                }
                                
                                num = a.Customer_Address_District__c.Length();
                                if (num > 32)
                                {
                                    a.Customer_Address_District__c = a.Customer_Address_District__c.Substring(0,32);
                                }
                               
                                
                                //system.debug('In populateDistrict A ' + a.BillingStreet);
                                //system.debug('In populateDistrict B ' + a.Customer_Address_District__c );  
                                //integer c = 1 / 0;                                                                               
                                
                                //Integer lastIndex=0; 
                                
                                //Find the last index of numbers 0-9
                                //for(Integer c = 0;c<10;c++)
                                //{
                                //    string s = string.valueOf(c);
                                //    integer index = address.lastIndexOf(s);
                                //    if( index> lastIndex)
                                //    {
                                //        lastIndex = index;
                                //    }
                                //}
                                
                                //if (lastIndex > 0)
                                //{
                                //    a.BillingStreet = address.substring(0,lastIndex + 1);
                                //    a.Customer_Address_District__c = address.substring(lastIndex + 1 ); 
                                //}
                                //else
                                //{
                                    
                                //    a.Customer_Address_District__c = address; 
                                //}
                                
                                //string billingStreet = a.BillingStreet;
                                //string districtAddress = a.Customer_Address_District__c;
                                //integer len = billingStreet.Trim().length();
                                //system.debug ('In populateDistrict A - ' + districtAddress);
                                //system.debug ('In populateDistrict B - ' + billingStreet);
                                //system.debug ('In populateDistrict C - ' + string.valueof(len));
                                //system.debug ('In populateDistrict D - ' + districtAddress.substring(0, billingStreet.Trim().length()));
                                
                                //if ( billingStreet.Length() < districtAddress.Length())
                                //{
                                //    if(districtAddress.substring(0, billingStreet.Trim().length()) == billingStreet.trim())  
                                //    {
                                       
                                //        a.Customer_Address_District__c = a.Customer_Address_District__c.substring(billingStreet.length());
                                //    }
                                //}
                                                   
                                                        
                              }                           
                        }
                  }
                  if (a.ShippingStreet != null)
                  {
                         string address = '';
                        if (a.ShippingStreet.contains(splitChar))
                        {
                              splitAddress = a.ShippingStreet.split(splitChar);
                              a.ShippingStreet = splitAddress[0]; 
                              a.Customer_Previous_Address_District__c = splitAddress[1];
                              string additional = ''; 
                              /*
                              for(Integer i = 2; i < splitAddress.size(); i++ )
                              {
                                    a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c + ', ' + splitAddress[i];
                              }
                              */
                              if(splitAddress.size() > 2)
                              {
                                additional = splitAddress[2];
                                for(integer j=0;j<splitAddress.size();j++)
                                {
                                    string addr = splitAddress[j];
                                    addr = addr.replace('\r','');
                                    
                                    address = address + addr + ' ';
                                }                                                                                   
                                
                                Integer lastIndex=0; 
                                //Find the last index of numbers 0-9
                                for(Integer c = 0;c<10;c++)
                                {
                                    string s = string.valueOf(c);
                                    integer index = address.lastIndexOf(s);
                                    if( index> lastIndex)
                                    {
                                        lastIndex = index;
                                    }
                                }
                                
                                a.ShippingStreet = a.ShippingStreet.replace('\r', '');
                                a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c.replace('\r', '');
                                a.ShippingStreet= a.ShippingStreet + ' ' + a.Customer_Previous_Address_District__c ;
                                a.Customer_Previous_Address_District__c = additional;
                                
                                
                                integer num = a.ShippingStreet.Length();
                                if (num > 32)
                                {
                                    a.ShippingStreet= a.ShippingStreet.Substring(0,32);
                                }
                                
                                num = a.Customer_Previous_Address_District__c.Length();
                                if (num > 32)
                                {
                                    a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c.Substring(0,32);
                                }
                                
                                /*
                                if (lastIndex > 0)
                                {
                                    a.ShippingStreet= address.substring(0,lastIndex + 1);
                                    a.Customer_Previous_Address_District__c = address.substring(lastIndex + 1 );  
                                }
                                else
                                {
                                    a.Customer_Previous_Address_District__c = address; 
                                } 
                                
                                string shippingStreet = a.ShippingStreet;
                                string districtAddress = a.Customer_Previous_Address_District__c;
                                
                                if ( shippingStreet.Length() < districtAddress.Length())
                                {
                                    if(districtAddress.substring(0, shippingStreet.Trim().length()) == shippingStreet.trim())  
                                    {
                                        a.Customer_Previous_Address_District__c = a.Customer_Previous_Address_District__c.substring(shippingStreet.length());
                                    } 
                                }
                                */                          
                              }                                
                        }
                  }
                  if (a.PersonMailingStreet != null)
                  {
                        string address = '';
                        if (a.PersonMailingStreet.contains(splitChar))
                        {
                              splitAddress = a.PersonMailingStreet.split(splitChar);
                              a.PersonMailingStreet = splitAddress[0];
                              a.Customer_Prev_Previous_Address_District__c = splitAddress[1];
                              string additional = ''; 
                              /*
                              for(Integer i = 2; i < splitAddress.size(); i++ )
                              {
                                    a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c + ', ' + splitAddress[i];
                              }  
                              */ 
                              if(splitAddress.size() > 2)
                              {
                                additional = splitAddress[2];
                                for(integer j=0;j<splitAddress.size();j++)
                                {
                                    string addr = splitAddress[j];
                                    addr = addr.replace('\r','');
                                    
                                    address = address + addr + ' ';
                                }  
                                
                                
                                a.PersonMailingStreet = a.PersonMailingStreet.replace('\r', '');
                                a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c.replace('\r', '');
                                a.PersonMailingStreet = a.PersonMailingStreet + ' ' + a.Customer_Prev_Previous_Address_District__c ;
                                a.Customer_Prev_Previous_Address_District__c = additional;
                                
                               
                                integer num = a.PersonMailingStreet .Length();
                                if (num > 32)
                                {
                                    a.PersonMailingStreet = a.PersonMailingStreet.Substring(0,32);
                                }
                                
                                num = a.Customer_Prev_Previous_Address_District__c.Length();
                                if (num > 32)
                                {
                                    a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c.Substring(0,32);
                                }
                                                                                                                 
                                
                                /*
                                Integer lastIndex=0; 
                                //Find the last index of numbers 0-9
                                for(Integer c = 0;c<10;c++)
                                {
                                    string s = string.valueOf(c);
                                    integer index = address.lastIndexOf(s);
                                    if( index> lastIndex)
                                    {
                                        lastIndex = index;
                                    }
                                }
                                if(lastIndex > 0)
                                {
                                    a.PersonMailingStreet = address.substring(0,lastIndex + 1);
                                    a.Customer_Prev_Previous_Address_District__c = address.substring(lastIndex + 1 );
                                } 
                                else
                                {
                                    a.Customer_Prev_Previous_Address_District__c = address;
                                }
                                
                                string mailingStreet = a.PersonMailingStreet;
                                string districtAddress = a.Customer_Prev_Previous_Address_District__c;
                               
                                if ( mailingStreet.Length() < districtAddress.Length())
                                {
                                    if(districtAddress.substring(0, mailingStreet.Trim().length()) == mailingStreet.trim())  
                                    {
                                        a.Customer_Prev_Previous_Address_District__c = a.Customer_Prev_Previous_Address_District__c.substring(mailingStreet.length());
                                    }
                                }
                                */  
                                                                
                              }                            
                        }
                  }
            }
      }

       /* C0684 ? */
      @future(callout = true)
      public static void DoTax (string newAccid, string weblogid)
      {
          string res ;
            
          res = UpdateEBSCustomer (newAccid, weblogid);
          System.debug ('the resuklt ' + res);
            
      }
      /* C0684 */
      

      public static String UpdateEBSCustomer(Account acc, String webLogId)
      {
        Debug__c log = new Debug__c();
        String processedResponse;
        
        System.debug('Account to update: ' + acc);
          
        WebLogClass wlClass = new WebLogClass();
        List<Web_Integration_Log__c> webLogs = [Select AccountId__c, AccountwithIBBId__c, ApplicantId__c, AssetRelationshipId__c, CreatedById, CreatedDate, Debug_Log__c, IsDeleted, 
                                                IntegrationTaskPerformed__c, LastModifiedById, LastModifiedDate, OpportunityId__c, OwnerId, 
                                                ConnectionReceivedId, Id, Request_Action__c, Request_Body__c, Request_Log_Date_Time__c, Request_Object_Type__c, Request_Output__c, 
                                                Request_Status__c, Response_Action__c, Response_Body__c, Response_Log_Date_Time__c, Response_Message_Name__c, Response_Object_Type__c, 
                                                Response_Output__c, Response_Status__c, ConnectionSentId, SystemModstamp, Name from Web_Integration_Log__c Where Id =: webLogId];             
        Web_Integration_Log__c webLog = webLogs[0];       
        webLog.AccountId__c = acc.id;
        wlClass.webLogsToUpsert.add(webLog); 
          
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', wlClass.webLogsToUpsert[0].Id);
        params.put('inId', acc.id);
        params.put('inObjectType', 'Account');
        params.put('inObjectResponseType', 'Account');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'MaintainCustomerDetails');
        params.put('inAction', 'MaintainCustomerDetails');
        params.put('inXmlMsgName', 'MaintainCustomerDetails');
        params.put('inXmlResponseMsgName', 'AddNewCustomerAllInformation');
         Map<String, String> overrideValues = new Map<String, String>();
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues, log);
        System.debug('UpdateEBSCustomer: Response - '  + returnString);
        if (returnString != null){
            processedResponse = OpportunityTriggerMethods.getStatusFromXML(returnString);
            //XMLMethods.sendResponseConfirmation(wlId, processedResponse, 'AddNewCustomer', wlClass);
        }
        
        System.debug('*** -- processedResponse = ' + processedResponse + ' -- ***');
        if ('FAILED'.equalsIgnoreCase(processedResponse))
        {
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS FAILED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
            //TODO: What to do in the event of a failure
        }
        else if ('BUFFERED'.equalsIgnoreCase(processedResponse))
        {
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS BUFFERED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
        }   
        
        return processedResponse;

      }

     /* C0684 */
      public static String UpdateEBSCustomer(string accid, String webLogId)
      {
        Debug__c log = new Debug__c();
        String processedResponse;
        
        System.debug('Account to update: ' + accid);
          
        WebLogClass wlClass = new WebLogClass();
        List<Web_Integration_Log__c> webLogs = [Select AccountId__c, AccountwithIBBId__c, ApplicantId__c, AssetRelationshipId__c, CreatedById, CreatedDate, Debug_Log__c, IsDeleted, 
                                                IntegrationTaskPerformed__c, LastModifiedById, LastModifiedDate, OpportunityId__c, OwnerId, 
                                                ConnectionReceivedId, Id, Request_Action__c, Request_Body__c, Request_Log_Date_Time__c, Request_Object_Type__c, Request_Output__c, 
                                                Request_Status__c, Response_Action__c, Response_Body__c, Response_Log_Date_Time__c, Response_Message_Name__c, Response_Object_Type__c, 
                                                Response_Output__c, Response_Status__c, ConnectionSentId, SystemModstamp, Name from Web_Integration_Log__c Where Id =: webLogId];             
        Web_Integration_Log__c webLog = webLogs[0];       
        webLog.AccountId__c = accid;
        wlClass.webLogsToUpsert.add(webLog); 
          
        Map<String, String> params = new Map<String, String>();
        params.put('inWebLogId', wlClass.webLogsToUpsert[0].Id);
        params.put('inId', accid);
        params.put('inObjectType', 'Account');
        params.put('inObjectResponseType', 'Account');
        params.put('inMessageType', 'Request');
        params.put('inWhichElement', 'MaintainCustomerDetails');
        params.put('inAction', 'MaintainCustomerDetails');
        params.put('inXmlMsgName', 'MaintainCustomerDetails');
        params.put('inXmlResponseMsgName', 'AddNewCustomerAllInformation');
         Map<String, String> overrideValues = new Map<String, String>();
        String returnString = WebServiceClass.sendRequest(params, wlClass, overrideValues , log);    
          
        
        System.debug('UpdateEBSCustomer: Response - '  + returnString);
        if (returnString != null){
            processedResponse = OpportunityTriggerMethods.getStatusFromXML(returnString);
            //XMLMethods.sendResponseConfirmation(wlId, processedResponse, 'AddNewCustomer', wlClass);
        }
        
        System.debug('*** -- processedResponse = ' + processedResponse + ' -- ***');
        if ('FAILED'.equalsIgnoreCase(processedResponse))
        {
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS FAILED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
            //TODO: What to do in the event of a failure
        }
        else if ('BUFFERED'.equalsIgnoreCase(processedResponse))
        {
            System.debug('*** -- MAINTAIN CUSTOMER DETAILS BUFFERED -- ***');
            System.debug('*** -- '+returnString +' -- ***');
        }   
        
        return processedResponse;

      }
      /* C0684 */
      
}