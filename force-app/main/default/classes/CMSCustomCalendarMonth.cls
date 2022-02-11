public without sharing class CMSCustomCalendarMonth {
	
	private List<Week> weeks; 
	public Date firstDate; // always the first of the month
	private Date upperLeft; 
	
	public List<Date> getValidDateRange() { 
		// return one date from the upper left, and one from the lower right
		List<Date> ret = new List<Date>();
		ret.add(upperLeft);
		ret.add(upperLeft.addDays(5*7) );
		return ret;
	}
	
	public String getMonthName() { 
		return DateTime.newInstance(firstDate.year(),firstdate.month(),firstdate.day()).format('MMMM');
	} 
	
	public String getYearName() { 
		return DateTime.newInstance(
		firstDate.year(),firstdate.month(),firstdate.day()).format('yyyy');
	} 
	
	public String[] getWeekdayNames() { 
		Date today = system.today().toStartOfWeek();
		DateTime dt = DateTime.newInstanceGmt(today.year(),today.month(),today.day());		
		list<String> ret = new list<String>();
		for(Integer i = 0; i < 7;i++) { 
			ret.add( dt.formatgmt('EEEE') );
			dt= dt.addDays(1);
		} 
		return ret;
	}
	
	public Date getfirstDate() { return firstDate; }
	
	public static map<date, Holiday> holidays {
		get {
			if (holidays == null) {
				list<Holiday> holidayList = [SELECT StartTimeInMinutes, RecurrenceType, RecurrenceStartDate, RecurrenceMonthOfYear, RecurrenceInterval, 
													RecurrenceInstance, RecurrenceEndDateOnly, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, Name, IsRecurrence, 
													IsAllDay, EndTimeInMinutes, Description, ActivityDate 
												FROM Holiday
												WHERE ActivityDate >= THIS_MONTH
												OR (IsRecurrence = true AND RecurrenceType = 'RecursYearly' AND RecurrenceStartDate <= THIS_MONTH 
													AND (RecurrenceEndDateOnly >= THIS_MONTH OR RecurrenceEndDateOnly = null))
												ORDER BY ActivityDate ASC];
				
				holidays = new map<date, Holiday>();
												
				for(Holiday hol : holidayList){
					if(hol.IsRecurrence){
						
						date todayDate = date.today();
						integer thisYear = todayDate.year();
						
						date holidayDayDate = date.newinstance(thisYear, convertMonthToInt(hol.RecurrenceMonthOfYear), hol.RecurrenceDayOfMonth);
						
						holidays.put(holidayDayDate, hol);
					}else{
						holidays.put(hol.ActivityDate, hol);
					}
				}								
			}
			return holidays;
		}
		set;
	} 

	public Branch__c theBranch {get;set;}

	public CMSCustomCalendarMonth( Date value, Branch__c inBranch ) {
		theBranch = inBranch;
		weeks = new List<Week>();
		firstDate = value.toStartOfMonth();
		upperLeft = firstDate.toStartOfWeek();
		Date tmp = upperLeft;
		for (Integer i = 0; i < 5; i++) {
			Week w = new Week(i+1,tmp,value.month(),theBranch);	
			system.assert(w!=null); 
			this.weeks.add( w );
			tmp = tmp.addDays(7);
		}		
	}
	
	public List<Week> getWeeks() { 
		system.assert(weeks!=null,'could not create weeks list');
		return this.weeks; 
	}
		

	/* 
	 * helper classes to define a month in terms of week and day
	 */
	public class Week {
	 public List<Day> days;
	 public Integer weekNumber; 
	 public Date startingDate; // the date that the first of this week is on
	 public Branch__c branch {get;set;}
	 // so sunday of this week
	 
	 public List<Day> getDays() { 
	 	
	 	for(Day d : days){
	 		d.assignCSSClass();
	 	}
	 	
	 	return this.days; 
	 	
	 }
	 
	 public Week () { 
	 	days = new List<Day>(); 	
	 }
	 public Week(Integer value,Date sunday,Integer month, Branch__c inBranch) { 
	 	this();
	 	weekNumber = value;
	 	startingDate = sunday;
	 	Date tmp = startingDate;
	 	branch = inBranch;
	 	for (Integer i = 0; i < 7; i++) {
	 		Day d = new Day( tmp,month,branch ); 
	 		tmp = tmp.addDays(1);
	 		d.dayOfWeek = i+1;  		
	 	//	system.debug(d);
	 		days.add(d);
	 	} 
	 	
	 }
	 public Integer getWeekNumber() { return this.weekNumber;}
	 public Date getStartingDate() { return this.startingDate;}
	 
	}
	
	public class Day {
		 
		public Date 		theDate;
		public Integer 		month, dayOfWeek;
		public String 		formatedDate; // for the formated time 	
		private String 		cssclass = 'calActive';
		 
		public Date 		getDate() { return theDate; }
		public Integer 		getDayOfMonth() { return theDate.day(); }
		public String 		getDayOfMonth2() { 
			if ( theDate.day() <= 9 ) 
				return '0'+theDate.day(); 
			return String.valueof( theDate.day()); 
		}
		public Integer getDayOfYear() { return theDate.dayOfYear(); }
		public String 		getFormatedDate() { return formatedDate; }
		public Integer 		getDayNumber() { return dayOfWeek; }
		public String 		getCSSName() { 	return cssclass; }
		
		public boolean isActive {get;set;}
		public boolean IsSelectedDate {get;set;}
		public Branch__c branch {get;set;}
		
		public Day(Date value,Integer vmonth, Branch__c inBranch) { 
			theDate=value; month=vmonth; 		
			formatedDate = string.valueOf(theDate);
			branch = inBranch;
			  
			if ( theDate.daysBetween(System.today()) == 0 ){
				IsSelectedDate = true;
			}else{
				IsSelectedDate = false;
			}
			
			assignCSSClass();
		}
		
		public void assignCSSClass(){

			if(theDate.month() != month){
				cssclass = 'CMSCustCalInactiveMonth';
			}else{
				cssclass = 'calActive';
			}
			
			if(IsSelectedDate){
				cssclass = 'CMSCustChosenDate';
			}
			
			Date pastDate = date.newInstance(1900, 1, 1);
			Integer dayOfWeekNum = math.mod(pastDate.daysBetween(theDate), 7);

			DateTime dtValue = datetime.newInstance(theDate.year(), theDate.month(), theDate.day());
			String dayString = dtValue.format('EEEE');

			if(!branch.Branch_Open_Days__c.containsIgnoreCase(dayString)){
				isActive = false;
				cssclass = 'CMSCustCalInactiveDay';
			}else if(holidays.containsKey(theDate)){	
				isActive = false;
				cssclass = 'CMSCustCalHolidayDay';
			}else{
				isActive = true;
			}

			/*if(dayOfWeekNum == 6){ //sets day to active or not
				isActive = false;
				cssclass = 'CMSCustCalInactiveDay';
			}else if(holidays.containsKey(theDate)){	
				isActive = false;
				cssclass = 'CMSCustCalHolidayDay';
			}else{
				isActive = true;
			}*/
		}
	}
	
	public static Integer convertMonthToInt(String inMonth) {
        Integer i = 0;

        if(inMonth == 'Jan' || inMonth == 'January')
            i = 01;
        else if(inMonth == 'Feb' || inMonth == 'February')
            i = 02;
        else if(inMonth == 'Mar' || inMonth == 'March')
            i = 03;
        else if(inMonth == 'Apr' || inMonth == 'April')
            i = 04;
        else if(inMonth == 'May')
            i = 05;
        else if(inMonth == 'Jun' || inMonth == 'June')
            i = 06;
        else if(inMonth == 'Jul' || inMonth == 'July')
            i = 07;
        else if(inMonth == 'Aug' || inMonth == 'August')
            i = 08;
        else if(inMonth == 'Sep' || inMonth == 'September')
            i = 09;
        else if(inMonth == 'Oct' || inMonth == 'October')
            i = 10;
        else if(inMonth == 'Nov' || inMonth == 'November')
            i = 11;
        else if(inMonth == 'Dec' || inMonth == 'December')
            i = 12;
        
        return i;
    }
	
/*	static testMethod void testMe() {
		Month m = new Month( Date.newInstance(2007,11,1) );
		system.assert(m!=null);	
		List<Week> l = m.getWeeks(); 
		repeatcon r = new repeatcon(); 
		system.debug(m.getMonthName());
		Month mm = r.getMonth();
		//system.debug(mm); 
		system.debug(m.getFirstDate());
		system.debug(m.getWeekdayNames());
		for(Week w:r.getWeeks()) { 
			for(Day c:w.days) {   
				if (c.eventsToday.size() > 0 ) { 
					String ss = String.valueOf(c.eventsToday[0].ev.ActivityDate);
					ss = c.eventsToday[0].ev.ActivityDateTime.format('MMMM a');
					//system.debug(ss);
					//system.debug(c.eventsToday[0].ev);
				} 
			} 
		} 
	}*/
}