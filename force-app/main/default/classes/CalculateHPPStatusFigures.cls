global class CalculateHPPStatusFigures implements Database.Batchable<SObject> {
	global static final Date START_DATE = Date.newInstance(2013, 6, 1);
	global static final String SOBJECT_NAME = 'Opportunity';
	global static final String STATUS_FIELD_NAME = 'Status_HPP_CAA__c';
	global static final String[] OPPORTUNITY_RECORD_TYPE_NAMES = new String[] {
		'General', 'HPP_CAA', 'HPP_Opporunities', 'HPP_Premier'
	};
	
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
        
	 	//	Delete all but yesterdays figures
		List<HPPStatusFigures__c> allFigures = [
			SELECT Name 
			FROM HPPStatusFigures__c
			WHERE RunDate__c < :Date.today().addDays(-1)
				OR RunDate__c = :Date.today()
		];
		delete allFigures;
        
        String queryString = 'SELECT OpportunityId, NewValue, Field, CreatedDate, Opportunity.IsWon, Opportunity.IsClosed ' 
			+ 'FROM OpportunityFieldHistory '
			+ 'WHERE Field = \'' + STATUS_FIELD_NAME + '\' '
			+ 'AND Opportunity.RecordTypeId IN :recordTypeIDs '
			+ 'AND Opportunity.CreatedDate >= :START_DATE '
			+ 'ORDER BY NewValue ASC NULLS LAST, OpportunityId ASC';
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext context, List<SObject> scopeObjects) {
    	List<OpportunityFieldHistory> scopeFieldHistorys = (List<OpportunityFieldHistory>)scopeObjects;
    	Set<Id> allOpportunityIDs = new Set<Id>();
    	Map<String, Set<Id>> statusOpportunityIDs = new Map<String, Set<Id>>();
    	
    	Map<String, Integer> statusNumberOfOpportunities = new Map<String, Integer>();
    	Map<String, Integer> statusNumberOfClosedOpportunities = new Map<String, Integer>();
    	Map<String, Integer> statusNumberOfWonOpportunities = new Map<String, Integer>();
    	Map<String, Integer> statusNumberOfWonOpportunitiesWithCompletedDate = new Map<String, Integer>();
    	Map<String, Integer> statusDaysToWon = new Map<String, Integer>();
    	
    	for (OpportunityFieldHistory fieldHistory : scopeFieldHistorys) {
    		String status = (String)fieldHistory.NewValue;
    		
    		if (!allOpportunityIDs.contains(fieldHistory.OpportunityId)) {
    			allOpportunityIDs.add(fieldHistory.OpportunityId);
    		}
    	}
    	
    	//	Get the Opportunities and HPP Extended Opportunities
    	Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
    		SELECT Id,
    			(SELECT Actual_Completion_Date__c FROM HPP_Extended_Opportunities__r)
			FROM Opportunity
			WHERE Id IN :allOpportunityIDs
    	]);
    	
    	for (OpportunityFieldHistory fieldHistory : scopeFieldHistorys) {
    		String status = (String)fieldHistory.NewValue;
    		if (Test.isRunningTest()) {
    			status = 'Testing';
    		}
    		
    		/*
    		//	WG Debug
    		if (status == 'Application Underway') {
    			System.debug('*** ' + status + ' ***');
    		}
    		*/
    			
    		if (String.isNotBlank(status)) {
    			/*
    			//	WG Debug
	    		if (status == 'Application Underway') {
	    			System.debug('*** statusOpportunityIDs.containsKey(status) => ' + statusOpportunityIDs.containsKey(status) + ' ***');
	    		}
	    		*/
    			
	    		if (!statusOpportunityIDs.containsKey(status)) {	    			
	    			Set<Id> opportunityIDs = new Set<Id>();
	    			opportunityIDs.add(fieldHistory.OpportunityId);
	    			statusOpportunityIDs.put(status, opportunityIDs);
	    			
	    			//	Start the count
	    			statusNumberOfOpportunities.put(status, 1);
	    			
	    			Integer isClosed = (fieldHistory.Opportunity.IsClosed) ? 1 : 0;
	    			statusNumberOfClosedOpportunities.put(status, isClosed);
	    			
	    			Integer isWon = (fieldHistory.Opportunity.IsWon) ? 1 : 0;
	    			statusNumberOfWonOpportunities.put(status, isWon);
	    			
	    			/*
	    			//	WG Debug
		    		if (status == 'Application Underway') {
		    			System.debug('*** isWon => ' + isWon + ' ***');
		    		}
		    		*/
	    			
	    			if (isWon == 1) {
	    				/*
	    				//	WG Debug
			    		if (status == 'Application Underway') {
			    			System.debug('*** opportunitiesMap.containsKey(fieldHistory.OpportunityId) => ' + opportunitiesMap.containsKey(fieldHistory.OpportunityId) + ' ***');
			    		}
			    		*/
	    				
	    				//	Get the days from status date to closed
	    				if (opportunitiesMap.containsKey(fieldHistory.OpportunityId)) {
	    					Opportunity opp = opportunitiesMap.get(fieldHistory.OpportunityId);
	    					
	    					/*
	    					//	WG Debug
				    		if (status == 'Application Underway') {
				    			System.debug('*** opp.HPP_Extended_Opportunities__r.isEmpty() => ' + opp.HPP_Extended_Opportunities__r.isEmpty() + ' ***');
				    		}
				    		*/
	    					
	    					if (!opp.HPP_Extended_Opportunities__r.isEmpty()) {
	    						Date statusDate = fieldHistory.CreatedDate.date();
	    						Date closeDate = getCloseDate(opp);
	    						
	    						/*
								//	WG Debug
			    				if (status == 'Application Underway') {
		    						System.debug('*** statusDate => ' + statusDate + ' ***');
		    						System.debug('*** closeDate => ' + closeDate + ' ***');
			    				}
			    				*/
	    						
	    						if (statusDate != null && closeDate != null) {
	    							Integer oppsWithCompletedDate = statusNumberOfWonOpportunitiesWithCompletedDate.get(status);
	    							Integer totalDaysToClose = statusDaysToWon.get(status);
	    							
	    							Integer daysToClose = statusDate.daysBetween(closeDate);
	    							System.debug('daysToClose => ' + daysToClose);
	    							
	    							oppsWithCompletedDate = (oppsWithCompletedDate != null) ? 
	    								oppsWithCompletedDate + 1 : 1;
    								totalDaysToClose = (totalDaysToClose != null) ?
    									totalDaysToClose + daysToClose : daysToClose;
	    							
	    							statusNumberOfWonOpportunitiesWithCompletedDate.put(status, oppsWithCompletedDate);
	    							statusDaysToWon.put(status, totalDaysToClose);
	    						}
	    					}
	    					else {
	    						//	Opportunity doesn't have an Extended Opportunity, so unabled to find completion date
	    						System.debug('Opportunity ID \'' + opp.Id + '\' has no Extended Opportunity records.');
	    					}
	    				}
	    				else {
	    					//	Opportunity not in map, so unable to use in calculation
	    					System.debug('Opportunity ID \'' + fieldHistory.OpportunityId + '\' missing from map. For Field History ID \'' + fieldHistory.Id + '\'');	
	    				}
	    			}
	    		}
	    		else {
	    			Set<Id> opportunityIDs = statusOpportunityIDs.get(status);
	    			if (!opportunityIDs.contains(fieldHistory.OpportunityId)) {
	    				opportunityIDs.add(fieldHistory.OpportunityId);
	    				statusOpportunityIDs.put(status, opportunityIDs);
	    				
	    				//	Increment the counts
	    				Integer numberOfOpps = statusNumberOfOpportunities.get(status) + 1;
		    			statusNumberOfOpportunities.put(status, numberOfOpps);
		    			
		    			Integer isClosed = (fieldHistory.Opportunity.IsClosed) ? 1 : 0;
		    			Integer numberOfClosedOpps = statusNumberOfClosedOpportunities.get(status) + isClosed;
	    				statusNumberOfClosedOpportunities.put(status, numberOfClosedOpps);
		    			
		    			Integer isWon = (fieldHistory.Opportunity.IsWon) ? 1 : 0;
		    			Integer numberOfWonOpps = statusNumberOfWonOpportunities.get(status) + isWon;
		    			statusNumberOfWonOpportunities.put(status, numberOfWonOpps);
		    			
		    			/*
		    			//	WG Debug
			    		if (status == 'Application Underway') {
			    			System.debug('*** isWon => ' + isWon + ' ***');
			    		}
			    		*/
		    			
		    			if (isWon == 1) {
		    				/*
		    				//	WG Debug
				    		if (status == 'Application Underway') {
				    			System.debug('*** opportunitiesMap.containsKey(fieldHistory.OpportunityId) => ' + opportunitiesMap.containsKey(fieldHistory.OpportunityId) + ' ***');
				    		}
				    		*/
		    				
		    				//	Get the days from status date to closed
		    				if (opportunitiesMap.containsKey(fieldHistory.OpportunityId)) {
		    					Opportunity opp = opportunitiesMap.get(fieldHistory.OpportunityId);
		    					
		    					/*
		    					//	WG Debug
					    		if (status == 'Application Underway') {
					    			System.debug('*** opp.HPP_Extended_Opportunities__r.isEmpty() => ' + opp.HPP_Extended_Opportunities__r.isEmpty() + ' ***');
					    		}
					    		*/
		    					
		    					if (!opp.HPP_Extended_Opportunities__r.isEmpty()) {
		    						Date statusDate = fieldHistory.CreatedDate.date();
		    						Date closeDate = getCloseDate(opp);
		    						
		    						/*
		    						//	WG Debug
				    				if (status == 'Application Underway') {
			    						System.debug('*** statusDate => ' + statusDate + ' ***');
			    						System.debug('*** closeDate => ' + closeDate + ' ***');
				    				}
				    				*/
		    						
		    						if (statusDate != null && closeDate != null) {
		    							Integer oppsWithCompletedDate = statusNumberOfWonOpportunitiesWithCompletedDate.get(status);
		    							Integer totalDaysToClose = statusDaysToWon.get(status);
		    							
		    							Integer daysToClose = statusDate.daysBetween(closeDate);
		    							System.debug('daysToClose => ' + daysToClose);
		    							
		    							oppsWithCompletedDate = (oppsWithCompletedDate != null) ? 
		    								oppsWithCompletedDate + 1 : 1;
	    								totalDaysToClose = (totalDaysToClose != null) ?
	    									totalDaysToClose + daysToClose : daysToClose;
		    							
		    							statusNumberOfWonOpportunitiesWithCompletedDate.put(status, oppsWithCompletedDate);
		    							statusDaysToWon.put(status, totalDaysToClose);
		    						}
		    					}
		    					else {
		    						//	Opportunity doesn't have an Extended Opportunity, so unabled to find completion date
		    						System.debug('Opportunity ID \'' + opp.Id + '\' has no Extended Opportunity records.');
		    					}
		    				}
		    				else {
		    					//	Opportunity not in map, so unable to use in calculation
		    					System.debug('Opportunity ID \'' + fieldHistory.OpportunityId + '\' missing from map. For Field History ID \'' + fieldHistory.Id + '\'');	
		    				}
		    			}
	    			}
	    		}
    		}
    	}
    	
    	List<HPPStatusFigures__c> statusFigures = new List<HPPStatusFigures__c>();
    	
    	//	Generate a random batch key
    	String batchKey = EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(1, 10).toLowerCase();
    	
    	for (String status : statusNumberOfOpportunities.keySet()) {
    		Integer numberOfOpps = statusNumberOfOpportunities.get(status);
    		Integer numberOfClosedOpps = statusNumberOfClosedOpportunities.get(status);
    		Integer numberOfWonOpps = statusNumberOfWonOpportunities.get(status);
    		Integer numberOfWonOppsWithCompletedDate = statusNumberOfWonOpportunitiesWithCompletedDate.get(status);
    		Integer daysToWon = statusDaysToWon.get(status);
    		
    		//	String customSettingName = DateTime.now().format('yyyyMMddHHmmssSSS') + '_' + status;
    		String customSettingName = batchKey + '_' + status;
        	customSettingName = customSettingName.replaceAll(' ', '_').toLowerCase();
        	customSettingName = (customSettingName.length() > 38) ? customSettingName.substring(0, 38) : customSettingName;
    		
    		HPPStatusFigures__c figures = new HPPStatusFigures__c(
    			Name = customSettingName, NumberOfOpportunities__c = numberOfOpps, NumberOfClosedOpportunities__c = numberOfClosedOpps,
    			NumberOfWonOpportunities__c = numberOfWonOpps, NumberOfWonOppsWithCompletedDate__c = numberOfWonOppsWithCompletedDate,
    			TotalStatusAgeToWon__c = daysToWon, Status__c = status, RunDate__c = Date.today()
    		);
    		statusFigures.add(figures);
    	}
    	
    	System.debug('statusNumberOfOpportunities => ' + statusNumberOfOpportunities);
    	System.debug('statusNumberOfClosedOpportunities => ' + statusNumberOfClosedOpportunities);
    	System.debug('statusNumberOfWonOpportunities => ' + statusNumberOfWonOpportunities);
    	System.debug('statusNumberOfWonOpportunitiesWithCompletedDate => ' + statusNumberOfWonOpportunitiesWithCompletedDate);
    	System.debug('statusDaysToWon => ' + statusDaysToWon);
    	
    	System.debug('statusFigures');
    	System.debug(statusFigures);
    	System.debug('statusFigures.isEmpty() => ' + statusFigures.isEmpty());
    	
    	if (!statusFigures.isEmpty()) {
    		insert statusFigures;
    	}
    }
    
    global void finish(Database.BatchableContext context) {
        //	Get the Figures for all the Opportunities without Field Histories
        Database.executeBatch(new CalculateHPPStatusFiguresWithoutHistory());
    }
    
    private Date getCloseDate(Opportunity opp) {
    	Date closeDate = null;
    	
    	if (opp.HPP_Extended_Opportunities__r.size() == 1) {
			HPP_Extended_Opportunity__c extendedOpp = opp.HPP_Extended_Opportunities__r[0];
			closeDate = extendedOpp.Actual_Completion_Date__c;
		}
		
		return closeDate;
    }
}