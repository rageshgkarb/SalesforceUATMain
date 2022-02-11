public with sharing class KRIReportSelection 
{
  transient public List<grc__Risk__c> theRisks {get;set;}  
  transient public List<ReportRow> reportRows {get;set;}
  public datetime theDateTimeNow {get;set;}
  public String dateRanges {get;set;}
  public String [] MonthsList{get;set;}
  public Map<Id, List<HeatMapReportHelper.BU>> availableBusinessUnitHierarchy {get; set;}
  public Id chosenBusinessUnitId{get; set;}
  public List<FilterOption> filterOptions {get;set;}
  public List<SelectOption> CategoryFilterOption{get;set;}
  public String[] SelectedCategories{get;set;}
  public boolean AllChildrenSelected{get;set;}
  
  public KRIReportSelection()
  {
    filterOptions = new List<FilterOption>();
    filterOptions.add(new FilterOption('Risk Title'));
    filterOptions.add(new FilterOption('Business Unit'));
    filterOptions.add(new FilterOption('Risk Category'));
    filterOptions.add(new FilterOption('Risk Subcategory'));
    filterOptions.add(new FilterOption('Inherent Rating'));
    filterOptions.add(new FilterOption('Residual Rating'));
    
    AllChildrenSelected = false;
    
    getBusinessUnitsMap(); 
    
    CategoryFilterOption = new List<SelectOption>(); 
 
	for(Schema.PicklistEntry res : grc__Risk__c.grc__Category__c.getDescribe().getPickListValues())
	{	
		CategoryFilterOption.add(new SelectOption(res.getValue(),res.getLabel()));
	} 
	SelectedCategories = new String[]{};
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
    theRisks = new List<grc__Risk__c>();
    Set<Id> selectedBUIDSet = selectedBusinessUnits(chosenBusinessUnitId);
    String filterStr ='';
    if(selectedBUIDSet != null && selectedBUIDSet.size()>0)
    {
    	filterStr = ' WHERE grc__Business_Unit__c IN :selectedBUIDSet ';
    }
    if(SelectedCategories != null && SelectedCategories.size()>0)
    {
    	boolean allSelected = false;
    	for(String str : SelectedCategories)
    	{
    		if(str == 'All')
    		{
    			allSelected = true;
    		}
    	}
    	if(!allSelected)
    	{
    		filterStr = filterStr + (filterStr.contains('WHERE') ? ' AND grc__Category__c IN :SelectedCategories' : 'WHERE grc__Category__c IN :SelectedCategories');
    	}
    }
    
    String queryString = ' select grc__Subcategory__c,Risk__Inherent_Rating__c,Risk__Residual_Rating__c, grc__Key_Risk__c, grc__Category__c, grc__Business_Unit__r.Name,'+ 
                       ' grc__Business_Unit__c, Risk__Residual_Score__c, Risk__Inherent_Score__c, Name, Id,'+
                       ' Risk__Inherent_Likelihood_Text__c, '+
                       ' Risk__Inherent_Impact_Text__c, Risk__Residual_Likelihood_Text__c, Risk__Residual_Impact_Text__c, '+
                       ' ( select Risk__Control__r.Name '+
                       ' from Risk__Risk_Control_Lookup__r ) '+
                ' from grc__Risk__c '+filterStr+
                +' order by Name limit 2000 ';

    theRisks = Database.query(queryString);
    Set<Id> riskIds = new Set<Id>();          
    for(grc__Risk__c risk : theRisks)
    {    
      riskIds.add(risk.Id);
    }
    
    List<Risk__Risk_KRI_Lookup__c> riskKRILookups = new List<Risk__Risk_KRI_Lookup__c>();
    
    riskKRILookups = [select Risk__Risk__c, Risk__KRI__c from Risk__Risk_KRI_Lookup__c where Risk__Risk__c in : riskIds];
     
    Set<Id> kriIDsSet = new Set<Id>(); 
    Map<Id, Set<Id>> riskToKRI = new Map<Id, Set<Id>>();
                     
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
    
    Datetime lastSearchDate = setupSelectedDateRange(dateRanges);
    if(lastSearchDate == null) return null;
    
    MonthsList = getDateList(lastSearchDate);
    Map<Id, Risk__KRI__c> theKRIMap = new Map<Id, Risk__KRI__c>();
    theKRIMap = new Map<Id, Risk__KRI__c>([select Id, Name,
                                         (select Id, Name,Risk__Score__c, Risk__Review_Summary__c, Risk__Review_Date__c
                                          from Risk__Reviews__r
                                          where Risk__Review_Date__c <= :theDateTimeNow
                                          and Risk__Review_Date__c >= :lastSearchDate and Risk__Submitted__c = true order by name),
                                         (select Id, Name,Risk__Metric__r.Name
                                          from Risk__KRI_Metrics__r)
                                           from Risk__KRI__c
                                 where Id in : kriIDsSet]);
    
    Map<Id, KRIHive> kriToHiveMap = new Map<Id, KRIHive>();
   
    for(Risk__KRI__c theKRI : theKRIMap.values())
    {
      
      KRIHive hive = new KRIHive(theKRI, getDateAssociatedReviews(theKRI.Risk__Reviews__r));
      
      kriToHiveMap.put(theKRI.Id, hive);
    }
    
    reportRows = new List<ReportRow>();
    
    for(grc__Risk__c risk : theRisks)
    {
      List<KRIHive> hives = new List<KRIHive>();
      
      Set<Id> kriIds = new Set<Id>();
      
      kriIds = riskToKRI.get(risk.Id);
      if(kriIds != null)
      {
	      for(Id kriId : kriIds)
	      {
	        if(kriToHiveMap.get(kriId) != null)
	        {
	          hives.add(kriToHiveMap.get(kriId));
	        }
	      }
      }

      ReportRow rr = new ReportRow(risk, hives);

      reportRows.add(rr);
    }
    
    PageReference pr = Page.KRIReport;
    
    pr.setRedirect(false); 
    
    return pr;
  }
  
  private Map<String,Risk__KRI_Review__c> getDateAssociatedReviews(List<Risk__KRI_Review__c> reviewsList)
  {
  	  Map<String,Risk__KRI_Review__c> theReviews = new Map<String,Risk__KRI_Review__c>();
      for(Risk__KRI_Review__c rw : reviewsList)
      {
      	theReviews.put(rw.Risk__Review_Date__c.format('MMMMM')+' - '+rw.Risk__Review_Date__c.year(),rw);
      }
      for(String monthKey : MonthsList)
      {
      	if(! (theReviews.containsKey(monthKey)))
      	{
      		theReviews.put(monthKey,new Risk__KRI_Review__c());
      	}
      }
      return theReviews;
  }
  
  private DateTime setupSelectedDateRange(String range)
  {
 	theDateTimeNow = datetime.now();
 	datetime endDate;
    Integer month;
    Integer year;
  	if(range == '1 Month')
  	{
  		endDate = theDateTimeNow.addMonths(-1);
  		month = endDate.month();
  		year = endDate.year();
  	}
  	else if(range == '3 Months')
  	{
  		endDate = theDateTimeNow.addMonths(-3);
  		month = endDate.month();
  		year = endDate.year();
  		
  	}
  	else if(range == '6 Months')
  	{
  		endDate = theDateTimeNow.addMonths(-6);
  		month = endDate.month();
  		year = endDate.year();
  	}
  	else
  	{
  		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select a Date Range');
  		ApexPages.addMessage(myMsg);
  	}
  	
  	return endDate;
  }
  
  private List<String> getDateList(DateTime lastDate)
  {
  	String[] selectedMonths = new String[]{};
  	for(Integer i = 0; i < lastDate.date().monthsBetween(Date.today()); i++)
  	{
  		DateTime tempDate = theDateTimeNow.addMonths(-i);
  		selectedMonths.add(tempDate.format('MMMMM')+' - '+tempDate.year());
  	}
  	return 	selectedMonths;
  }
 
	private void getBusinessUnitsMap()
	{
		HeatMapReportHelper help = new HeatMapReportHelper();
		Map<Id, List<HeatMapReportHelper.BU>> output = new Map<Id, List<HeatMapReportHelper.BU>>();
		
		// If a business unit has been chosen then simply get this and its children.
		if(chosenBusinessUnitId != null)
		{
			output.put(chosenBusinessUnitId, help.getHierachyFlat(chosenBusinessUnitId));
			availableBusinessUnitHierarchy = output;
		}
		else // If no business unit has been chosen then get all the business units with the user's membership and their children.
		{					
			output.putAll(help.getHierachyFlat(new Set<Id>(getTopLevelBUIds())));
			availableBusinessUnitHierarchy = output;			
		}
	}
	
	public void getSelection()
	{
		List<List<HeatMapReportHelper.BU>> selectedBUListOfList = availableBusinessUnitHierarchy.values();
		List<HeatMapReportHelper.BU> selectedBUs = new List<HeatMapReportHelper.BU>();
		for(List<HeatMapReportHelper.BU>  buList : selectedBUListOfList)
		{
			selectedBUs.addAll(buList);
		}
		if(selectedBUs != null)
		{
			for(HeatMapReportHelper.BU tempBU : selectedBUs)
			{
				if(tempBU.me.Id == chosenBusinessUnitId)
				{
					tempBU.Selected = true;
				}
				else
				{
					tempBU.Selected = false;
				}
			}
		}
	}
	
  private List<Id> getTopLevelBUIds()
  {
  		// First get the group member records of the current user.		
		List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId, GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()];
		Map<String,grc__Business_Unit__c> buMaptoGroupName = new Map<String,grc__Business_Unit__c>();
		for(grc__Business_Unit__c b : [Select Risk__Sharing_Group_Name__c,id From grc__Business_Unit__c LIMIT 1000])
		{
			buMaptoGroupName.put(b.Risk__Sharing_Group_Name__c,b);
		}
		
		// Now get the groups which the GroupMember records are related to.
		Set<Id> groupIds = new Set<Id>();
		for(GroupMember gm : groupMembers)
		{
			groupIds.add(gm.GroupId);
		}
		List<Group> groups = [SELECT Id, Name FROM Group WHERE Id IN :groupIds];
		// Finally get the business unit ids which the groups are related to.
		List<Id> businessUnitIds = new List<Id>();
		for(Group gr : groups)
		{
			List<String> buIds = gr.Name.split('-');
			
			if((buIds.size() == 3) && (buIds[1] == 'Xactium') && (buIds[2].contains('R') || buIds[2].contains('W')))
			{
				if(buMaptoGroupName.keySet().contains(buIds[0]))
				{
					businessUnitIds.add(buMaptoGroupName.get(buIds[0]).id);
				}
			}
		}
		return businessUnitIds;
  }
  
   private set<Id> selectedBusinessUnits(Id selecteBUID)
   {
        Set<Id> output = new Set<Id>();
        if(selecteBUID != null)
        {
            output.add(selecteBUID);
        }
        if(AllChildrenSelected)
        {
            List<HeatMapReportHelper.BU> temp = new HeatMapReportHelper().getHierachyFlat(selecteBUID);
            for(HeatMapReportHelper.BU bu : temp)
            {
                output.add(bu.me.Id);
            }
        }
        return output;
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
    public Map<String,Risk__KRI_Review__c> theReviews {get;set;}
    
    public KRIHive(Risk__KRI__c theKRI, Map<String,Risk__KRI_Review__c> theReviews)
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