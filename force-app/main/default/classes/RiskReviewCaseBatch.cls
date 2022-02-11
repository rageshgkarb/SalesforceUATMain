/**
* @author Subramanian Jayaram
* @date 24-12-2018
*
* @group Review Customer Periodically Batch
*
* @description Batch job to create case
*/
global class RiskReviewCaseBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable
{
    private integer BatchSize = 20;

    // ************  Constructor  ************* //
    public RiskReviewCaseBatch() {

    }

    // *************  Schedule Bit  **************** //
    global void execute(SchedulableContext sc)
    {        
        RiskReviewCaseBatch batch = new RiskReviewCaseBatch();
        database.executebatch(batch, BatchSize);

    } // end scheduled class

    // ************  START  ************* //
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('RiskReviewCaseBatch.start() Entry');
        Date todaysDate = System.Today();
        if(Test.isRunningTest()){
            todaysDate = System.Today().addMonths(36);
        }
        // Case-01933907: Exclude medium and low risk customer from creating risk review cases
        String query = 'Select Id, FirstName, LastName, Name, Risk_Review_in_progress__c, Last_Risk_Review_Date__c, Next_Risk_Review_Date__c, Risk_Rating__c From Account Where Risk_Review_in_progress__c = FALSE AND Risk_Rating__c != \'Medium\' AND Risk_Rating__c != \'Low\' AND Next_Risk_Review_Date__c != NULL AND Next_Risk_Review_Date__c = NEXT_N_DAYS:100';
        system.debug('query::' + query);
         
        return Database.getQueryLocator(query);
    }

    // ************  Execute  ************* //
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        system.debug('RiskReviewCaseBatch.execute() Entry');
        system.debug('accountList: ' + accountList);     
        
        RiskUtils.raiseCaseforReviewRisk(accountList);
        
        List<Account> accountListToUpdate = new List<Account>();
        for(Account accountObj: accountList){
            Account accObj = new Account();
            accObj.id = accountObj.Id;
            accObj.Risk_Review_in_progress__c = TRUE;
            accountListToUpdate.add(accObj);
        }
        update accountListToUpdate;
    }

    // ************  FINISH  ************* //
    global void finish(Database.BatchableContext BC){
        system.debug('RiskReviewCaseBatch.finish() Entry');
    }
}