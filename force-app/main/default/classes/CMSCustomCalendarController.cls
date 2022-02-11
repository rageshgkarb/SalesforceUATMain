public without sharing class CMSCustomCalendarController {
	
	public CMSCustomCalendarMonth choosenDay {get;set;}
	public date selectedDateValue {get;set;}
	public CMSDateWrapper dateSelected {get;set;}
  public Branch__c theBranch {get;set;}
	
	public string selectedDateStr {get;set;}
	
  public void next() { 
    addMonth(1);
  }

  public void prev() { 
    addMonth(-1); 
  }

  public CMSCustomCalendarController() {
 
   Date d = system.today();
   Integer mo = d.month(); 
   String m_param = System.currentPageReference().getParameters().get('mo');
   String y_param = System.currentPageReference().getParameters().get('yr');
   String branchID = System.currentPageReference().getParameters().get('branchID');
   theBranch = [SELECT Id, Branch_Open_Days__c FROM Branch__c WHERE Id =: branchID];

   //allow a month to be passed in on the url as mo=10
   if (m_param != null) { 
        Integer mi = Integer.valueOf(m_param); 
        if (mi > 0 && mi <= 12) {
          d = Date.newInstance(d.year(),mi,d.day());
        }
   }
   //and year as yr=2008
   if (y_param != null) { 
        Integer yr = Integer.valueOf(y_param); 
        d = Date.newInstance(yr, d.month(), d.day());
   }
     
   selectedDateValue = date.today();
   dateSelected = new CMSDateWrapper(); 
     dateSelected.thedate = selectedDateValue;
   datetime tempDt = datetime.newInstance(selectedDateValue.year(), selectedDateValue.month(), selectedDateValue.day(), 00, 00, 00);
  	selectedDateStr = tempDt.format('dd/MM/YYYY');

   setMonth(d);
  }
 
  public list<CMSCustomCalendarMonth.Week> getWeeks() { 
    system.assert(month!=null,'month is null');
    return month.getWeeks();
  }
  
  public CMSCustomCalendarMonth getMonth() { return month; } 


  private void setMonth(Date d) { 
    month = new CMSCustomCalendarMonth(d, theBranch);  
    system.assert(month != null); 

    Date[] da = month.getValidDateRange(); //gather events that fall in this month

  }
  
  private void addMonth(Integer val) { 
    Date d = month.getFirstDate();
    d = d.addMonths(val);
    setMonth(d);
  }

  private CMSCustomCalendarMonth month;
  
  public void highlightChosenDate(){
  	
  	system.debug(ApexPages.currentPage().getParameters().get('selectedDate'));
  	selectedDateValue = date.valueOf(ApexPages.currentPage().getParameters().get('selectedDate'));
  	
  	datetime tempDt = datetime.newInstance(selectedDateValue.year(), selectedDateValue.month(), selectedDateValue.day(), 00, 00, 00);
  	
  	selectedDateStr = tempDt.format('dd/MM/YYYY');
  	
  	list<CMSCustomCalendarMonth.Week> tempWeeks = getWeeks();
  	
  	for(CMSCustomCalendarMonth.Week wk : tempWeeks){
  		for(CMSCustomCalendarMonth.Day day : wk.days){
  			if(day.theDate == selectedDateValue){
  				day.IsSelectedDate = true;
  			}else{
  				day.IsSelectedDate = false;
  			}
  		}
  	}
  	
  	system.debug('*** -- dateSelected obj : ' + dateSelected);
  	system.debug('*** -- selectedDateValue  : ' + selectedDateValue);
  	
  	dateSelected.thedate = selectedDateValue;
  	
  }  
}