global class ForecastTolerancesCheck implements Database.Batchable<SObject> {
	global String queryString = 'SELECT ForecastToleranceDate__c, ForecastCategoryName ' 
			+ 'FROM Opportunity '
			+ 'WHERE IsClosed = false ' 
			+ 'AND ForecastCategoryName != \'Omitted\' '
			+ 'AND ForecastToleranceDate__c != null '
			+ 'AND ForecastToleranceDate__c < :todaysDate';
			
	global ForecastTolerancesCheck(String query) {
		if (String.isNotBlank(query)) {
			this.queryString = query;
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		Date todaysDate = Date.today();
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext context, List<SObject> scopeObjects) {
    	List<Opportunity> scopeOpportunities = (List<Opportunity>)scopeObjects;
		
		List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
		for (Opportunity opp : scopeOpportunities) {
			if (opp.ForecastToleranceDate__c != null && opp.ForecastToleranceDate__c < Date.today()) {
				opp.ForecastCategoryName = 'Omitted';
				opportunitiesToUpdate.add(opp);
			}
		}
		
		if (!opportunitiesToUpdate.isEmpty()) {
			update opportunitiesToUpdate;
		}
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}