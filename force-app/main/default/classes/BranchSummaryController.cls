public with sharing class BranchSummaryController extends CMSBaseController {

	public BranchSummaryController() {
		
	}
	
	public List<Holiday> upcomingHolidaysList {
		get {
			if (upcomingHolidaysList == null) {
				upcomingHolidaysList = [
					SELECT StartTimeInMinutes, RecurrenceType, RecurrenceStartDate, RecurrenceMonthOfYear, RecurrenceInterval, 
						RecurrenceInstance, RecurrenceEndDateOnly, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, Name, IsRecurrence, 
						IsAllDay, EndTimeInMinutes, Description, ActivityDate 
					FROM Holiday
					WHERE (ActivityDate >= :Date.today() AND (ActivityDate = THIS_MONTH OR ActivityDate = NEXT_MONTH))
						OR (IsRecurrence = true AND RecurrenceType = 'RecursYearly' AND RecurrenceStartDate <= :Date.today() 
							AND (RecurrenceEndDateOnly >= :Date.today() OR RecurrenceEndDateOnly = null))
					ORDER BY ActivityDate ASC
				];
			}
			
			return upcomingHolidaysList;
		}
		private set;
	}
	
	public List<HolidayWrapper> upcomingHolidays {
		get {
			if (upcomingHolidays == null) {
				
				upcomingHolidays = new list<HolidayWrapper>();
				date todayDate = date.today();
				integer thisYear = todayDate.year();
				
				for(Holiday hol : upcomingHolidaysList){
					
					if(hol.IsRecurrence){
						
						integer calMonth = CMSCustomCalendarMonth.convertMonthToInt(hol.RecurrenceMonthOfYear);
						
						if(calMonth < date.today().month()){
							thisYear = thisYear + 1;
						}
						
						date holidayDayDate = date.newinstance(thisYear, calMonth, hol.RecurrenceDayOfMonth);
						if(holidayDayDate.month() == date.today().month() || holidayDayDate.month() == date.today().addMonths(1).month()){
							upcomingHolidays.add(new HolidayWrapper(holidayDayDate, hol));
						}

					}else{
						upcomingHolidays.add(new HolidayWrapper(hol.ActivityDate, hol));
					}
				}
			}
			
			upcomingHolidays.sort();
			
			system.debug('*** -- upcomingHolidays ' + upcomingHolidays);
			return upcomingHolidays;
		}
		private set;
	}
	
	public List<Cash_Order__c> recentCashOrders {
		get {
			if (recentCashOrders == null) {
				recentCashOrders = [
					SELECT Name, Delivery_Date__c, Order_Date__c, Total_Cash_Amount__c, Status__c, RecordType.Name
					FROM Cash_Order__c
					WHERE Branch__c = :selectedBranch.Id
						AND Delivery_Date__c >= :Date.today().addDays(-28)
					ORDER BY Delivery_Date__c DESC 
				];
			}
			
			return recentCashOrders;
		}
		private set;
	}
	
	private List<Balance_Entry__c> recentBalanceEntries {
		get {
			if (recentBalanceEntries == null) {
				recentBalanceEntries = [
					SELECT Name, Balance__c, Branch__c, Date__c
					FROM Balance_Entry__c
					WHERE Branch__c = :selectedBranch.Id
						AND Date__c >= :Date.today().addDays(-7)
					ORDER BY Date__c DESC
				];
			}
			
			return recentBalanceEntries;
		}
		set;
	}
	
	public List<BalanceEntryLine> recentBalanceEntryLines {
		get {
			if (recentBalanceEntryLines == null) {
				recentBalanceEntryLines = new List<BalanceEntryLine>();
				
				for (Integer i = 0; i < 7; ++i) {
					Date balanceDate = Date.today().addDays(-i);
					Balance_Entry__c dateBalanceEntry = null;
					
					for (Balance_Entry__c balanceEntry : recentBalanceEntries) {
						if (balanceEntry.Date__c == balanceDate) {
							dateBalanceEntry = balanceEntry;
							break;
						}
					}
					
					BalanceEntryLine dateBalanceEntryLine = new BalanceEntryLine(balanceDate, dateBalanceEntry, selectedBranch);
					recentBalanceEntryLines.add(dateBalanceEntryLine);
				}
			}
			
			return recentBalanceEntryLines;
		}
		private set;
	}
	
	public class HolidayWrapper implements Comparable {
		public date theDate {get;set;}
		public Holiday holiday {get;set;}
		public string dateFormated {get;set;}
		
		public holidayWrapper(Date inDate, Holiday inHoliday){
			this.theDate = inDate;
			this.holiday = inHoliday;
			
			this.dateFormated = datetime.newInstance(theDate.year(), theDate.month(), theDate.day(), 00, 00, 00).format('dd/MM/yyyy');
		}
		
		public Integer compareTo(Object ObjToCompare) {
			return compareToDate(ObjToCompare);
        }
        

	    Integer compareToDate(Object objHoliday) {
	        Date otherDate = ((HolidayWrapper)objHoliday).theDate != null ?
	                                          ((HolidayWrapper)objHoliday).theDate : date.today();
	        
	        return otherDate.daysBetween(this.theDate);
	    }
	}
}