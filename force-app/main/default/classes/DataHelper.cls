/* -------------------------------------------------------------------------------------- */
/* C00098 Add Method GetValuationReports                                                  */
/* -------------------------------------------------------------------------------------- */
/* C00103    Get the Account with IBB list from the EBS Account Number                    */
/* -------------------------------------------------------------------------------------- */
/* C00106    GetOpportunity - get Product Name and Record Type Name                       */ 
/* -------------------------------------------------------------------------------------- */
/* C00170    GetPaymentTypes - get the List of Payment Types                              */
/* -------------------------------------------------------------------------------------- */
/* C00233    Need recordtype.developername added to query for GetAccount                   */
/* -------------------------------------------------------------------------------------- */

public class DataHelper
{
    public static String GenerateFields(List<Schema.SObjectField> fldObjMapValues )
    {
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theLabel = s.getDescribe().getLabel(); // Perhaps store this in another map
            String theName = s.getDescribe().getName();
            // String theType = s.getDescribe().getType(); // Perhaps store this in another map

            // Continue building your dynamic query string
            theQuery += theName + ',';
        }

        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        return theQuery;
    }
    
    public static String ConvertListToString(List<String> data)
    {
        boolean first = true;
        String returnValue;
        for(String s : data)
        {
            if(first)
            {
                returnValue = '\'' + s + '\'';
                first=false;
            }
            else
            {
                returnValue += ',' + '\'' + s + '\'';
            }
        }
        return returnValue;
    }

    public static List<Account> GetAccount(String id)
    { 
        Boolean normalAccount = false;
        List<Account> acc = [select id, isPersonAccount from account where id=:id];
        
        if(acc.size() == 1 )
        {
            if(!acc[0].IsPersonAccount)
            {
                normalAccount = true;
            }
        }
        String theQuery;
        if(normalAccount)
        {
            theQuery = QueryGenerator.GetAccountCustomerQuery();
        }   
        else
        {
            theQuery = QueryGenerator.GetAccountQuery();
        }         
       
        /* C00233 start */
        theQuery += ', recordtype.developername ';
        /* C00233 end */ 
        
        theQuery += ' from account WHERE id = \'' + id + '\'';

        return Database.query(theQuery);
    }
    
    public static List<Account> GetAccounts(String accountIds, boolean UseAccountCustomerQuery)
    {    
        // C0644 Need to force a different query now the list contains a business account
        String theQuery;
        if(UseAccountCustomerQuery)
        {
            theQuery = QueryGenerator.GetAccountCustomerQuery();
        }
        else
        {
            theQuery = QueryGenerator.GetAccountQuery();
        }

        theQuery +=  ' , RecordType.DeveloperName  from account WHERE id in  ' + accountIds ;        

        return Database.query(theQuery);
    }
    
    public static List<Account> GetAccountByOpportunity(String oppId)
    {   
        Opportunity opp = GetOpportunity(oppid)[0]; 
        string accountId = opp.Account.Id;
       
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        theQuery = theQuery.Replace('LastReferencedDate,','');
        theQuery = theQuery.Replace('LastViewedDate,','');
        theQuery = theQuery.Replace('BillingLongitude,','');
        theQuery = theQuery.Replace('PersonMailingLatitude,','');
        theQuery = theQuery.Replace('PersonOtherLongitude,','');
        theQuery = theQuery.Replace('PersonOtherLatitude,','');
        theQuery = theQuery.Replace('ShippingLongitude,','');
        theQuery = theQuery.Replace('ShippingLatitude,','');
        theQuery = theQuery.Replace('BillingLatitude,','');
        theQuery = theQuery.Replace('ShippingAddress,','');
        theQuery = theQuery.Replace('BillingAddress,','');
        theQuery = theQuery.Replace('PersonOtherAddress,','');
        theQuery = theQuery.Replace('PersonMailingAddress,','');
        
        /* C0551 */
        theQuery = theQuery.Replace('NVMContactWorld__NVM_Phone__c,','');
        theQuery = theQuery.Replace('PhotoUrl,','');
        theQuery = theQuery.Replace('BillingGeocodeAccuracy,','');
        theQuery = theQuery.Replace('ShippingGeocodeAccuracy,','');
        theQuery = theQuery.Replace('PersonMailingGeocodeAccuracy,','');
        theQuery = theQuery.Replace('PersonOtherGeocodeAccuracy,','');

        // Finalize query string
        //theQuery += ',Opportunity.id FROM Account WHERE Opportunity.id= \'' + oppId + '\'';
        theQuery += ' FROM Account WHERE Id =  \'' + accountId + '\'';

        system.debug(theQuery);

        // Make dynamic call
        Account[] accList = Database.query(theQuery);
        return accList;
    }
        
    public static List<Opportunity> GetOpportunity(String id)
    {
       String theQuery = QueryGenerator.GetOpportunityQuery(); 

        // Finalize query string
        /* C00106
        theQuery += ',account.id,Account.No_of_Opportunities__c FROM Opportunity WHERE id = \'' + id + '\'';
        */
        theQuery += ',account.id,Account.No_of_Opportunities__c, ' ;
        theQuery += 'recordtype.Name,recordtype.developername,ibb_product__r.Term__c, ibb_product__r.name, ibb_product__r.Marketing_product_code__c, '; //ibb_product__r.Term__c as part of C0779: 5 Years Fixed Rental rate
        theQuery += 'Switched_From_Opp__r.account_with_ibb__r.name, account_with_ibb__r.name ';
        theQuery += 'FROM Opportunity WHERE id = \'' + id + '\'';
        /* C00106 end */
        
       return Database.query(theQuery);

    }
    
     public static List<HPP_extended_opportunity__c> GetHPPExtendedOpportunity(String id)
    {
        String theQuery = QueryGenerator.GetExtendedOpportunityQuery();
        theQuery += ' from HPP_extended_opportunity__c WHERE id = \'' + id + '\'';

        return Database.query(theQuery);
    }
    
     public static List<HPP_extended_opportunity__c> GetHPPExtendedOpportunityByOpp(String id)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.HPP_extended_opportunity__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ',Opportunity__r.id  FROM HPP_extended_opportunity__c WHERE Opportunity__r.id = \'' + id + '\'';

       

        // Make dynamic call
        HPP_extended_opportunity__c[] extOppList = Database.query(theQuery);
        return extOppList;
    }
    
    
     public static List<HPP_extended_opportunity__c> GetHPPExtendedOpportunityFromOpportunity(String oppId)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.HPP_extended_opportunity__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM HPP_extended_opportunity__c WHERE opportunity__c = \'' + oppId + '\'';

        

        // Make dynamic call
        HPP_extended_opportunity__c[] extOppList = Database.query(theQuery);
        return extOppList;
    }  
    
    public static List<Applicant__c> GetOpportunityAccountsDetails(string oppId)
    {
           
        String theQuery = 'Select Prospect_Customer__r.id,Prospect_Customer__r.US_Person_Check__c FROM Applicant__c WHERE Opportunity__r.id = \'' + oppId+ '\' order by Applicant_Number__c';
        List<Applicant__c> ids = Database.query(theQuery);
        System.debug('ids='+ids);
        return ids;
    }  
    
    public static List<Applicant__c> GetApplicants(String opportunityId)
    {    
        String theQuery = QueryGenerator.GetApplicantQuery();
        theQuery += ', Prospect_Customer__r.id    FROM Applicant__c WHERE Opportunity__r.id = \'' + opportunityId+ '\' order by Applicant_Number__c';

        return Database.query(theQuery);
    }
    
    public static List<Account_with_IBB__c> GetTheAccountWithIBB(string opportunityId)
    {
        String theQuery = QueryGenerator.GetAccountWithIBBQuery();
        theQuery += ' from Account_with_IBB__c  WHERE Opportunity__c = \'' + opportunityId+ '\'';

        return Database.query(theQuery);
    }
    
    public static List<Account_Reference_Information__c> GetAccountReferenceInfo(string accountType)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account_Reference_Information__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Account_Reference_Information__c WHERE Request_Type__c= \'' + accountType + '\'';

        

        // Make dynamic call
        Account_Reference_Information__c[] accRefList = Database.query(theQuery);
        return accRefList;
    }
    
     /* C00096 */
    public static List<Account_Reference_Information__c> GetAccountReferenceInfo(string accountType, 
                                                                                    string paymentType)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account_Reference_Information__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Account_Reference_Information__c WHERE Request_Type__c= \'' + accountType + '\'' +
                    ' AND Payment_Type__c = \'' + paymentType + '\'';

        

        // Make dynamic call
        Account_Reference_Information__c[] accRefList = Database.query(theQuery);
        return accRefList;
    }
    /* C00096 end */
    
    public static List<Asset_Relationship__c> GetAccountHolders(String accountIds)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Asset_Relationship__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery +=  ' FROM Asset_Relationship__c WHERE Prospect_Customer__c in  ' + accountIds ;

        
        // Make dynamic call
        Asset_Relationship__c[] accList = Database.query(theQuery);
        return accList;
    }
    
    public static List<Asset_Relationship__c> GetAccountHoldersByAccountWithIBB(String accountIds, 
                                                                                string AccountWithIBBId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Asset_Relationship__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery +=  ' FROM Asset_Relationship__c WHERE Account_With_IBB__c = \'' + accountWithIBBId + '\'';
        theQuery += ' AND Prospect_Customer__c in  ' + accountIds ;
        

        // Make dynamic call
        Asset_Relationship__c[] accList = Database.query(theQuery);
        return accList;
    }
    
    
    
    public static List<Credit_Score__c> GetCreditScores(String accountIds, string OpportunityId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Credit_Score__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery +=  ' FROM Credit_Score__c WHERE Prospect_Customer__c in  ' + 
                        accountIds +
                        ' AND Opportunity__c = \'' + OpportunityId + '\'' +
                        ' AND DecisionEnginePerformed__c = false ' +
                        ' ORDER BY CreatedDate DESC ';

        
        // Make dynamic call
        Credit_Score__c[] accList = Database.query(theQuery);
        return accList;
    }
    
    public static List<Event__c> GetEvent(String eventId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Event__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += '     FROM Event__c WHERE id = \'' + eventId + '\'';

        // Make dynamic call
        Event__c[] appList = Database.query(theQuery);
        return appList;
    }
    
    public static List<Event__c> GetEvents(List<string> eventIds)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Event__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += '     FROM Event__c WHERE id in  (' + ConvertListToString(eventIds)+ ')';

        // Make dynamic call
        Event__c[] appList = Database.query(theQuery);
        return appList;
    }    
    
     public static List<Event__c> GetEventsByType(String eventType)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Event__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += '     FROM Event__c WHERE EventType__c = \'' + eventType+ '\' order by name';

        

        // Make dynamic call
        Event__c[] appList = Database.query(theQuery);
        return appList;
    }
 
    public static List<Event__c> GetEvents(String opportunityId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Event__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ', Related_to__r.id     FROM Event__c WHERE Related_to__r.id = \'' + opportunityId+ '\'  ORDER BY name desc';

        
        // Make dynamic call
        Event__c[] appList = Database.query(theQuery);
        return appList;
    }
    
    public static List<EventLog__c > GetEventLog(String eventId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.EventLog__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ',Event__r.id    FROM EventLog__c WHERE id = \'' + eventId+ '\'';

       

        // Make dynamic call
        EventLog__c [] appList = Database.query(theQuery);
               
        
        return appList;
    }
    
    public static List<EventCase__c> GetEventCase(String caseId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.EventCase__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM EventCase__c WHERE id = \'' + caseId+ '\'';

        

        // Make dynamic call
        EventCase__c[] caseList = Database.query(theQuery);               
        
        return caseList ;
    }
    
    public static List<EventCase__c> GetEventCaseByEvent(String eventId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.EventCase__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ', event__r.id FROM EventCase__c WHERE event__r.id = \'' + eventId+ '\'';

       

        // Make dynamic call
        EventCase__c[] caseList = Database.query(theQuery);               
        
        return caseList ;
    }
    
    public static List<EventLog__c> GetEventLogByOpportunityAll(String opportunityId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.EventLog__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ', Opportunity__r.id     FROM EventLog__c WHERE Opportunity__r.id = \'' + opportunityId+ '\'  ORDER BY createddate desc';

     

        // Make dynamic call
        EventLog__c[] appList = Database.query(theQuery);
        return appList;
    }
    
    public static List<EventLog__c> GetEventLogByOpportunity(String opportunityId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.EventLog__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ', Opportunity__r.id     FROM EventLog__c WHERE Opportunity__r.id = \'' + opportunityId+ '\' and isExpired__c = false  ORDER BY name desc';

     

        // Make dynamic call
        EventLog__c[] appList = Database.query(theQuery);
        return appList;
    }
    
    public static List<Account> GetApplicantsByOpp(String oppId)
    {
         Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += '   FROM Account WHERE Id in (select Prospect_Customer__c from Applicant__c where Opportunity__c = \'' + oppId+ '\'  )          ';

      

        // Make dynamic call
        Account[] appList = Database.query(theQuery);
        return appList;
    } 

    public static List<EventLog__c> GetValidEventLogs(String opportunityId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.EventLog__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ', Opportunity__r.id     FROM EventLog__c WHERE IsExpired__c= false and  Opportunity__r.id = \'' + opportunityId+ '\'  ORDER BY name desc';

      

        // Make dynamic call
        EventLog__c[] appList = Database.query(theQuery);
        return appList;
    }

    // C0644 Need to just get the Product SubType
    public static string GetProductSubType(String productId)
    {    
        String subType = '';

        IBB_Product__c[] prodList = [SELECT ID,ProductSubType__c FROM IBB_Product__c WHERE id =:productId];
        if(prodList.size()>0)
        {
            subType=prodList[0].ProductSubType__c;
        }
        return subType;
    }

    // C0644 Retrieve the Opportunitie's Product SubType
    public static string GetProductSubTypeFromOpportunity(string opportunityID)
    {
        String subType;

        Opportunity[] oppList = [SELECT ID,ProductSubType__c FROM Opportunity WHERE id =:opportunityID];
        if(oppList.size()>0)
        {
            subType=oppList[0].ProductSubType__c;
        }
        return subType;
    }

    // C0695 Retrieve the Opportunity's Product
    public static string GetProductIDFromOpportunity(string opportunityID)
    {
        String id;

        Opportunity[] oppList = [SELECT ID,IBB_Product__c FROM Opportunity WHERE id =:opportunityID];
        if(oppList.size()>0)
        {
            id=oppList[0].IBB_Product__c;
        }
        return id;
    }
    
    public static List<IBB_Product__c> GetProduct (String productId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.IBB_Product__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM IBB_Product__c WHERE id = \'' + productId+ '\'    ';

     

        // Make dynamic call
        IBB_Product__c[] appList = Database.query(theQuery);
        return appList;
    }
    
    public static List<IBBQuotation__c> GetQuotations (String oppID)
    {
        return [SELECT    ID,
                          Name,
                          QuoteReference__c,
                          Sequence__c,
                          QuoteDate__c
               FROM       IBBQuotation__c
               WHERE      Opportunity__c = :oppID
               ORDER BY   Sequence__c DESC];
                          
    }
    
    public static List<IBBQuotation__c> GetQuotationsFromOpportunity (string oppid)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.IBBQuotation__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );
        theQuery += ' FROM IBBQuotation__c WHERE Opportunity__c =   \'' + oppid + '\'    ';
        theQuery += ' AND Sequence__c != null ';
        theQuery += ' ORDER BY Sequence__C DESC ';
       
        // Make dynamic call
        IBBQuotation__c[] appList = Database.query(theQuery);
        return appList;    
    }
    
    public static List<Budget_planner__c> GetBudgets(string accountIds)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Budget_planner__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Budget_planner__c WHERE Person__c in   ' + accountIds ;

      
        // Make dynamic call
        Budget_planner__c[] appList = Database.query(theQuery);
        return appList;    
    }
    
    public static List<Budget_planner__c> GetBudget(string oppId)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Budget_planner__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Budget_planner__c WHERE Opportunity__c =: oppId ' ;

      

        // Make dynamic call
        Budget_planner__c[] appList = Database.query(theQuery);
        return appList;    
    }    
    
    public static List<Person_Debts__c> GetDebts(String accountids)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Person_Debts__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Person_Debts__c WHERE Owner_of_debt__c in ' +  accountids;


        // Make dynamic call
        Person_Debts__c[] accList = Database.query(theQuery);
        return accList;
    }
    
      public static List<event__c > GetEventsByIds(String eventIds)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.event__c .fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM event__c WHERE id in ' +  eventIds;

       
        // Make dynamic call
        event__c [] accList = Database.query(theQuery);
        return accList;
    }
    
    public static List<Property_information__c> GetPropertyInfo(String accountids)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Property_information__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Property_information__c WHERE PersonAccount__c in   ' + accountids ;

     

        // Make dynamic call
        Property_information__c [] accList = Database.query(theQuery);
        return accList;
    }
    
    public static List<Other_adults_in_the_property__c> GetOtherAdults(String oppId)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Other_adults_in_the_property__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Other_adults_in_the_property__c WHERE HPP_Application__c = \'' + oppId+ '\'' ;

    
        // Make dynamic call
        Other_adults_in_the_property__c[] accList = Database.query(theQuery);
        return accList;
    }
    
      public static List<ProductEventDirector__c> GetDirector(String directorId )
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.ProductEventDirector__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM ProductEventDirector__c  WHERE id= \'' + directorId + '\'' ;

        system.debug('Query :' + theQuery);

        // Make dynamic call
        ProductEventDirector__c[] accList = Database.query(theQuery);
        return accList;
    }
    
    
    public static List<Account> GetExistingAccounts(String firstName, String lastName, Date dob)
    {
        return  [select id,SFDC_ID__c, firstname, lastname,EBS_ID__c, salutation, date_of_birth__c from Account where firstname=:firstname and lastname=:lastname and Date_of_Birth__c =: dob  ];
    
    }
    
    public static List<Case> GetCases(String oppId)
    {
        return  [select id,Subject,Referral_Decision__c,Credit_accepted__c,Credit_comments__c , comments__c, BDM_Comments__c , ContactId, CaseNumber,Satisfied__c,  description from Case where Opportunity__c=:oppId];
    
    }    
    
    public static List<GenericObject__c> GetGenericObjectByAccount(String accountIds)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.GenericObject__c .fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM GenericObject__c WHERE Account__c in '  + accountIds ; 

    

        // Make dynamic call
        GenericObject__c[] accList = Database.query(theQuery);
        return accList;
    }
    
    public static List<GenericObject__c> GetGenericObject(String opp)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.GenericObject__c .fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM GenericObject__c WHERE Opportunity__c = \'' + opp+ '\'' ; 

   

        // Make dynamic call
        GenericObject__c[] accList = Database.query(theQuery);
        return accList;
    }


    
    public static string SetStringList(string inStr)
    {
        return '\'' + inStr + '\'';
    }
    public static List<Valuation_Table__c> GetValuationTableFromValType (String valuationType, string valuationId)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Valuation_Table__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Valuation_Table__c WHERE Type_of_valuation__c = \'' + valuationType + '\'';
        theQuery += ' AND Id = \'' + valuationId + '\'';

        system.debug(theQuery);

        // Make dynamic call
        Valuation_Table__c[] valTabList = Database.query(theQuery);
        return valTabList ;
    }
    
    public static List<Valuation_Report__c> GetValuationReportFromOpp (String oppId)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Valuation_Report__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        string reportStatus = 'InstructionCreated';
        theQuery += ' FROM Valuation_Report__c WHERE Opportunity__c = \'' + oppId + '\'';
        //theQuery += ' AND ReportStatus__c = \'' + reportStatus + '\'';

   

        // Make dynamic call
        Valuation_Report__c[] valRepList = Database.query(theQuery);
        return valRepList ;
    }
    
    public static List<Valuation_Report__c> GetValuationReportFromOppName (String oppName)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Valuation_Report__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        string reportStatus = 'InstructionCreated';
        theQuery += ' FROM Valuation_Report__c WHERE LenderReference__c = \'' + oppName + '\'';
       
   

        // Make dynamic call
        Valuation_Report__c[] valRepList = Database.query(theQuery);
        return valRepList ;
    }
    
    public static List<Valuation_Notification__c> GetValuationNotificationFromValuationReport (String valRepId)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Valuation_Notification__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        
        theQuery += ' FROM Valuation_Notification__c WHERE Valuation_Report__c = \'' + valRepId + '\'';
        


        // Make dynamic call
        Valuation_Notification__c[] valNoteList = Database.query(theQuery);
        return valNoteList ;
    }  
    
    /* C00103 start */
    public static List<Account_With_IBB__c> GetTheAccountsfromEBSAccount (string accountNos)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account_With_IBB__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        
        theQuery += ' FROM Account_With_IBB__c WHERE Name in ' + accountNos;
        

        system.debug(theQuery);

        // Make dynamic call
        Account_With_IBB__c[] accountList = Database.query(theQuery);
        return accountList ;
    }
    /* C00103 end */ 
    
    /* C00170 start */
    public static List<IBBPaymentType__c> GetPaymentTypes ()
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.IBBPaymentType__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        
        theQuery += ' FROM IBBPaymentType__c  ';
        
        // Make dynamic call
        IBBPaymentType__c[] paymentTypeList = Database.query(theQuery);
        return paymentTypeList ;
    }
    
    //CP00226 Start
    public static List<Log__c> GetLog (string logId)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Log__c.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );
        
        theQuery += ' FROM Log__c WHERE id = \'' + logId + '\'' ;
        

        system.debug(theQuery);

        // Make dynamic call
        Log__c[] logList= Database.query(theQuery);
        return logList;
    }
    //CP00226 End    
}