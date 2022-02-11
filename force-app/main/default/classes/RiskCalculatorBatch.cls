/**
* @author Gurdeep Singh
* @date 16-12-2018
*
* @group Risk Calculator Batch
*
* @description Batch job to recalculate the risk scores of all customers using the new RiskCalculator class
*/
global class RiskCalculatorBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable
{
	private integer BatchSize = 100;

    // **************************************
    // ************ Constructor *************
    // **************************************
	public RiskCalculatorBatch() {

	}

    // ***********************************************
    // ************* Schedule Bit    *****************
    // ***********************************************
    global void execute(SchedulableContext sc)
    {        
        RiskCalculatorBatch batch = new RiskCalculatorBatch();
        database.executebatch(batch, BatchSize);

    } // end scheduled class

    // **************************************
    // ************ START       *************
    // **************************************
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('RiskCalculatorBatch.start() Entry');

		String query = 'Select Id From Account Where Country_of_Residence__c!= \'\' and Country_of_nationality__c != \'\' and Sanctioned_Individual_Check__c != \'\' and Previously_Exited_or_Declined__c != \'\' and ';
		query += ' Source_of_Funds__c != \'\' and Employment_Type__c != \'\' and Face_to_face_Contact__c != \'\' and What_is_your_total_net_worth__c !=\'\'';
		system.debug('query::' + query);
		
		return Database.getQueryLocator(query);
	}


    // **************************************
    // ************ Execute     *************
    // **************************************
	global void execute(Database.BatchableContext BC, List<Account> accountList) {
		system.debug('RiskCalculatorBatch.execute() Entry');
		system.debug('accountList: ' + accountList);

		List<Account> accountListToUpdate = RiskCalculator.CalculateRiskScores(accountList);

		update accountListToUpdate;
	}

    // **************************************
    // ************ FINISH      *************
    // **************************************
	global void finish(Database.BatchableContext BC){
		system.debug('RiskCalculatorBatch.finish() Entry');
	}
}