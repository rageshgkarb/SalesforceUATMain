@isTest
public class HPPStatusFiguresTestData {
	private static List<HPPStatusFigures__c> hppStatusFigures;
	private static List<HPPStatusTotalFigures__c> hppStatusTotalFigures;
	private static List<OpportunityForecastSettings__c> opportunityForecastSettings; 
	
	public static List<HPPStatusFigures__c> getHPPStatusFigures() {
		if (hppStatusFigures == null) {
			hppStatusFigures = Test.loadData(HPPStatusFigures__c.sObjectType, 'HPPStatusFiguresTestData');
		}
		return hppStatusFigures;
	}
	
	public static List<HPPStatusTotalFigures__c> getHPPStatusTotalFigures() {
		if (hppStatusTotalFigures == null) {
			hppStatusTotalFigures = Test.loadData(HPPStatusTotalFigures__c.sObjectType, 'HPPStatusTotalFiguresTestData');
		}
		return hppStatusTotalFigures;
	}
	
	public static List<OpportunityForecastSettings__c> getOpportunityForecastSettings() {
		if (opportunityForecastSettings == null) {
			opportunityForecastSettings = Test.loadData(OpportunityForecastSettings__c.sObjectType, 'OpportunityForecastSettingsTestData');
		}
		return opportunityForecastSettings;
	}
}