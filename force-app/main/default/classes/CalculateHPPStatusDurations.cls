global class CalculateHPPStatusDurations implements Database.Batchable<SObject> {
	global static final Date START_DATE = Date.newInstance(2013, 6, 1);
	global static final String[] OPPORTUNITY_RECORD_TYPE_NAMES = new String[] {
		'General', 'HPP_CAA', 'HPP_Opporunities', 'HPP_Premier'
	};
	global String queryString = 'SELECT OpportunityId, OldValue, NewValue, Field, CreatedDate, Opportunity.IsWon, Opportunity.IsClosed ' 
			+ 'FROM OpportunityFieldHistory '
			+ 'WHERE Field = \'Status_HPP_CAA__c\' '
			+ 'AND Opportunity.RecordTypeId IN :recordTypeIDs '
			+ 'AND Opportunity.CreatedDate >= :START_DATE '
			+ 'ORDER BY OpportunityId ASC, CreatedDate ASC';
			
	global CalculateHPPStatusDurations(String query) {
		if (String.isNotBlank(query)) {
			this.queryString = query;
		}
		
		if (Test.isRunningTest()) {
			//	Ensure there is only 1 batch execution, otherwise tests will fail
			if (String.isNotBlank(queryString) && !queryString.contains('LIMIT')) {
				queryString += ' LIMIT 200';
			}
		}
		
		//	Delete old values (need to delete all as there will be lots!)
		List<HPPStatusDuration__c> durationsToDelete = [
			SELECT Id
			FROM HPPStatusDuration__c
			LIMIT :Limits.getLimitQueryRows()
		];
		if (!durationsToDelete.isEmpty()) {
			delete durationsToDelete;
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		List<Id> recordTypeIDs = new List<Id>();
		List<RecordType> recordTypes = [
			SELECT Id
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND DeveloperName IN :OPPORTUNITY_RECORD_TYPE_NAMES
		];
		for (RecordType recordType : recordTypes) {
			recordTypeIDs.add(recordType.Id);
		}
		
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext context, List<SObject> scopeObjects) {
    	List<OpportunityFieldHistory> scopeHistories = (List<OpportunityFieldHistory>)scopeObjects;
    	
    	Map<Id, Map<String, OpportunityFieldHistory>> opportunityStatusHistoryMap = new Map<Id, Map<String, OpportunityFieldHistory>>();
    	for (OpportunityFieldHistory history : scopeHistories) {
    		String newValue = (String)history.NewValue;
    		
    		if (opportunityStatusHistoryMap.containsKey(history.OpportunityId)) {
    			Map<String, OpportunityFieldHistory> statusHistoryMap = opportunityStatusHistoryMap.get(history.OpportunityId);
    			statusHistoryMap.put(newValue, history);
    			opportunityStatusHistoryMap.put(history.OpportunityId, statusHistoryMap);
    		}
    		else {
    			Map<String, OpportunityFieldHistory> statusHistoryMap = new Map<String, OpportunityFieldHistory>();
    			statusHistoryMap.put(newValue, history);
    			opportunityStatusHistoryMap.put(history.OpportunityId, statusHistoryMap);
    		}
    	}
    	
    	//	Generate a random batch key
    	String batchKey = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1, 10).toLowerCase();
    	
    	Map<String, HPPStatusDuration__c> statusDurationsMap = new Map<String, HPPStatusDuration__c>();
    	for (OpportunityFieldHistory history : scopeHistories) {
    		String oldValue = (String)history.OldValue;
    		String newValue = (String)history.NewValue;
    		
    		if (String.isNotBlank(oldValue) && String.isNotBlank(newValue)) {
    			String keyOldValue = oldValue.replaceAll(' ', '').toLowerCase();
	    		String keyNewValue = newValue.replaceAll(' ', '').toLowerCase();
	    		
	    		String customSettingKey = batchKey + '_';
	    		String fullKey = customSettingKey + keyOldValue + '-' + keyNewValue;

	    		if (fullKey.length() > 38) {
	    			List<String> oldStatusWords = oldValue.split(' ');
	    			List<String> newStatusWords = newValue.split(' ');
	    			
	    			if (oldStatusWords.size() > 1) {
	    				keyOldValue = '';
	    				for (String word : oldStatusWords) {
	    					if (word.length() > 3) {
	    						keyOldValue += word.substring(0, 3);
	    					}
	    					else {
	    						keyOldValue += word;
	    					}
	    				}
	    			}
	    			if (newStatusWords.size() > 1) {
	    				keyNewValue = '';
	    				for (String word : newStatusWords) {
	    					if (word.length() > 3) {
	    						keyNewValue += word.substring(0, 3);
	    					}
	    					else {
	    						keyNewValue += word;
	    					}
	    				}
	    			}
	    			
	    			customSettingKey = customSettingKey + keyOldValue + '-' + keyNewValue;
	    			System.debug('customSettingKey => ' + customSettingKey);
	    			
	    			if (customSettingKey.length() > 38) {
	    				customSettingKey = customSettingKey.substring(0, 38);
	    			}
	    		}
	    		else {
	    			customSettingKey = fullKey;
	    		}
	    		
	    		String mapKey = oldValue + '-' + newValue;
	    		mapKey = mapKey.replaceAll(' ', '').toLowerCase();
	        	mapKey = (mapKey.length() > 38) ? mapKey.substring(0, 38) : mapKey;
    			
	    		Integer statusDuration = 0;
	    		if (opportunityStatusHistoryMap.containsKey(history.OpportunityId)) {
	    			if (opportunityStatusHistoryMap.get(history.OpportunityId).containsKey(oldValue)) {
	    				Date oldStatusDate = opportunityStatusHistoryMap.get(history.OpportunityId).get(oldValue).CreatedDate.date();
	    				statusDuration = oldStatusDate.daysBetween(history.CreatedDate.date());
	    			}
	    		}
	    		//	Deal with minus durations (usually due to stages being skipped and later added)
	    		if (statusDuration < 0) {
	    			statusDuration = 0;
	    		}
	    		
	    		//	Get the maximum permitted duration (default is 100 days)
	    		Integer maxStatusDuration = 100;
	    		String shortHppStatus = (oldValue.length() > 38) ? oldValue.substring(0, 38) : oldValue;
	    		HPPStatusTolerances__c statusTolerance = HPPStatusTolerances__c.getValues(shortHppStatus); 
	    		if (statusTolerance != null && statusTolerance.MaximumStatusDuration__c != null) {
	    			maxStatusDuration = Integer.valueOf(statusTolerance.MaximumStatusDuration__c);
	    		}
	    		
	    		//	Only use duration value if it is lower than the maximum permitted
	    		if (statusDuration <= maxStatusDuration) {
		    		if (statusDurationsMap.containsKey(mapKey)) {
			    		HPPStatusDuration__c hppStatusDurations = statusDurationsMap.get(mapKey);
			    		hppStatusDurations.OpportunityCount__c = hppStatusDurations.OpportunityCount__c + 1;
			    		hppStatusDurations.TotalStatusDuration__c = hppStatusDurations.TotalStatusDuration__c + statusDuration;
			    		statusDurationsMap.put(mapKey, hppStatusDurations);
		    		}
		    		else {
		    			HPPStatusDuration__c hppStatusDurations = new HPPStatusDuration__c(
			    			Name = customSettingKey, FromStatus__c = oldValue, ToStatus__c = newValue, OpportunityCount__c = 1, 
			    			TotalStatusDuration__c = statusDuration, RunDate__c = Date.today()
			    		);
			    		statusDurationsMap.put(mapKey, hppStatusDurations);
		    		}
	    		}
    		}
    	}
    	
    	List<HPPStatusDuration__c> hppStatusDurations = new List<HPPStatusDuration__c>();
    	hppStatusDurations.addAll(statusDurationsMap.values());
    	if (!hppStatusDurations.isEmpty()) {
    		insert hppStatusDurations;
    	}
    }
    
    global void finish(Database.BatchableContext context) {
        new CalculateHPPStatusTotalDurations();
    }
}