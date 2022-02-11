/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing Class idVerification_Controller{
    @AuraEnabled
    public static list<Salesforce_ID_Questions__mdt> returnData(){
        return [SELECT id,Order__c,Field_Api__c,Available_for_Application_Security__c,Available_for_Manual_PSN__c,Available_for_Manual_Security__c,Available_for_PSN_Verified__c,Question__c,Section_2__c,
        Available_for_Outbound__c FROM Salesforce_ID_Questions__mdt ORDER BY Order__c ASC];
             
    }
    // To fecth account and its opportunities
    @AuraEnabled
    public static list<Account> returnAccount(string accountId){
        
        
        return [SELECT id,FirstName,LastName,BillingAddress,Date_of_Birth__c,Mother_s_family_name_security_question__c,Town_of_Birth__c,Home_Telephone_No__c,PersonMobilePhone,PersonEmail,        
        BillingStreet,BillingCity,BillingPostalCode,BillingCountry, (SELECT id,Name,Seller__c,Seller__r.name,User_IBB_Division__c,User_Branch__c,Owner.Name,CreatedDate   FROM Opportunities ORDER BY CreatedDate DESC LIMIT 50) FROM Account WHERE Id=:accountId];
             
    }
    
    @AuraEnabled
    public static void createAlert(string accountId,string alertmessage){
        if(!string.isBlank(alertmessage)){
            string message = '';
            for(string str:alertmessage.split('\n')){
                system.debug('inside loop***:'+str);
                message +=  str + '\n';    
            }
            system.debug('Message to be saved:'+message );
            Alert__c alert = new Alert__c();
            alert.Alert__c = message;
            alert.Prospect_Customer__c = accountId;
            alert.Expiry_Date__c = date.today().addDays(1);
            alert.Active__c = true;
            alert.Alert_Type__c = 'Security';
            insert alert;
        }
    }
    
    
}