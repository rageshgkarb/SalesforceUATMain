global class CalculateHPPStatusFiguresWithoutHistory implements Database.Batchable<SObject> {
	global final Date START_DATE = CalculateHPPStatusFigures.START_DATE;
	global final String STATUS_FIELD_NAME = CalculateHPPStatusFigures.STATUS_FIELD_NAME;
	global final String[] OPPORTUNITY_RECORD_TYPE_NAMES = CalculateHPPStatusFigures.OPPORTUNITY_RECORD_TYPE_NAMES;
	
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
        
        String queryString = 'SELECT Id, IsClosed, IsWon, StageName, Status_HPP_CAA__c, CreatedDate, '
        	+ '(SELECT Id FROM Histories WHERE Field = \'' + STATUS_FIELD_NAME + '\' LIMIT 1) ' 
			+ 'FROM Opportunity '
			+ 'WHERE RecordTypeId IN :recordTypeIDs '
			+ 'AND CreatedDate >= :START_DATE '
			+ 'AND Status_HPP_CAA__c != null '
			+ 'ORDER BY CreatedDate ASC';
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext context, List<SObject> scopeObjects) {
    	List<Opportunity> scopeOpportunities = (List<Opportunity>)scopeObjects;
    	
    	Map<String, Integer> statusNumberOfOpportunities = new Map<String, Integer>();
    	Map<String, Integer> statusNumberOfClosedOpportunities = new Map<String, Integer>();
    	Map<String, Integer> statusNumberOfWonOpportunities = new Map<String, Integer>();
    	
    	//	Generate a random batch key
    	String batchKey = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1, 10).toLowerCase();
    	batchKey += '_nohist';
    	
    	for (Opportunity opp : scopeOpportunities) {
    		//	Check for Field History records
    		if (opp.Histories.isEmpty()) {
    			//	No Field History, so add to the totals
    			String status = opp.Status_HPP_CAA__c;
    			
    			if (statusNumberOfOpportunities.containsKey(status)) {
    				Integer numberOfOpps = statusNumberOfOpportunities.get(status) + 1;
    				statusNumberOfOpportunities.put(status, numberOfOpps);
    			}
    			else {
    				statusNumberOfOpportunities.put(status, 1);
    			}
    			
    			if (opp.IsClosed) {
    				if (statusNumberOfClosedOpportunities.containsKey(status)) {
    					Integer numberOfClosedOpps = statusNumberOfClosedOpportunities.get(status) + 1;
    					statusNumberOfClosedOpportunities.put(status, numberOfClosedOpps);
    				}
    				else {
    					statusNumberOfClosedOpportunities.put(status, 1);
    				}
    			}
    			
    			if (opp.IsWon) {
	    			if (statusNumberOfWonOpportunities.containsKey(status)) {
	    				Integer numberOfWonOpps = statusNumberOfWonOpportunities.get(status) + 1;
	    				statusNumberOfWonOpportunities.put(status, numberOfWonOpps);
	    			}
	    			else {
	    				statusNumberOfWonOpportunities.put(status, 1);
	    			}
    			}
    		}
    	}
    	
    	Set<String> uniqueStatuses = new Set<String>();
    	uniqueStatuses.addAll(statusNumberOfOpportunities.keySet());
    	uniqueStatuses.addAll(statusNumberOfClosedOpportunities.keySet());
    	uniqueStatuses.addAll(statusNumberOfWonOpportunities.keySet());
    	
    	List<HPPStatusFigures__c> statusFigures = new List<HPPStatusFigures__c>();
    	for (String status : uniqueStatuses) {
    		Boolean updateFigures = false;
    		
    		String customSettingName = batchKey + '_' + status;
	    	customSettingName = customSettingName.replaceAll(' ', '_').toLowerCase();
	    	customSettingName = (customSettingName.length() > 38) ? customSettingName.substring(0, 38) : customSettingName;
    		
    		HPPStatusFigures__c figures = new HPPStatusFigures__c(
    			Name =  customSettingName, Status__c = status, RunDate__c = Date.today()
    		);
    		
    		if (statusNumberOfOpportunities.containsKey(status)) {
    			Integer numberOfOpps = statusNumberOfOpportunities.get(status);
    			figures.NumberOfOpportunities__c = (figures.NumberOfOpportunities__c != null) ?
    				figures.NumberOfOpportunities__c + numberOfOpps : numberOfOpps;
    			updateFigures = true;
    		}
    		if (statusNumberOfClosedOpportunities.containsKey(status)) {
    			Integer numberOfClosedOpps = statusNumberOfClosedOpportunities.get(status);
    			figures.NumberOfClosedOpportunities__c = (figures.NumberOfClosedOpportunities__c != null) ?
    				figures.NumberOfClosedOpportunities__c + numberOfClosedOpps : numberOfClosedOpps;
				updateFigures = true;
    		}
    		if (statusNumberOfWonOpportunities.containsKey(status)) {
    			Integer numberOfWonOpps = statusNumberOfWonOpportunities.get(status);
    			figures.NumberOfWonOpportunities__c = (figures.NumberOfWonOpportunities__c != null) ?
    				figures.NumberOfWonOpportunities__c + numberOfWonOpps : numberOfWonOpps;
    			updateFigures = true;
    		}
    		
    		if (updateFigures) {
    			statusFigures.add(figures);
    		}
    	}
    	
    	if (!statusFigures.isEmpty()) {
    		insert statusFigures;
    	}
    }
    
    global void finish(Database.BatchableContext context) {
        //  Start the process of making final calculations
        new CalculateHPPStatusTotalFigures();
    }
}