/**
* @author Chakravarthy Kancharla
* @date 25-01-2020
*
* @description Copy Request call back data from Lead to web form data object
*/
global class CopyRequestCallBackBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable
{
    private integer BatchSize = Integer.valueof(system.label.RequestCallBackBatchSize);

    // ************  Constructor  ************* //
    public CopyRequestCallBackBatch() {

    }

    // *************  Schedule Bit  **************** //
    global void execute(SchedulableContext sc)
    {        
        CopyRequestCallBackBatch batch = new CopyRequestCallBackBatch();
        database.executebatch(batch, BatchSize);

    } // end scheduled class

    // ************  START  ************* //
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('CopyRequestCallBackBatch.start() Entry');
        
        String query = 'Select Id,Title__c,First_Name__c,Last_Name__c,Phone_Number__c,Are_you_an_existing_customer__c,Type_of_product__c,New_Existing_Home_Finance_Application__c,Home_Finance_Product_Type__c,Current_Status__c,Property_Value__c,Size_Of_Deposit__c,Home_Finance_Reference_Number__c,New_Existing_Savings_Application__c,Savings_Account_Type__c,Deposit_Amount__c,Savings_Account_Reference_Number__c,Finance_Amount__c,Title,Title_Other__c,FirstName,LastName,Phone,Preferred_Call_back_time__c,Email__c,Postcode__c,Comments__c,Form_Type__c from Lead where Form_Type__c = \'Request Call Back\'';
        system.debug('query::' + query);
         
        return Database.getQueryLocator(query);
    }

    // ************  Execute  ************* //
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        system.debug('CopyRequestCallBackBatch.execute() Entry');
        system.debug('leadList: ' + leadList);    
        List<Web_Form_Data__c> webFormDataList = new List<Web_Form_Data__c>();
        for(Lead l: leadList){
            Web_Form_Data__c newRecord = new Web_Form_Data__c();
            newRecord.Are_you_an_existing_customer__c = l.Are_you_an_existing_customer__c!= null?boolean.valueof(l.Are_you_an_existing_customer__c):False;
            newRecord.Type_of_product_to_discuss__c = l.Type_of_product__c ;
            newRecord.New_Existing_Home_Finance_Application__c = l.New_Existing_Home_Finance_Application__c;
            newRecord.Home_Finance_Product_Type__c = l.Home_Finance_Product_Type__c;
            newRecord.Current_Status__c = l.Current_Status__c;
            newRecord.Property_Value__c = l.Property_Value__c;
            newRecord.Size_Of_Deposit__c = l.Size_Of_Deposit__c;
            newRecord.Home_Finance_Reference_Number__c = l.Home_Finance_Reference_Number__c;
            newRecord.New_Existing_Savings_Application__c = l.New_Existing_Savings_Application__c;
            newRecord.Savings_Account_Type__c = l.Savings_Account_Type__c;
            newRecord.Deposit_Amount__c = l.Deposit_Amount__c;
            newRecord.Savings_Account_Reference_Number__c = l.Savings_Account_Reference_Number__c;
            newRecord.Finance_Amount__c = l.Finance_Amount__c;
            newRecord.Title__c = l.Title__c;
            newRecord.Title_Other__c = l.Title_Other__c;
            newRecord.FirstName__c = l.First_Name__c;
            newRecord.LastName__c = l.Last_Name__c;
            newRecord.Preferred_phone_number__c = l.Phone_Number__c;
            newRecord.Email_Address__c = l.Email__c;
            newRecord.Preferred_Call_back_time__c = l.Preferred_Call_back_time__c;
            newRecord.Address_Postcode__c = l.Postcode__c;
            newRecord.Enquiry_Details__c = l.Comments__c;
            newRecord.Form_name__c = l.Form_Type__c;            
            webFormDataList.add(newRecord );
        }
        database.insert(webFormDataList);
        Delete leadList;
    }

    // ************  FINISH  ************* //
    global void finish(Database.BatchableContext BC){
        system.debug('CopyRequestCallBackBatch.finish() Entry');
    }
}