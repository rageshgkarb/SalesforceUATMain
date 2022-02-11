public with sharing class CaseHelperController {


    public list<String> caseRecordTypes{get;set;} //holds all the case record types that the logged-in user has access too

    public CaseHelperController(ApexPages.StandardController controller) {

       setAvailableRecordTypesForCase(Case.SObjectType);  
       
    }
    
      //C0786 ;Start;Complaints management
    @RemoteAction
    public static String redirect(String AccountID, String recordTypeName){
        String respondCaseURL;
        RespondService service = new RespondService();
        System.debug('recordTypeName'+recordTypeName);
        system.debug('AccountID'+AccountID);       
        if(AccountID != null){
        Account loggedinAccount = [select id,Respond_Case_Status__c from account where id= :AccountID limit 1];
        if(loggedinAccount.Respond_Case_Status__c   == 'Open' && recordTypeName == 'Customer Complaint - Respond'){
            return 'You can not log new complaint as one open complaint is associated with this account';     
        }else{
        RespondService.CreateCaseRequest data = RespondGetData.getUniqueIdandData(AccountID,recordTypeName);
        try {  
            RespondService.CreateCaseResponse response = service.CreateCase(data);
            respondCaseURL = response.url;
            system.debug('respondCaseURL '+response.url);
        }catch(RespondService.RespondException ex){
            system.debug('Exception from Respond'+ex.message);
            return ex.message;
        }      
            Account currentAccount = new Account();
            currentAccount  = [select id,Respond_Case_URL__c ,Respond_Unique_ID__c,Respond_Callout_Count__c  from account where id=:AccountID];
            if (recordTypeName != 'Customer Feedback - Respond'){
                if(respondCaseURL != null && (currentAccount.Respond_Case_URL__c == null || currentAccount.Respond_Case_URL__c != respondCaseURL)){             
                    currentAccount.Respond_Unique_ID__c = data.caseId ;
                    system.debug('currentAccount.Respond_Unique_ID__c'+currentAccount.Respond_Unique_ID__c);
                    if(currentAccount.Respond_Callout_Count__c == null)
                    currentAccount.Respond_Callout_Count__c  = 1;
                    else
                    currentAccount.Respond_Callout_Count__c  = currentAccount.Respond_Callout_Count__c + 1;
                    currentAccount.Respond_Case_URL__c = respondCaseURL;
                    system.debug('currentAccount.Respond_Case_URL__c'+currentAccount.Respond_Case_URL__c);
                    try{
                    update currentAccount;
                    }catch(Exception e){
                        system.debug('Exception in update'+e.getmessage());
                    }
                }  
        }else{
            if(currentAccount.Respond_Callout_Count__c == null)
            currentAccount.Respond_Callout_Count__c  = 1;
            else
            currentAccount.Respond_Callout_Count__c  = currentAccount.Respond_Callout_Count__c + 1;
            try{
            update currentAccount;
            }catch(Exception e){
                system.debug('Exception in update'+e.getmessage());
            }
            
        }
        }
        }else{
            if(recordTypeName != 'Customer Feedback - Respond')
            {
            RespondService.CreateCaseRequest data = new RespondService.CreateCaseRequest();
            data.respondCaseType = RespondService.RespondCaseType.COMPLAINT;
            RespondService.CreateCaseResponse response = service.CreateCase(data);
            respondCaseURL = response.url;
            }   
            else{
            RespondService.CreateCaseRequest data = new RespondService.CreateCaseRequest();
            data.respondCaseType = RespondService.RespondCaseType.COMPLIMENT_SUGGESTION;
            RespondService.CreateCaseResponse response = service.CreateCase(data);
            respondCaseURL = response.url;
            }
        }
        system.debug('returned value'+respondCaseURL);   
        return respondCaseURL; 
    }
    //C0786 ;End
    
    public void setAvailableRecordTypesForCase(Schema.SObjectType objType)     
    {
        caseRecordTypes = new list<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        // If there are 2 or more RecordTypes
        if (infos.size() > 1) {
            for (RecordTypeInfo ri : infos) {
               if (ri.isAvailable() 
               // Ignore the Master Record Type, whose Id always ends with 'AAA'.
               // We check the Id because Name can change depending on the user's language.
                && !String.valueOf(ri.getRecordTypeId()).endsWith('AAA')) {
                  
                    addRecordTypeToList(ri.getName(),ri.getRecordTypeId());
                
                }
            }
        } else {// Otherwise there's just the Master record type, so add it in, since it MUST always be available
        
            addRecordTypeToList(infos[0].getName(), infos[0].getRecordTypeId());
        }
 
    }

    //converts record to json format and adds to list
    void addRecordTypeToList(String name, String id)
    {
        Map<String, String> recordTypeMap = new Map<String, String>();      
        recordTypeMap.put('name',name );
        recordTypeMap.put('id',id );
        caseRecordTypes.add(JSON.serialize(recordTypeMap));
    }

    @RemoteAction
    public static Contact getInternalStaffContact() { //returns the internal staff contact & associated account id

       List<Contact> contacts = [SELECT id, accountId FROM Contact where account.name = 'Al Rayan Bank Staff' and User_lookup__c =:UserInfo.getUserId() limit 1];
     
       if(contacts.size()>0){
       
          return contacts[0];  
       
       }else {      
           return null;
       }
    }
    
    @RemoteAction
    public static string getWebFormFieldIdOfCase() {     
        WebFormFieldIdOnCase__c WebFormFieldIdOnCase = WebFormFieldIdOnCase__c.getValues('WebFormFieldIdOnCase');
        if(WebFormFieldIdOnCase.WebFormFieldId__c!=null)
            return WebFormFieldIdOnCase.WebFormFieldId__c;
        else
            return null;
    }
}