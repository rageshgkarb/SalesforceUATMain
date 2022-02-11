global class OpenOpportunitiesUpdate implements Database.Batchable<SObject> {
	global Database.QueryLocator start(Database.BatchableContext context) {
		Trigger_Helper.TriggerItem tItem = new Trigger_Helper.TriggerItem();
		tItem.IgnoreAudit = true;
		tItem.IgnoreTrigger = true;
		tItem.Name = 'Opportunity';
		Trigger_Helper.Items = new Trigger_Helper.TriggerItem[] { tItem };
		
		List<OpportunityForecastSettings__c> forecastSettings = [
			SELECT AmountField__c
			FROM OpportunityForecastSettings__c
			WHERE AmountField__c != null
			ORDER BY AmountField__c ASC
		];
		
		Set<String> uniqueAmountFields = new Set<String>();
		String amountFields = '';
		for (OpportunityForecastSettings__c setting : forecastSettings) {
			
			if (String.isNotBlank(setting.AmountField__c)) {
				if (!uniqueAmountFields.contains(setting.AmountField__c)){
					amountFields += setting.AmountField__c + ', ';
					uniqueAmountFields.add(setting.AmountField__c);
				}
			}
		}
		
        String queryString = 'SELECT Amount, TotalOpportunityQuantity, Status_HPP_CAA__c, RecordTypeId, RecordType.DeveloperName, ' + amountFields
        	+ '(SELECT OpportunityId, NewValue, Field, CreatedDate FROM Histories WHERE Field = \'Status_HPP_CAA__c\' ORDER BY CreatedDate DESC LIMIT 1), '
        	+ '(SELECT Requested_Completion_Date__c FROM HPP_Extended_Opportunities__r LIMIT 1) '
			+ 'FROM Opportunity '
			+ 'WHERE IsClosed = false ';
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext context, List<SObject> scopeObjects) {
    	List<Opportunity> opportunities = (List<Opportunity>)scopeObjects;
    	List<Opportunity> opportunitiesToUpdate = new List<Opportunity>(); 
    	
    	List<AggregateResult> latestFiguresDates = [
			SELECT MAX(RunDate__c) latestDate
			FROM HPPStatusTotalFigures__c
		];
		
		Date latestFiguresDate = null;
		if (!latestFiguresDates.isEmpty()) {
			latestFiguresDate = (Date)latestFiguresDates[0].get('latestDate');
			
			Map<String, HPPStatusTotalFigures__c> statusFiguresMap = new Map<String, HPPStatusTotalFigures__c>();
	    	List<HPPStatusTotalFigures__c> allStatusFigures = [
	    		SELECT Status__c, AverageStatusAgeToWon__c, Probability__c
	    		FROM HPPStatusTotalFigures__c
	    		WHERE RunDate__c = :latestFiguresDate
	    	];
	    	for (HPPStatusTotalFigures__c figures : allStatusFigures) {
	    		if (!statusFiguresMap.containsKey(figures.Status__c)) {
	    			statusFiguresMap.put(figures.Status__c, figures);
	    		}
	    	}
	    	
	    	for (Opportunity opp : opportunities) {
	    		Boolean updateOpportunity = false;
	    		
	    		OpportunityForecastSettings__c forecastSettings = OpportunityForecastSettings__c.getInstance(opp.RecordType.DeveloperName);
	    		if (forecastSettings != null) {
	    			try {
	    				Decimal quantity = forecastSettings.Quantity__c;
	    				Decimal amount = null;
	    				if (String.isNotBlank(forecastSettings.AmountField__c)) {
	    					amount = (Decimal)opp.get(forecastSettings.AmountField__c);
	    				}
	    				
	    				opp.TotalOpportunityQuantity = quantity;
	    				opp.Amount = amount;
	    				updateOpportunity = true;
	    			}
	    			catch (Exception ex) {
	    				System.debug('Unable to set Opportunity Quantity and Amount.');
	    				System.debug(ex);
	    				System.debug(ex.getMessage());
	    			}
	    		}
	    		
	    		if (String.isNotBlank(opp.Status_HPP_CAA__c) && statusFiguresMap.containsKey(opp.Status_HPP_CAA__c)) {
		    		HPPStatusTotalFigures__c statusFigures = statusFiguresMap.get(opp.Status_HPP_CAA__c);
		    		
		    		Decimal probability = statusFigures.Probability__c;
		    		opp.Probability = probability;
		    		
		    		Date closeDate = null;
		    		
		    		//	If Actual Completion Date is set, then use that
		    		if (!opp.HPP_Extended_Opportunities__r.isEmpty()) {
		    			HPP_Extended_Opportunity__c extendedOpp = opp.HPP_Extended_Opportunities__r[0];
		    			if (extendedOpp.Requested_Completion_Date__c != null) {
			    			closeDate = extendedOpp.Requested_Completion_Date__c;
			    			opp.CloseDate = closeDate;
		    			}
		    		}
		    		
		    		//	If no Actual Completion Date, then work out from Status field history and average age
		    		if (closeDate == null && !opp.Histories.isEmpty() && statusFigures.AverageStatusAgeToWon__c != null) {
						Date statusChangeDate = opp.Histories[0].CreatedDate.date();
						closeDate = statusChangeDate.addDays(Integer.valueOf(statusFigures.AverageStatusAgeToWon__c));
						opp.CloseDate = closeDate;
		    		}
		    		
		    		updateOpportunity = true;
	    		}
				
				if (updateOpportunity) {
					opportunitiesToUpdate.add(opp);
				}
	    	}
	    	
	    	if (!opportunitiesToUpdate.isEmpty()) {
	    		Trigger_Helper.TriggerItem tItem = new Trigger_Helper.TriggerItem();
				tItem.IgnoreAudit = true;
				tItem.IgnoreTrigger = true;
				tItem.Name = 'Opportunity';
				Trigger_Helper.Items = new Trigger_Helper.TriggerItem[] { tItem };
	    		
	    		//	update opportunitiesToUpdate;
	    		Database.update(opportunitiesToUpdate, false);
	    	}	
		}
    }
    
    global void finish(Database.BatchableContext context) {

    }
}