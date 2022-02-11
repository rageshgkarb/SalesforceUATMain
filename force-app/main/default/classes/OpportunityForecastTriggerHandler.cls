public without sharing class OpportunityForecastTriggerHandler {
	//	public static Boolean hasRun = false;
	private List<Opportunity> opportunities;
	private Set<String> hppStatuses;
	private Map<Id, Opportunity> opportunityMap;
	private Map<Id, RecordType> opportunityRecordTypes;

	public OpportunityForecastTriggerHandler(List<Opportunity> opportunities, Set<String> hppStatuses) {
		this.opportunities = opportunities;
		this.hppStatuses = hppStatuses;
		if (Trigger.isUpdate) {
			this.opportunityMap = new Map<Id, Opportunity>(this.opportunities);
		}
		else {
			this.opportunityMap = new Map<Id, Opportunity>();
		}
		
		updateOpportunities();
		//	hasRun = true;	//	Will only run once during 1 Apex execution - mainly to prevent SOQL limit during tests
	}
	
	private void updateOpportunities() {
		Set<Id> opportunityIDs = new Set<Id>();
		Set<Id> recordTypeIDs = new Set<Id>();
		for (Opportunity opp : opportunities) {
			if (opp.Id != null) {
				opportunityIDs.add(opp.Id);
			}
			if (String.isNotBlank(opp.RecordTypeId)) {
				recordTypeIDs.add(opp.RecordTypeId);
			}
		}
		
		//	Get the Opportunity Record Types
		opportunityRecordTypes = new Map<Id, RecordType>([
			SELECT DeveloperName
			FROM RecordType
			WHERE SObjectType = 'Opportunity'
				AND Id IN :recordTypeIDs
		]);
		
		//	Get the Opportunity Field History records for Close Dates
		Map<Id, OpportunityFieldHistory> fieldHistoryMap = new Map<Id, OpportunityFieldHistory>();
		if (Trigger.isUpdate) {
			List<OpportunityFieldHistory> fieldHistories = [
				SELECT CreatedDate, OpportunityId, NewValue
				FROM OpportunityFieldHistory
				WHERE OpportunityId IN :opportunityIDs
					AND Field = 'Status_HPP_CAA__c'
				ORDER BY CreatedDate DESC
				LIMIT :Limits.getLimitQueryRows()
			];
			for (OpportunityFieldHistory history : fieldHistories) {
				if (!fieldHistoryMap.containsKey(history.OpportunityId)) {
					if (opportunityMap.get(history.OpportunityId).Status_HPP_CAA__c == history.NewValue) {
						fieldHistoryMap.put(history.OpportunityId, history);
					}
				}
			}
			
			System.debug('fieldHistories');
			System.debug(fieldHistories);
			System.debug('fieldHistoryMap');
			System.debug(fieldHistoryMap);
		}
		
		//	Get the Extended Opportunity records for Solicitor Close Dates
		Map<Id, HPP_Extended_Opportunity__c> extendedOppsMap = new Map<Id, HPP_Extended_Opportunity__c>();
		List<HPP_Extended_Opportunity__c> extendedOpps = [
			SELECT Opportunity__c, Requested_Completion_Date__c
			FROM HPP_Extended_Opportunity__c
			WHERE Opportunity__c IN :opportunityIDs
			LIMIT :Limits.getLimitQueryRows()
		];
		for (HPP_Extended_Opportunity__c extendedOpp : extendedOpps) {
			extendedOppsMap.put(extendedOpp.Opportunity__c, extendedOpp);
		}
		
		for (Opportunity opp : opportunities) {
			System.debug('opp.Status_HPP_CAA__c => ' + opp.Status_HPP_CAA__c);
			System.debug('opp.RecordType => ' + opportunityRecordTypes.get(opp.RecordTypeId));
			
			setProbability(opp);
			setQuantity(opp);
			setAmount(opp);
			setCloseDate(opp, fieldHistoryMap.get(opp.Id), extendedOppsMap.get(opp.Id));
			setToleranceDate(opp);
		}
	}
	
	private void setProbability(Opportunity opp) {
		if (opp != null && hppFiguresMap.containsKey(opp.Status_HPP_CAA__c)) {
			opp.Probability = hppFiguresMap.get(opp.Status_HPP_CAA__c).Probability__c;
		}
	}
	
	private void setQuantity(Opportunity opp) {
		if (opp != null) {
			if (opportunityRecordTypes.containsKey(opp.RecordTypeId)) {
				String recordTypeName = opportunityRecordTypes.get(opp.RecordTypeId).DeveloperName;
				OpportunityForecastSettings__c forecastSettings = OpportunityForecastSettings__c.getValues(recordTypeName);
				if (forecastSettings != null) {
					opp.TotalOpportunityQuantity = forecastSettings.Quantity__c;
				}
			}
		}
	}
	
	private void setAmount(Opportunity opp) {
		if (opp != null) {
			if (opportunityRecordTypes.containsKey(opp.RecordTypeId)) {
				String recordTypeName = opportunityRecordTypes.get(opp.RecordTypeId).DeveloperName;
				OpportunityForecastSettings__c forecastSettings = OpportunityForecastSettings__c.getValues(recordTypeName);
				
				if (forecastSettings != null && String.isNotBlank(forecastSettings.AmountField__c)) {
					try {
						opp.Amount = (Decimal)opp.get(forecastSettings.AmountField__c);
					}
					catch (Exception ex) {
						System.debug(ex);
						System.debug(ex.getMessage());
						System.debug(ex.getLineNumber());
					}
				}
			}
		}
	}
	
	private void setCloseDate(Opportunity opp, OpportunityFieldHistory history, HPP_Extended_Opportunity__c extendedOpp) {
		System.debug('### setCloseDate ###');
		System.debug('opp => ' + opp);
		System.debug('history => ' + history);
		System.debug('extendedOpp => ' + extendedOpp);
		
		if (opp != null) {
			if (extendedOpp != null && extendedOpp.Requested_Completion_Date__c != null) {
				//	Use the Solicitor Requested Completion Date
				opp.CloseDate = extendedOpp.Requested_Completion_Date__c;
			}
			else {
				//	Use the average days to won value, if present
				if (hppFiguresMap.containsKey(opp.Status_HPP_CAA__c) && hppFiguresMap.get(opp.Status_HPP_CAA__c).AverageStatusAgeToWon__c != null) {
					Integer daysToClose = Integer.valueOf(hppFiguresMap.get(opp.Status_HPP_CAA__c).AverageStatusAgeToWon__c);
					System.debug('daysToClose => ' + daysToClose);
					
					if (history != null && history.NewValue == opp.Status_HPP_CAA__c) {
						//	Use date field was changed plus days
						opp.CloseDate = history.CreatedDate.date().addDays(daysToClose);
					}
					else {
						//	Use today's date plus days
						opp.CloseDate = Date.today().addDays(daysToClose);
					}
				}
			}
		}
	}
	
	private void setToleranceDate(Opportunity opp) {
		System.debug('*** setToleranceDate() started.');
		System.debug('opp.Status_HPP_CAA__c => ' + opp.Status_HPP_CAA__c);
		
		if (opp != null && String.isNotBlank(opp.Status_HPP_CAA__c)) {
			String hppStatus = (opp.Status_HPP_CAA__c.length() > 38) ? opp.Status_HPP_CAA__c.substring(0, 38) : opp.Status_HPP_CAA__c;
			HPPStatusTolerances__c hppStatusTolerance = HPPStatusTolerances__c.getValues(hppStatus);
			System.debug('hppStatusTolerance => ' + hppStatusTolerance);
			
			if (hppStatusTolerance != null) {
				Integer toleranceDays = Integer.valueOf(hppStatusTolerance.ToleranceDuration__c);
				opp.ForecastToleranceDate__c = (toleranceDays != null) ? Date.today().addDays(toleranceDays) : Date.today();
			}
			else {
				//	Default to no tolerance date, to prevent Opportunity from being omitted
				opp.ForecastToleranceDate__c = null;
			}
		}
		
		System.debug('*** setToleranceDate() ended.');
	}
	
	private Map<String, HPPStatusTotalFigures__c> hppFiguresMap {
		get {
			if (hppFiguresMap == null) {
				hppFiguresMap = new Map<String, HPPStatusTotalFigures__c>();
				
				List<AggregateResult> latestFiguresDates = [
					SELECT MAX(RunDate__c) latestDate
					FROM HPPStatusTotalFigures__c
					WHERE Status__c IN :hppStatuses
				];
				System.debug('latestFiguresDates');
				System.debug(latestFiguresDates);
				
				Date latestFiguresDate = null;
				if (!latestFiguresDates.isEmpty()) {
					latestFiguresDate = (Date)latestFiguresDates[0].get('latestDate');
					System.debug('latestFiguresDate');
					System.debug(latestFiguresDate);
					
					List<HPPStatusTotalFigures__c> latestFigures = [
						SELECT Status__c, Probability__c, AverageStatusAgeToWon__c
						FROM HPPStatusTotalFigures__c
						WHERE RunDate__c = :latestFiguresDate
							AND Status__c IN :hppStatuses
						ORDER BY Status__c ASC NULLS LAST
						LIMIT :Limits.getLimitQueryRows()
					];
					hppFiguresMap = new Map<String, HPPStatusTotalFigures__c>();
					for (HPPStatusTotalFigures__c figures : latestFigures) {
						hppFiguresMap.put(figures.Status__c, figures);
					}	
				}
			}
			return hppFiguresMap;
		}
		private set;
	}
}