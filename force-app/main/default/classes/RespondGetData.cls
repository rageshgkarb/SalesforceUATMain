public class RespondGetData{
    public static  RespondService.CreateCaseRequest getUniqueIdandData(String accountId, String recordtypeName){
        Account acc = [select id,Salutation,FirstName,LastName,BillingPostalCode,PersonEmail,Home_Telephone_No__c,PersonMobilePhone,Respond_Unique_ID__c,Respond_Callout_Count__c,EBS_ID__c,BillingStreet,Customer_Address_District__c,BillingCity,Respond_Case_URL__c from account where id=:accountId limit 1];
        system.debug('acc'+acc);
        if(acc.Respond_Callout_Count__c == null){
            acc.Respond_Callout_Count__c = 1;
            acc.Respond_Unique_ID__c = acc.id + String.valueOf(acc.Respond_Callout_Count__c);
            system.debug('acc.Respond_Callout_Count__c'+acc.Respond_Callout_Count__c);
            system.debug('acc.Respond_Unique_ID__c'+acc.Respond_Unique_ID__c);
        }else{
            acc.Respond_Callout_Count__c = acc.Respond_Callout_Count__c +1;
            acc.Respond_Unique_ID__c = acc.id + String.valueOf(acc.Respond_Callout_Count__c);
            system.debug('acc.Respond_Callout_Count__c'+acc.Respond_Callout_Count__c);
            system.debug('acc.Respond_Unique_ID__c'+acc.Respond_Unique_ID__c);
        }
        RespondService.CreateCaseRequest data = new RespondService.CreateCaseRequest();
        data.title =   acc.Salutation;
        data.firstName = acc.FirstName;
        data.lastName  = acc.LastName;
        data.postalCode = acc.BillingPostalCode;
        data.emailAddress  = acc.PersonEmail;
        data.homePhone   = acc.Home_Telephone_No__c;
        data.mobilePhone  = acc.PersonMobilePhone;
        data.ebsId   = acc.EBS_ID__c;
        data.addressStreet = acc.BillingStreet;
        data.addressLine2 = acc.Customer_Address_District__c;
        data.addressCity = acc.BillingCity;
        data.caseId = acc.Respond_Unique_ID__c;
        data.contactId = acc.Id;
        if(recordtypeName == 'Customer Feedback - Respond')
        data.respondCaseType = RespondService.RespondCaseType.COMPLIMENT_SUGGESTION;
        else
        data.respondCaseType = RespondService.RespondCaseType.COMPLAINT;
        system.debug('data'+data);
        return data;
    }
}