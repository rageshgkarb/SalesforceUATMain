global class CleanPipeline implements Database.Batchable<sObject> {
	
	String query;
	
	global CleanPipeline() {
		String today = Datetime.now().format('yyyy-MM-dd');

		query = 'SELECT Id FROM Opportunity '
			+ 'WHERE ((CloseDate < ' + today + ' AND ForecastToleranceDate__c = null) '
            + 'OR Status_HPP_CAA__c = \'Abandoned\') '
			+ 'AND ForecastCategory IN (\'Pipeline\',\'BestCase\',\'Forecast\') '
			+ 'AND isClosed = false';
        
        System.debug(query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Opportunity[] opps = (Opportunity[])scope;

		for (Opportunity opp : opps) {
			opp.ForecastCategoryName = 'Omitted';
			opp.Batch_Omitted_Timestamp__c = Datetime.now();
		}

		try {
			update opps;
		}
		catch (Exception e) {
			system.debug('xxx error updating opportunities: ' + e.getMessage());
		}
	}
	
	global void finish(Database.BatchableContext BC) {}
}