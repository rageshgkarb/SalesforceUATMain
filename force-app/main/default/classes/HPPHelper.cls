public class HPPHelper
{
    public static Boolean CheckFTVIsValid(Opportunity opp)
    {
        system.debug('Check valid value;' + opp.ftv_valid__c);
        
        if(!Opp.FTV_Valid__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'FTV is no longer valid for this product'));
        }
        return Opp.FTV_Valid__c;
    }
    
    public static String CompleteEvent(ID eventlogId)
    {       
        //load event log
        List<EventLog__c> log = [select id, Event__c, Opportunity__r.ProductEventDirector__c ,opportunity__r.ibb_product__r.Product_code__c       
                                from eventlog__c where id=:eventLogId];
                                
        if(log.size() == 0) return null; 
    
        /*
        //Check required fields
        system.debug('Checking required fields');
        if(!CheckRequiredFields())
        {
            system.debug('CheckRequiredFields - fields requried');
            return null;
        }
        */
    
        //IsCompleted =true;             
        IBBEvents director = new IBBEvents(log[0].opportunity__r.ProductEventDirector__c);
        
        //check    
        Boolean returnValue = director.CompleteEvent(log[0], log[0].opportunity__r); 
        
        if(!returnValue) return null;
         
        system.debug('Return value is :' + returnValue);
        
              
                
        EventLog__c CreatedEvent = director.GetCreatedEvent(); 
        system.debug('Created Event : ' + CreatedEvent);
        system.debug('Error : ' + director.ErrorMessage());
        
        string NextEventUrl ;
        
        if(director.GetCreatedEventLocation() != null)
        {
            NextEventUrl  = director.GetCreatedEventLocation();// + '?id=' +CreatedEvent.id;
        }
        else
        {
            NextEventUrl  = string.valueof(CreatedEvent);
            
            Event__c event = [select id,CustomPageLocation__c  from Event__c where id=:CreatedEvent.Event__c];
            
                    
            NextEventUrl  = event.CustomPageLocation__c;//   +'?id=' + CreatedEvent.id;
        }
        
        
        if(false)//IsGuestUser())
        {
            NextEventUrl += '?extid=' + CAA_Helper.EncryptData(CreatedEvent.Id) ;
        }
        else
        {
            NextEventUrl += '?id=' + CreatedEvent.Id;
        }
        
        //if(log[0].opportunity__r.ibb_product__c != null && log[0].opportunity__r.ibb_product__r.Product_code__c != null)
        //NextEventUrl +=  '&product=' + log[0].opportunity__r.ibb_product__r.Product_code__c ;
        
        
        system.debug('Director.Created Event ' + director.GetCreatedEvent());
        system.debug('Created Event ' + CreatedEvent );
        
        if(false)//IsGuestUser())
            NextEventUrl = NextEventUrl.replace('/apex/','');
        
        
        return NextEventUrl ; 
    }  
    
    public static List<CAA_Data.KeyValue> InternalAccounts(String accountEBSID)
    {        
        List<CAA_Data.KeyValue> lst = new List<CAA_Data.KeyValue>();
        lst.add(new CAA_Data.KeyValue('','-- Please select --'));
        List<Asset_Relationship__c> bankAccounts = [SELECT Id,
                                                             Account_With_IBB__c,
                                                             Customer_EBS_ID_from_profile__c,
                                                             Account_with_IBB_Number__c,
                                                             Account_with_IBB__r.External_Account_Number__c,
                                                             Account_with_IBB__r.EBS_ID__c,
                                                             Account_with_IBB__r.EBS_Customer_Number__c
                                                    FROM  Asset_Relationship__c
                                                    WHERE Customer_EBS_ID_from_profile__c = :accountEBSID
                                                    AND   Customer_EBS_ID_from_profile__c != null
                                                    AND   Account_with_IBB__r.External_Account_Number__c != null];
                                                    
        if ( bankAccounts.Size() > 0 )
        {
            for (Asset_Relationship__c bankAccount : bankAccounts)
            {
                system.debug ('This is ID ' + bankAccount.Id);
                system.debug ( 'this is EBS ID ' + 
                                bankAccount.Customer_EBS_ID_from_profile__c);
                system.debug ( 'This is EBS Account ' + 
                                bankAccount.Account_with_IBB__r.External_Account_Number__c);
                                
                string suffix = bankAccount.Account_with_IBB_Number__c.Substring (10);
                integer iSuffix = integer.valueof(suffix);
                
                if (iSuffix < 80)
                {
                                
                    CAA_Data.KeyValue opt = new CAA_Data.KeyValue(bankAccount.Account_with_IBB_Number__c, 
                                                        bankAccount.Account_with_IBB__r.External_Account_Number__c);
                    system.debug ( 'This is opt ' + opt);
                    
                    lst.Add (opt);
                }
            }
        }            
        system.debug ('This is lst ' + lst);                                               
        return lst;            
    }
    
    public static List<SelectOption> InternalAccountsOptionsList(String accountEBSID)
    {   
        List<SelectOption> lst = new List<SelectOption>();
        lst.add(new SelectOption('--','-- Please select --'));
        List<Asset_Relationship__c> bankAccounts = [SELECT Id,
                                                             Account_With_IBB__c,
                                                             Customer_EBS_ID_from_profile__c,
                                                             Account_with_IBB_Number__c,
                                                             Account_with_IBB__r.External_Account_Number__c,
                                                             Account_with_IBB__r.EBS_ID__c,
                                                             Account_with_IBB__r.EBS_Customer_Number__c
                                                    FROM  Asset_Relationship__c
                                                    WHERE Customer_EBS_ID_from_profile__c = :accountEBSID
                                                    AND   Customer_EBS_ID_from_profile__c != null
                                                    AND   Account_with_IBB__r.External_Account_Number__c != null];
                                                    
        if ( bankAccounts.Size() > 0 )
        {
            for (Asset_Relationship__c bankAccount : bankAccounts)
            {
                system.debug ('This is ID ' + bankAccount.Id);
                system.debug ( 'this is EBS ID ' + 
                                bankAccount.Customer_EBS_ID_from_profile__c);
                system.debug ( 'This is EBS Account ' + 
                                bankAccount.Account_with_IBB__r.External_Account_Number__c);
                                
                string suffix = bankAccount.Account_with_IBB_Number__c.Substring (10);
                integer iSuffix = integer.valueof(suffix);
                
                if (iSuffix < 80)
                {
                                
                    SelectOption opt = new SelectOption (bankAccount.Account_with_IBB_Number__c, 
                                                        bankAccount.Account_with_IBB__r.External_Account_Number__c);
                    system.debug ( 'This is opt ' + opt);
                    
                    lst.Add (opt);
                }
            }
        }            
        system.debug ('This is lst ' + lst);                                               
        return lst;            
    }
}