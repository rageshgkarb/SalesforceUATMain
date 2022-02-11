trigger ApplicantTrigger on Applicant__c (after insert, after update, before insert, 
before update) {
	/*
	if (trigger.isAfter){
		if (trigger.isUpdate){
			for (Applicant__c a : trigger.new){
				String oppId = a.Opportunity__c;
				String accId = a.Prospect_Customer__c;
				String webLogId = ApplicantTriggerMethods.createWebIntegrationLog(a.Id);
				ApplicantTriggerMethods.accessDecisionEngine(webLogId, a.Id);
			}
		}
	}
	*/
}