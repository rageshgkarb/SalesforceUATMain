public with sharing class KCIReportSelection {

  transient public List<grc__Control__c> theControls {get;set;}  
  transient public List<ReportRow> reportRows {get;set;}
  public datetime theDateTimeNow {get;set;}
  public String dateRanges {get;set;}
  public String [] MonthsList{get;set;}
  public Map<Id, List<HeatmapReportHelper.BU>> availableBusinessUnitHierarchy {get; set;}
  public Id chosenBusinessUnitId{get; set;}
  public List<SelectOption> CategoryFilterOption{get;set;}
  public String[] SelectedCategories{get;set;}
  public boolean AllChildrenSelected{get;set;}
 
  public KCIReportSelection() 
  { 
    AllChildrenSelected = false;
    
    getBusinessUnitsMap(); 
   
    CategoryFilterOption = new List<SelectOption>(); 

  for(Schema.PicklistEntry res : grc__Control__c.grc__Category__c.getDescribe().getPickListValues())
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
    theControls = new List<grc__Control__c>();
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
    
    String queryString = ' select grc__Business_Unit__r.Name, grc__Business_Unit__c, Name, Id,grc__Category__c , ( select Risk__Control__r.Name  from Risk__Risk_Control_Lookup__r )  from grc__Control__c '+filterStr+' order by Name limit 2000 ';

    theControls = Database.query(queryString);
    
    Set<Id> controlIds = new Set<Id>();          
    for(grc__Control__c control : theControls)
    {    
      controlIds.add(control.Id);
    }
    
    List<Risk__Control_KCI_Lookup__c> controlKCILookups = new List<Risk__Control_KCI_Lookup__c>();
    
    controlKCILookups = [select Risk__KCI__c, Risk__Control__c from Risk__Control_KCI_Lookup__c where Risk__Control__c in : controlIds];
     
    Set<Id> KCIIDsSet = new Set<Id>(); 
    Map<Id, Set<Id>> controlToKCI = new Map<Id, Set<Id>>();
                     
    for(Risk__Control_KCI_Lookup__c controlKCI : controlKCILookups)
    {
      KCIIDsSet.add(controlKCI.Risk__KCI__c);
      Set<Id> KCIIds = new Set<Id>();
      
      if(controlToKCI.get(controlKCI.Risk__Control__c) == null)
      {
        KCIIds.add(controlKCI.Risk__KCI__c);
        controlToKCI.put(controlKCI.Risk__Control__c, KCIIds);
      }
      else
      {
        KCIIds = controlToKCI.get(controlKCI.Risk__Control__c);
        KCIIds.add(controlKCI.Risk__KCI__c);
        controlToKCI.put(controlKCI.Risk__Control__c, KCIIds);
      }
    }
    
    Datetime lastSearchDate = setupSelectedDateRange(dateRanges);
    if(lastSearchDate == null) return null;
    
    MonthsList = getDateList(lastSearchDate);
    Map<Id, Risk__KCI__c> theKCIMap = new Map<Id, Risk__KCI__c>();

    theKCIMap = new Map<Id, Risk__KCI__c>([select Id, Name,
                                         (select Id, Name,Risk__Score__c, Risk__Review_Summary__c, Risk__Rating__c, Risk__Review_Date__c
                                          from Risk__Reviews__r
                                          where Risk__Review_Date__c <= :theDateTimeNow
                                          and Risk__Review_Date__c >= :lastSearchDate and Risk__Submitted__c = true order by name),
                                         (select Id, Name,Risk__Metric__r.Name
                                          from Risk__KCI_Metrics__r)
                                           from Risk__KCI__c
                                 where Id in : KCIIDsSet]);
                                 
    
    Map<Id, KCIHive> KCIToHiveMap = new Map<Id, KCIHive>();
   
    for(Risk__KCI__c theKCI : theKCIMap.values())
    {
      KCIHive hive = new KCIHive(theKCI, getDateAssociatedReviews(theKCI.Risk__Reviews__r));
      KCIToHiveMap.put(theKCI.Id, hive);
    }

    reportRows = new List<ReportRow>();
    
    for(grc__Control__c control : theControls)
    {
      List<KCIHive> hives = new List<KCIHive>();
      
      Set<Id> KCIIds = new Set<Id>();
      
      KCIIds = controlToKCI.get(control.Id);
     
      if(KCIIds != null)
      {
        for(Id KCIId : KCIIds)
        {
          if(KCIToHiveMap.get(KCIId) != null)
          {
            hives.add(KCIToHiveMap.get(KCIId));
          }
        }
      }
    
      ReportRow rr = new ReportRow(control, hives);

      reportRows.add(rr);
    }
    
    PageReference pr = Page.KCIReport;
    
    pr.setRedirect(false); 
    
    return pr;
  }
  
  private Map<String,Risk__KCI_Review__c> getDateAssociatedReviews(List<Risk__KCI_Review__c> reviewsList)
  {
      Map<String,Risk__KCI_Review__c> theReviews = new Map<String,Risk__KCI_Review__c>();
      for(Risk__KCI_Review__c rw : reviewsList)
      {
        theReviews.put(rw.Risk__Review_Date__c.format('MMMMM')+' - '+rw.Risk__Review_Date__c.year(),rw);
      }
      for(String monthKey : MonthsList)
      {
        if(! (theReviews.containsKey(monthKey)))
        {
          theReviews.put(monthKey,new Risk__KCI_Review__c());
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
    return   selectedMonths;
  }
 
  private void getBusinessUnitsMap()
  {
    HeatmapReportHelper help = new HeatmapReportHelper();
    Map<Id, List<HeatmapReportHelper.BU>> output = new Map<Id, List<HeatmapReportHelper.BU>>();
    
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
    List<List<HeatmapReportHelper.BU>> selectedBUListOfList = availableBusinessUnitHierarchy.values();
    List<HeatmapReportHelper.BU> selectedBUs = new List<HeatmapReportHelper.BU>();
    for(List<HeatmapReportHelper.BU>  buList : selectedBUListOfList)
    {
      selectedBUs.addAll(buList);
    }
    if(selectedBUs != null)
    {
      for(HeatmapReportHelper.BU tempBU : selectedBUs)
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
            List<HeatmapReportHelper.BU> temp = new HeatmapReportHelper().getHierachyFlat(selecteBUID);
            for(HeatmapReportHelper.BU bu : temp)
            {
                output.add(bu.me.Id);
            }
        }
        return output; 
   }
  
  public class KCIHive
  {
    public Risk__KCI__c theKCI {get;set;}
    public Map<String,Risk__KCI_Review__c> theReviews {get;set;}
    
    public KCIHive(Risk__KCI__c theKCI, Map<String,Risk__KCI_Review__c> theReviews)
    {
      this.theKCI = theKCI;
      this.theReviews = theReviews;
    }
  }
   
  public class ReportRow
  {
    public grc__Control__c theControl {get;set;}
    public List<KCIHive> theKCIHives {get;set;}
    
    public ReportRow(grc__Control__c theControl, List<KCIHive> theKCIHives)
    {
      this.theControl = theControl;
      this.theKCIHives = theKCIHives;
    }
  }
}