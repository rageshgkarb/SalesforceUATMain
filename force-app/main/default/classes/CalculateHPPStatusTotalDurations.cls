public without sharing class CalculateHPPStatusTotalDurations {
	public CalculateHPPStatusTotalDurations() {
		execute();
		executeStatusTolerances();
	}
	
	private void execute() {
	 	//	Delete all but the last 3 days figures
		List<HPPStatusTotalDurations__c> oldDurations = [
			SELECT Name 
			FROM HPPStatusTotalDurations__c
			WHERE RunDate__c < :Date.today().addDays(-2)
				OR RunDate__c = :Date.today()
		];
		delete oldDurations;

		//	Get all of the figures gathered by the batch job
		Date todaysDate = Date.today();
        List<HPPStatusDuration__c> statusDurations = [
        	SELECT Name, FromStatus__c, ToStatus__c, OpportunityCount__c, TotalStatusDuration__c
			FROM HPPStatusDuration__c
			WHERE RunDate__c = :todaysDate
			ORDER BY FromStatus__c ASC NULLS LAST, ToStatus__c ASC NULLS LAST
		];
		
		System.debug('statusDurations:');
		System.debug(statusDurations);
		
		Map<String, List<HPPStatusDuration__c>> statusMap = new Map<String, List<HPPStatusDuration__c>>();
		for (HPPStatusDuration__c hppStatusDuration : statusDurations) {
			String fromStatus = hppStatusDuration.FromStatus__c;
			String toStatus = hppStatusDuration.ToStatus__c;
			String mapKey = fromStatus + '-' + toStatus;
			
			if (statusMap.containsKey(mapKey)) {
				List<HPPStatusDuration__c> statusRecords = statusMap.get(mapKey);
				statusRecords.add(hppStatusDuration); 
				statusMap.put(mapKey, statusRecords);
			}
			else {
				List<HPPStatusDuration__c> statusRecords = new HPPStatusDuration__c[] { hppStatusDuration }; 
				statusMap.put(mapKey, statusRecords);
			}
		}
		
		System.debug('statusMap:');
		System.debug(statusMap);
        
        List<HPPStatusTotalDurations__c> statusTotalDurations = new List<HPPStatusTotalDurations__c>();
        for (String mapKey : statusMap.keySet()) {
        	//	Get the raw data values
        	String fromStatus = '';
        	String toStatus = '';
        	Integer opportunityCount = 0;
        	Integer totalStatusDuration = 0;
        	
        	for (HPPStatusDuration__c statusDuration : statusMap.get(mapKey)) {
        		if (String.isBlank(fromStatus)) {
        			fromStatus = statusDuration.FromStatus__c;
        		}
        		if (String.isBlank(toStatus)) {
        			toStatus = statusDuration.ToStatus__c;
        		}
        		if (statusDuration.OpportunityCount__c != null) {
        			opportunityCount += Integer.valueOf(statusDuration.OpportunityCount__c);
        		}
        		if (statusDuration.TotalStatusDuration__c != null) {
        			totalStatusDuration += Integer.valueOf(statusDuration.TotalStatusDuration__c);
        		}
        	}
        	
        	//	Create a unique name
        	String fromStatusName = fromStatus.replaceAll(' ', '').toLowerCase();
        	fromStatusName = (fromStatusName.length() > 14) ? fromStatusName.substring(0, 14) : fromStatusName;
        	String toStatusName = toStatus.replaceAll(' ', '').toLowerCase();
        	toStatusName = (toStatusName.length() > 14) ? toStatusName.substring(0, 14) : toStatusName;
        	String customSettingName = DateTime.now().format('yyyyMMdd') + '_' + fromStatusName + '-' + toStatusName;
        	
        	//	Do the calculations for use in the Trigger
        	Integer averageStatusDuration = ((totalStatusDuration != null && opportunityCount != null) && opportunityCount > 0) ? 
        		totalStatusDuration / opportunityCount : 0;
        		
    		System.debug('averageStatusDuration => ' + averageStatusDuration); 
        	
        	HPPStatusTotalDurations__c hppStatusTotalDurations = new HPPStatusTotalDurations__c(
        		Name = customSettingName, FromStatus__c = fromStatus, ToStatus__c = toStatus, OpportunityCount__c = opportunityCount, 
        		TotalStatusDuration__c = totalStatusDuration, AverageStatusDuration__c = averageStatusDuration, RunDate__c = Date.today()
        	);
        	statusTotalDurations.add(hppStatusTotalDurations);
        }
        if (!statusTotalDurations.isEmpty()) {
        	insert statusTotalDurations;
        }
    }
    
    private void executeStatusTolerances() {
    	List<HPPStatusTotalDurations__c> hppStatusTotalDurations = [
    		SELECT FromStatus__c, ToStatus__c, AverageStatusDuration__c
    		FROM HPPStatusTotalDurations__c
    		WHERE RunDate__c = :Date.today()
    		ORDER BY FromStatus__c ASC NULLS LAST, ToStatus__c ASC NULLS LAST
    	];
    	
    	Map<String, List<HPPStatusTotalDurations__c>> statusDurationsMap = new Map<String, List<HPPStatusTotalDurations__c>>();
    	for (HPPStatusTotalDurations__c hppStatusTotalDuration : hppStatusTotalDurations) {
    		if (String.isNotBlank(hppStatusTotalDuration.FromStatus__c)) {
    			if (statusDurationsMap.containsKey(hppStatusTotalDuration.FromStatus__c)) {
    				List<HPPStatusTotalDurations__c> statusDurations = statusDurationsMap.get(hppStatusTotalDuration.FromStatus__c);
    				statusDurations.add(hppStatusTotalDuration);
    				statusDurationsMap.put(hppStatusTotalDuration.FromStatus__c, statusDurations);
    			}
    			else {
    				List<HPPStatusTotalDurations__c> statusDurations = new HPPStatusTotalDurations__c[] { hppStatusTotalDuration };
    				statusDurationsMap.put(hppStatusTotalDuration.FromStatus__c, statusDurations);
    			}
    		}
    	}
    	
    	List <HPPStatusTolerances__c> hppStatusTolerances = new List<HPPStatusTolerances__c>();
    	for (String statusKey : statusDurationsMap.keySet()) {
    		String shortStatusKey = (statusKey.length() > 38) ? statusKey.substring(0, 38) : statusKey;
    		
    		HPPStatusTolerances__c hppStatusTolerance = HPPStatusTolerances__c.getValues(shortStatusKey);
    		List<HPPStatusTotalDurations__c> statusTotalDurations = statusDurationsMap.get(statusKey);
    		
    		Decimal tolerance = (hppStatusTolerance != null) ? hppStatusTolerance.Tolerance__c : 100;
    		Decimal smallestDuration = null;
    		Decimal largestDuration = null;
    		Decimal toleranceDuration = null;
    		Integer defaultMaximumStatusDuration = 100;
    		
    		Integer stageCount = 0;
    		Integer totalDuration = 0;
    		Decimal averageDuration = null;
    		
    		for (HPPStatusTotalDurations__c statusTotalDuration : statusTotalDurations) {
    			if (smallestDuration == null || statusTotalDuration.AverageStatusDuration__c < smallestDuration) {
    				smallestDuration = statusTotalDuration.AverageStatusDuration__c;
    			}
    			if (largestDuration == null || statusTotalDuration.AverageStatusDuration__c > largestDuration) {
    				largestDuration = statusTotalDuration.AverageStatusDuration__c;
    			}
    			
    			System.debug('smallestDuration = ' + statusTotalDuration.AverageStatusDuration__c + ' < ' + smallestDuration);
    			System.debug('largestDuration = ' + statusTotalDuration.AverageStatusDuration__c + ' > ' + largestDuration);
    			
    			totalDuration += Integer.valueOf(statusTotalDuration.AverageStatusDuration__c);
    			++stageCount;
    		}
    		
    		if (stageCount > 0) {
    			averageDuration = totalDuration / stageCount;
    		}
    		
    		/*if (largestDuration != null) {
    			toleranceDuration = largestDuration / 100 * tolerance;
    		}*/
    		
    		if (averageDuration != null) {
    			toleranceDuration = averageDuration / 100 * tolerance;
    		}
    		
    		//	Set the minimum tolerance duration to 1
    		if (toleranceDuration == 0 && tolerance != 0) {
    			toleranceDuration = 1;
    		}
    		
    		if (hppStatusTolerance != null) {
    			if (String.isBlank(hppStatusTolerance.HPPStatus__c)) {
    				hppStatusTolerance.HPPStatus__c = statusKey;
    			}
    			if (hppStatusTolerance.MaximumStatusDuration__c == null) {
    				hppStatusTolerance.MaximumStatusDuration__c = defaultMaximumStatusDuration;
    			}
    			hppStatusTolerance.SmallestDuration__c = smallestDuration;
    			hppStatusTolerance.LargestDuration__c = largestDuration;
    			hppStatusTolerance.AverageDuration__c = averageDuration;
    			hppStatusTolerance.ToleranceDuration__c = toleranceDuration;
    		}
    		else {
    			hppStatusTolerance = new HPPStatusTolerances__c(
    				Name = shortStatusKey, HPPStatus__c = statusKey, Tolerance__c = tolerance, SmallestDuration__c = smallestDuration, 
    				LargestDuration__c = largestDuration, ToleranceDuration__c = toleranceDuration, AverageDuration__c = averageDuration,
    				MaximumStatusDuration__c = defaultMaximumStatusDuration
    			);
    		}
    		
    		hppStatusTolerances.add(hppStatusTolerance);
    	}
    	
    	if (!hppStatusTolerances.isEmpty()) {
    		upsert hppStatusTolerances;
    	}
    }
}