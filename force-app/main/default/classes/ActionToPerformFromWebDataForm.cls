public with sharing class ActionToPerformFromWebDataForm {
    
    private final Id webDataFormId; //current web data form id
    public String action = null;
    public List<Account> accountSearchResult{get; set;}
    public boolean displayButtonsWithoutAccount{get; set;}
    //  = new List<Account>();
    //public string selectedAccountId{get; set;}
    private Web_Form_Data__c webFormData = new Web_Form_Data__c();
    
    public String getAction() {
        return action;
    }           
  
    public void setAction(String action) { this.action = action; }
    
    public ActionToPerformFromWebDataForm() {    
        //ApexPages.StandardController standardController      
       //webDataFormId = standardController.getId();//set the Web Data Form id 
       webDataFormId =  Apexpages.currentPage().getParameters().get('webDataFormId');
       doSearch();       
         
    }
   
   /*   public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('1','Create a case'));
        options.add(new SelectOption('2','Customer Liabilities Eligibility'));
        options.add(new SelectOption('3','HPP CAA Eligibility')); 
        
        return options;
    }*/
    
    public void doSearch() {
        try{            
            system.debug('action: ' + action);
        
            if(webDataFormId!=null){                
                webFormData = [select id,Name,FirstName__c,LastName__c,Date_of_birth__c,Email_Address__c,Are_you_an_existing_customer__c,EBS_ID__c,
                                        Title__c,Preferred_phone_number__c,Address_Postcode__c
                                 FROM Web_Form_Data__c WHERE id =:webDataFormId];
                if(webFormData!=null) {
                    accountSearchResult = [select id,FirstName,LastName,Date_of_Birth__c,EBS_ID__c,PersonEmail  from Account 
                                                    where (FirstName!=null and FirstName=:webFormData.FirstName__c) 
                                                    and (LastName!=null and LastName=:webFormData.LastName__c)
                                                    and (Date_of_Birth__c!=null and Date_of_Birth__c=:webFormData.Date_of_birth__c)];
                                                    //and (PersonEmail!=null and PersonEmail=:webFormData.Email_Address__c)];
                                                    
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }   
        
    }
    
   /* public void getSelected() {
        
        System.debug('Entered account selection block');
        selectedAccountId = ApexPages.currentPage().getParameters().get('accountid');       
    }  */     
    
    public PageReference createCase(){
        id selectedAccountId;
        try{
                if(Apexpages.currentPage().getParameters().get('selectedAccountId') != 'blank')
                    selectedAccountId =  Apexpages.currentPage().getParameters().get('selectedAccountId');
                    
                system.debug('selectedAccountId: ' +selectedAccountId);
                
                if (selectedAccountId !=null && webFormData.id != null){                    
                    updateWebFormData(selectedAccountId);
                }
                else {
                    //CREATE ACCOUNT
                    Account account = new Account();
                    account = createAccount();
                    selectedAccountId=account.Id;
                }
        }
        catch(Exception ex){
            throw ex;
        }       
        
        string caseUrl = '/apex/Case_Helper?WebFormDataName=' + webFormData.Name + '&def_account_id=' +selectedAccountId; 
        return new PageReference(caseUrl);
        //return null;
    }
    
    public PageReference checkCustomerLiablitiesEligibility(){
        id selectedAccountId;
        try{
                if(Apexpages.currentPage().getParameters().get('selectedAccountId') != 'blank')
                    selectedAccountId =  Apexpages.currentPage().getParameters().get('selectedAccountId');
                    
                system.debug('selectedAccountId: ' +selectedAccountId);
                
                if (selectedAccountId !=null && webFormData.id != null){                    
                    updateWebFormData(selectedAccountId);
                }
                else {
                    //CREATE ACCOUNT
                    Account account = new Account();
                    account = createAccount();
                    selectedAccountId=account.Id;
                }
        }
        catch(Exception ex){
            throw ex;
        }  
        //https://c.cs86.visual.force.com/apex/CAA_Eligibility?accountid=0017E00000Ef1lJ
        string cleURL = '/apex/CAA_Eligibility?webFormDataId=' + webDataFormId + '&accountid=' +selectedAccountId; 
        return new PageReference(cleURL);
    }
    
     
    public PageReference checkHPPCAAEligibility(){
        id selectedAccountId;
        try{
                if(Apexpages.currentPage().getParameters().get('selectedAccountId') != 'blank')
                    selectedAccountId =  Apexpages.currentPage().getParameters().get('selectedAccountId');
                    
                system.debug('selectedAccountId: ' +selectedAccountId);
                
                if (selectedAccountId !=null && webFormData.id != null){                    
                    updateWebFormData(selectedAccountId);
                }
                else {
                    //CREATE ACCOUNT
                    Account account = new Account();
                    account = createAccount();
                    selectedAccountId=account.Id;
                }
        }
        catch(Exception ex){
            throw ex;
        } 
        //https://c.cs86.visual.force.com/apex/MMR_eligibility?existingaccountid=0017E00000Ef1lJ
        string mmreURL = '/apex/MMR_eligibility?webFormDataId=' + webDataFormId + '&existingaccountid=' +selectedAccountId;
        return new PageReference(mmreURL);
    }
    
    private void updateWebFormData(Id selectedAccountId){
        try{
            webFormData.Are_you_an_existing_customer__c=true;
            for (Account account : accountSearchResult) {                       
                if ( (account.Id == selectedAccountId) && (account.EBS_ID__c!=null) ) {
                    webFormData.EBS_ID__c=account.EBS_ID__c; 
                    break;
                }                       
            }
            webFormData.Prospects_Customers__c=selectedAccountId;
            update webFormData;
        }
        catch(exception ex){
            throw ex;
        }
    }
    
    private Account createAccount(){
        Account account = new Account();
        try{                
                account.Salutation = webFormData.Title__c;
                account.FirstName = webFormData.FirstName__c;
                account.LastName = webFormData.LastName__c;
                account.Home_Telephone_No__c = webFormData.Preferred_phone_number__c;
                account.PersonEmail = webFormData.Email_Address__c;
                account.Date_of_Birth__c = webFormData.Date_of_birth__c;
                account.BillingPostalCode = webFormData.Address_Postcode__c;
                account.Web_Form_Data__c=webFormData.Id;
                    
                insert account;
        }
        catch(exception ex){
            throw ex;
        }
        
        return account;
    }
   /* public void proceedWithoutAccount(){
            String whetherToProceed;
            try{
                    whetherToProceed =  Apexpages.currentPage().getParameters().get('whetherToProceed');
                    if(whetherToProceed=='yes'){
                        displayButtonsWithoutAccount=true;
                    }
                    system.debug('displayButtonsWithoutAccount : '+ displayButtonsWithoutAccount);
            }
            catch(exception ex){
                throw ex;
            }
    }*/
}