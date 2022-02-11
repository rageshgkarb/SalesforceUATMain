public without sharing class CalculateHPPStatusTotalFigures {
	public CalculateHPPStatusTotalFigures() {
		execute();
	}
	
	private void execute() {
	 	//	Delete all but the last 3 days figures
		List<HPPStatusTotalFigures__c> allFigures = [
			SELECT Name 
			FROM HPPStatusTotalFigures__c
			WHERE RunDate__c < :Date.today().addDays(-2)
				OR RunDate__c = :Date.today()
		];
		delete allFigures;

		//	Get all of the figures gathered by the batch job
		Date todaysDate = Date.today();
        List<HPPStatusFigures__c> statusFigures = [
        	SELECT Name, NumberOfClosedOpportunities__c, NumberOfOpportunities__c, NumberOfWonOpportunities__c, 
        		NumberOfWonOppsWithCompletedDate__c, RunDate__c, Status__c, TotalNumberOfOpportunities__c, TotalStatusAgeToWon__c
			FROM HPPStatusFigures__c
			WHERE RunDate__c = :todaysDate
			ORDER BY Status__c ASC NULLS LAST
		];
		
		Set<String> statuses = new Set<String>();
		Map<String, Integer> statusNumberOfOpportunities = new Map<String, Integer>();
		Map<String, Integer> statusNumberOfClosedOpportunities = new Map<String, Integer>();
		Map<String, Integer> statusNumberOfWonOpportunities = new Map<String, Integer>();
		Map<String, Integer> statusNumberOfWonOppsWithCompletedDate = new Map<String, Integer>();
		Map<String, Integer> statusTotalDaysToWon = new Map<String, Integer>();
		
		for (HPPStatusFigures__c figures : statusFigures) {
			String status = figures.Status__c;
			
			if (String.isNotBlank(status) && !statuses.contains(status)) {
				statuses.add(status);
			}
			
			if (figures.NumberOfOpportunities__c != null) {
				if (statusNumberOfOpportunities.containsKey(status)) {
					Integer numberOfOpps = statusNumberOfOpportunities.get(status);
					numberOfOpps += Integer.valueOf(figures.NumberOfOpportunities__c);
					statusNumberOfOpportunities.put(status, numberOfOpps);
				}
				else {
					statusNumberOfOpportunities.put(status, Integer.valueOf(figures.NumberOfOpportunities__c));
				}
			}
			
			if (figures.NumberOfClosedOpportunities__c != null) {
				if (statusNumberOfClosedOpportunities.containsKey(status)) {
					Integer numberOfClosedOpps = statusNumberOfClosedOpportunities.get(status);
					numberOfClosedOpps += Integer.valueOf(figures.NumberOfClosedOpportunities__c);
					statusNumberOfClosedOpportunities.put(status, numberOfClosedOpps);
				}
				else {
					statusNumberOfClosedOpportunities.put(status, Integer.valueOf(figures.NumberOfClosedOpportunities__c));
				}
			}
			
			if (figures.NumberOfWonOpportunities__c != null) {
				if (statusNumberOfWonOpportunities.containsKey(status)) {
					Integer numberOfWonOpps = statusNumberOfWonOpportunities.get(status);
					numberOfWonOpps += Integer.valueOf(figures.NumberOfWonOpportunities__c);
					statusNumberOfWonOpportunities.put(status, numberOfWonOpps);
				}
				else {
					statusNumberOfWonOpportunities.put(status, Integer.valueOf(figures.NumberOfWonOpportunities__c));
				}
			}
			
			if (figures.NumberOfWonOppsWithCompletedDate__c != null) {
				System.debug('figures.NumberOfWonOppsWithCompletedDate__c => ' + figures.NumberOfWonOppsWithCompletedDate__c);
				if (statusNumberOfWonOppsWithCompletedDate.containsKey(status)) {
					Integer numberOfWonOppsWithCompletedDate = statusNumberOfWonOppsWithCompletedDate.get(status);
					numberOfWonOppsWithCompletedDate += Integer.valueOf(figures.NumberOfWonOppsWithCompletedDate__c);
					statusNumberOfWonOppsWithCompletedDate.put(status, numberOfWonOppsWithCompletedDate);
				}
				else {
					statusNumberOfWonOppsWithCompletedDate.put(status, Integer.valueOf(figures.NumberOfWonOppsWithCompletedDate__c));
				}
				System.debug('statusNumberOfWonOppsWithCompletedDate => ' + statusNumberOfWonOppsWithCompletedDate);
			}
			
			if (figures.TotalStatusAgeToWon__c != null) {
				System.debug('figures.TotalStatusAgeToWon__c => ' + figures.TotalStatusAgeToWon__c);
				if (statusTotalDaysToWon.containsKey(status)) {
					Integer daysToWon = statusTotalDaysToWon.get(status);
					daysToWon += Integer.valueOf(figures.TotalStatusAgeToWon__c);
					statusTotalDaysToWon.put(status, daysToWon);
				}
				else {
					statusTotalDaysToWon.put(status, Integer.valueOf(figures.TotalStatusAgeToWon__c));
				}
				System.debug('statusTotalDaysToWon => ' + statusTotalDaysToWon);
			}
		}
        
        List<HPPStatusTotalFigures__c> statusTotalFigures = new List<HPPStatusTotalFigures__c>();
        for (String status : statuses) {
        	//	For each status, create a Totals record
        	String customSettingName = DateTime.now().format('yyyyMMdd') + '_' + status;
        	customSettingName = customSettingName.replaceAll(' ', '_').toLowerCase();
        	customSettingName = (customSettingName.length() > 38) ? customSettingName.substring(0, 38) : customSettingName;
        	
        	//	Get the raw data numbers
        	Integer numberOfOpps = statusNumberOfOpportunities.get(status);
        	Integer numberOfClosedOpps = statusNumberOfClosedOpportunities.get(status);
        	Integer numberOfWonOpps = statusNumberOfWonOpportunities.get(status);
        	Integer numberOfWonOppsWithCompletedDate = statusNumberOfWonOppsWithCompletedDate.get(status);
        	Integer totalDaysToWon = statusTotalDaysToWon.get(status);
        	
        	//	Do the calculations for use in the Trigger
        	Decimal closedOpps = numberOfClosedOpps;
        	Decimal wonOpps = numberOfWonOpps;
        	Decimal probability = (closedOpps != null && closedOpps > 0) ?
        		wonOpps.divide(numberOfClosedOpps, 2) * 100 : null;
        	Decimal averageDaysToWon = (numberOfWonOppsWithCompletedDate != null && numberOfWonOppsWithCompletedDate > 0) ?
        		totalDaysToWon / numberOfWonOppsWithCompletedDate : null;
        		
    		System.debug('probability => ' + probability); 
        	
        	HPPStatusTotalFigures__c totalFigures = new HPPStatusTotalFigures__c(
        		Name = customSettingName, Status__c = status, RunDate__c = Date.today(), AverageStatusAgeToWon__c = averageDaysToWon,
        		NumberOfClosedOpportunities__c = numberOfClosedOpps, NumberOfOpportunities__c = numberOfOpps,
        		NumberOfWonOpportunities__c = numberOfWonOpps, NumberOfWonOppsWithCompletedDate__c = numberOfWonOppsWithCompletedDate,
        		Probability__c = probability, TotalStatusAgeToWon__c = totalDaysToWon
        	);
        	statusTotalFigures.add(totalFigures);
        }
        if (!statusTotalFigures.isEmpty()) {
        	insert statusTotalFigures;
        }
    }
}