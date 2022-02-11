public with sharing class RIReportSelection {

	transient public List<grc__Risk__c> theRisks {get;set;}  

	transient public List<ReportRow> reportRows {get;set;}
	
	public date todayDate {get;set;}
	
	public datetime sixMonthsAgoBeginningOfMonth {get;set;}
	
	public datetime theDateTimeNow {get;set;}
	
	public String[] dateRanges {get;set;}
	
	public List<FilterOption> filterOptions {get;set;}
	
	public RIReportSelection()
	{
		filterOptions = new List<FilterOption>();
		
		filterOptions.add(new FilterOption('Bank Risk Register ID'));
		filterOptions.add(new FilterOption('Board Risk Register ID'));
		filterOptions.add(new FilterOption('KRI Number'));
		filterOptions.add(new FilterOption('Level 1 Risk'));
		filterOptions.add(new FilterOption('Level 2 Risk'));
		filterOptions.add(new FilterOption('Risk Title'));
		filterOptions.add(new FilterOption('Level 3 Risk'));
		filterOptions.add(new FilterOption('Bank Inherent (Probability/Impact)'));
		filterOptions.add(new FilterOption('Controls'));
		filterOptions.add(new FilterOption('Bank Residual (Probability/Impact)'));
		filterOptions.add(new FilterOption('Risk Weighting'));
		filterOptions.add(new FilterOption('Owner'));
		filterOptions.add(new FilterOption('Process'));
		filterOptions.add(new FilterOption('Frequency'));
	//	filterOptions.add(new FilterOption('Level 3 Monitoring'));
		filterOptions.add(new FilterOption('Metric Information'));

	}
	
	public List<SelectOption> getDateRange() 
	{
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1 Month','1 Month'));
        options.add(new SelectOption('3 Months','3 Months'));
        options.add(new SelectOption('6 Months','6 Months'));
        return options;
    }
	
	public PageReference buildReport()
	{
		system.debug('## JT - 1');
		
		theRisks = new List<grc__Risk__c>();
		
		theRisks = [select grc__Subcategory__c, grc__Key_Risk__c, IBB_Level_3_Description__c, grc__Category__c, grc__Business_Unit__r.Name, 
		                   grc__Business_Unit__c, Risk__Residual_Score__c, Risk__Inherent_Score__c, Process__c, Pillar__c, Name, Id,
		                   IBB_KRI_Number__c, Frequency__c, Board_Risk_Register_ID__c, Bank_Risk_Register_ID__c, Risk__Inherent_Likelihood_Text__c,
		                   Risk__Inherent_Impact_Text__c, Risk__Residual_Likelihood_Text__c, Risk__Residual_Impact_Text__c, IBB_Risk_Weighting__c,
		                   (select Risk__Control__r.Name 
		                    from Risk__Risk_Control_Lookup__r)
		            from grc__Risk__c
		            limit 2000];
		
		system.debug('## JT - 2');
		
		Set<Id> riskIds = new Set<Id>();
            
		for(grc__Risk__c risk : theRisks)
		{		
			riskIds.add(risk.Id);
		}
		
		List<Risk__Risk_KRI_Lookup__c> riskKRILookups = new List<Risk__Risk_KRI_Lookup__c>();
		
		riskKRILookups = [select Risk__Risk__c, Risk__KRI__c
		                  from Risk__Risk_KRI_Lookup__c
		                  where Risk__Risk__c in : riskIds];
		 
		Set<Id> kriIDsSet = new Set<Id>(); 
		Map<Id, Set<Id>> riskToKRI = new Map<Id, Set<Id>>();
		   
		system.debug('## JT - 3');   
		                  
		for(Risk__Risk_KRI_Lookup__c riskKRI : riskKRILookups)
		{
			kriIDsSet.add(riskKRI.Risk__KRI__c);
			
			Set<Id> kriIds = new Set<Id>();
			
			if(riskToKRI.get(riskKRI.Risk__Risk__c) == null)
			{
				kriIds.add(riskKRI.Risk__KRI__c);
				
				riskToKRI.put(riskKRI.Risk__Risk__c, kriIds);
			}
			else
			{
				kriIds = riskToKRI.get(riskKRI.Risk__Risk__c);
				
				kriIds.add(riskKRI.Risk__KRI__c);
				
				riskToKRI.put(riskKRI.Risk__Risk__c, kriIds);
			}

		}
		
		todayDate = date.today();

		theDateTimeNow = datetime.now();
		datetime exactlySixMonthsAgo = theDateTimeNow.addMonths(-6);
		
		Integer month = exactlySixMonthsAgo.month();
		Integer year = exactlySixMonthsAgo.year();
		
		sixMonthsAgoBeginningOfMonth = datetime.newInstance(year, month, 1);
		
		Map<Id, Risk__KRI__c> theKRIMap = new Map<Id, Risk__KRI__c>();
		
		system.debug('## JT - 4');
		
		theKRIMap = new Map<Id, Risk__KRI__c>([select Id, Name,
						                             (select Id, Name, Risk__KRI_Review_Rating__c, Risk__Review_Date__c
						                              from Risk__Reviews__r
						                              where Risk__Review_Date__c <= :theDateTimeNow
						                              and Risk__Review_Date__c >= :sixMonthsAgoBeginningOfMonth),
						                             (select Id, Name, Risk__Metric__r.Description__c
						                              from Risk__KRI_Metrics__r)
		                                       from Risk__KRI__c
		           						 	   where Id in : kriIDsSet]);
		
		Map<Id, KRIHive> kriToHiveMap = new Map<Id, KRIHive>();
		
		system.debug('## JT - 5');
		
		for(Risk__KRI__c theKRI : theKRIMap.values())
		{
			List<Risk__KRI_Review__c> theReviews = new List<Risk__KRI_Review__c>();
			
			theReviews = theKRI.Risk__Reviews__r;

			KRIHive hive = new KRIHive(theKRI, theReviews);
			
			kriToHiveMap.put(theKRI.Id, hive);
		}
		
		reportRows = new List<ReportRow>();
		
		for(grc__Risk__c risk : theRisks)
		{
			List<KRIHive> hives = new List<KRIHive>();
			
			Set<Id> kriIds = new Set<Id>();
			
			kriIds = riskToKRI.get(risk.Id);
			
			for(Id kriId : kriIds)
			{
				if(kriToHiveMap.get(kriId) != null)
				{
					hives.add(kriToHiveMap.get(kriId));
				}
			}
			
			ReportRow rr = new ReportRow(risk, hives);

			reportRows.add(rr);
		}
		
		system.debug('## JT - 6');
		
		PageReference pr = Page.RIReport;
		
		pr.setRedirect(false);
		
		system.debug('## JT - 7 ' + pr);

		return pr;
	}
	
	public class FilterOption
	{
		public String fieldName {get;set;}
		public Boolean selected {get;set;}
		
		public FilterOption(String fieldName)
		{
			this.fieldName = fieldName;
			this.selected = true;
		}
	}
	
	public class KRIHive
	{
		public Risk__KRI__c theKRI {get;set;}
		public List<Risk__KRI_Review__c> theReviews {get;set;}
		
		public KRIHive(Risk__KRI__c theKRI, List<Risk__KRI_Review__c> theReviews)
		{
			this.theKRI = theKRI;
			this.theReviews = theReviews;
		}
	}
	
	public class ReportRow
	{
		public grc__Risk__c theRisk {get;set;}
		public List<KRIHive> theKRIHives {get;set;}
		
		public ReportRow(grc__Risk__c theRisk, List<KRIHive> theKRIHives)
		{
			this.theRisk = theRisk;
			this.theKRIHives = theKRIHives;
		}
	}

}