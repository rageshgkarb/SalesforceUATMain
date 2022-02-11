@isTest
private class ActionToPerformFromWebDataForm_Test {
    @testSetup 
    static void createData() {
        // Create common test account       
        Web_Form_Data__c webFormdata = new Web_Form_Data__c();
        webFormdata.FirstName__c='Test Account First Name';
        webFormdata.LastName__c='Test Account Last Name';
        webFormdata.Date_of_birth__c=Date.valueOf('2010-05-10');
        webFormdata.EBS_ID__c='12345';
        webFormdata.Email_Address__c='Test@Abc.com';
        insert webFormdata;
        
        //Create Account
        Account accountObj = new Account();
        //accountObj.Type='Prospect';
        accountObj.FirstName='Test Account First Name';
        accountObj.LastName='Test Account Last Name';
        accountObj.EBS_ID__c='12345';
        accountObj.PersonEmail='Test@Abc.com';
        accountObj.Date_of_Birth__c=Date.valueOf('2010-05-10');
        insert accountObj;
    }
    
    static testmethod void testWebFormData(){
        Test.startTest();
            // Get the webform Data 
            Web_Form_Data__c webForm = [SELECT Id FROM Web_Form_Data__c LIMIT 1]; 
            
            // Get the first test account by using a SOQL query
            Account acct = [SELECT Id FROM Account LIMIT 1];    
            
            // Instantiate PerformActionOnWebForm page  
            PageReference pageRefWebForm = Page.PerformActionOnWebForm;  
            Test.setCurrentPage(pageRefWebForm);
        	ApexPages.currentPage().getParameters().put('webDataFormId', webForm.Id); 
        
        	PageReference optyPage;
        	PageReference casePage;
        
        	//Calling without putting querystring Account Id parameter
        	ActionToPerformFromWebDataForm webFormClassObject = new ActionToPerformFromWebDataForm();
        
        	//Create Case
            casePage = webFormClassObject.createCase(); 
            
            //Create Opportunity            
            optyPage= webFormClassObject.checkCustomerLiablitiesEligibility(); 
            optyPage= webFormClassObject.checkHPPCAAEligibility(); 
        
        	//Calling with putting querystring Accountid parameter                         
            //webFormClassObject = new ActionToPerformFromWebDataForm();                        
            ApexPages.currentPage().getParameters().put('selectedAccountId', acct.Id);
             
            //Create Case
            casePage = webFormClassObject.createCase(); 
            
            //Create Opportunity            
            optyPage= webFormClassObject.checkCustomerLiablitiesEligibility(); 
            optyPage= webFormClassObject.checkHPPCAAEligibility(); 
            
        Test.stopTest();
    }
}