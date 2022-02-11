public without sharing class CMSCashOrderController extends CMSBaseController {
	
	public integer pageNum {get;set;}
	public string recordTypeId {get;set;}
	public list<SelectOption> recordTypeOptions {
		get{
			if(recordTypeOptions == null){
				recordTypeOptions = new list<SelectOption>();
								
				for(RecordType recType : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' ORDER BY Name DESC]){
					recordTypeOptions.add(new SelectOption(recType.Id, recType.Name));
				}

			}
			return recordTypeOptions;
		}
		set;
	}
	
	public RecordType cashRecType {get;set;}
	
	public Cash_Order__c cashOrder {
		get{
			if(cashOrder == null){
				cashOrder = new Cash_Order__c();
			}
			return cashOrder;
		}
		set;
	}
	
	public list<integer> currencySettingsOrdered {
		get{
			if(currencySettingsOrdered == null){
				currencySettingsOrdered = new list<integer>();
				
				currencySettings = CMSCashOrderCurrencySettings__c.getall();
				
				for(CMSCashOrderCurrencySettings__c value : currencySettings.values()){
					currencySettingsOrdered.add(integer.valueOf(value.Name));
				}
				
				currencySettingsOrdered.sort();
			}
			return currencySettingsOrdered;
		}
		set;
	}
	
	public map<string, CMSCashOrderCurrencySettings__c> currencySettings{
		get{
			if(currencySettings == null){
				currencySettings = CMSCashOrderCurrencySettings__c.getall();			
			}
			return currencySettings;
		}
		set;
	}
	
	public set<date> holidayDates{
		get{
			if(holidayDates == null){
				holidayDates = new set<date>();
					List<Holiday> upcomingHolidaysList = [SELECT StartTimeInMinutes, RecurrenceType, RecurrenceStartDate, RecurrenceMonthOfYear, RecurrenceInterval, 
														RecurrenceInstance, RecurrenceEndDateOnly, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, Name, IsRecurrence, 
														IsAllDay, EndTimeInMinutes, Description, ActivityDate 
													FROM Holiday
													WHERE ActivityDate >= :Date.today()
														OR (IsRecurrence = true AND RecurrenceType = 'RecursYearly' AND RecurrenceStartDate <= :Date.today() 
															AND (RecurrenceEndDateOnly >= :Date.today() OR RecurrenceEndDateOnly = null))
													ORDER BY ActivityDate ASC
												];
	
			
					for(Holiday hol : upcomingHolidaysList){
								
						if(hol.IsRecurrence){
							date holidayDayDate = date.newinstance(date.today().year(), CMSCustomCalendarMonth.convertMonthToInt(hol.RecurrenceMonthOfYear), hol.RecurrenceDayOfMonth);
							holidayDates.add(holidayDayDate);
			
						}else{
							holidayDates.add(hol.ActivityDate);
						}
					}
				
				system.debug('*** -- holidayDates ' + holidayDates);
			}
			return holidayDates;
		}
		set;
	}
	
	public decimal cashTotal {get;set;}
	public boolean showDiliveryChargeMsg {get;set;}
	
	//CONSTRUCTOR
	public CMSCashOrderController(ApexPages.StandardController stdController){
		this.cashOrder = (Cash_Order__c)stdController.getRecord();
		
		if(string.isBlank(cashOrder.RecordTypeId) && string.isBlank(cashOrder.Id)){
			pageNum = 1;
			recordTypeId = recordTypeOptions[0].getValue();
			this.cashOrder.Branch__c = selectedBranchID;
		}else{
			cashOrder = [SELECT Id, RecordTypeId, X1_Amount__c, X10_Amount__c, X2_Amount__c, X20_Amount__c, X5_Amount__c, X50_Amount__c, Num_Coin_Bags__c, X10p_Amount__c, X1p_Amount__c, X20p_Amount__c, X2p_Amount__c,
								X50p_Amount__c, X5p_Amount__c, Branch__c, Cash_Order_Approver__c, Comment__c, Delivery_Charge__c, Delivery_Date__c, Order_Date__c, Sell_Off_Amount__c, Status__c, Total_Cash_Amount__c
								FROM Cash_Order__c
								WHERE Id =: cashOrder.Id];
			
			recordTypeId = cashOrder.RecordTypeId;
			goToDetailPage();
								
			ApexPages.currentPage().getParameters().put('branchID', this.cashOrder.Branch__c);
		}
		
		this.cashOrder.Cash_Order_Approver__c = selectedBranch.Cash_Order_Approver__c;
		
		list<Holiday> holidayDays = [SELECT StartTimeInMinutes, RecurrenceType, RecurrenceStartDate, RecurrenceMonthOfYear, RecurrenceInterval, 
											RecurrenceInstance, RecurrenceEndDateOnly, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, Name, IsRecurrence, 
											IsAllDay, EndTimeInMinutes, Description, ActivityDate 
										FROM Holiday
										WHERE ActivityDate >= :Date.today()
										AND  ActivityDate <= :Date.today().addDays(7)];	
		
		calculateCashTotal();
		calculateDeliveryCharge();
	}
	
	public void goToDetailPage(){
		
		system.debug('*** -- recordTypeId : ' + recordTypeId);
		
		cashOrder.RecordTypeId = recordTypeId;
		cashRecType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Id =: cashOrder.RecordTypeId];
		
		Date nextDeliveryDate;
		
		//Sets the delivery date to 2 working days time
		if(cashRecType.Name == 'Standard Cash Order'){
			
			nextDeliveryDate = date.today().addDays(2);
			Date pastDate = date.newInstance(1900, 1, 1);
			
			while(holidayDates.contains(nextDeliveryDate)){
				nextDeliveryDate = nextDeliveryDate.addDays(1);
			}
			
			Integer dayOfWeekNum = math.mod(pastDate.daysBetween(nextDeliveryDate), 7);
			
			system.debug('*** -- dayOfWeekNum for delievery : ' + dayOfWeekNum);
			
			if(dayOfWeekNum == 6 || dayOfWeekNum == 5){ //if Saturday or Sunday add 2 more days
				nextDeliveryDate = nextDeliveryDate.addDays(2);
			}
			
		}else if(cashRecType.Name == 'Emergency Cash Order'){
			
			nextDeliveryDate = date.today().addDays(1);
			Date pastDate = date.newInstance(1900, 1, 1);
			
			while(holidayDates.contains(nextDeliveryDate)){
				nextDeliveryDate = nextDeliveryDate.addDays(1);
			}
			
			Integer dayOfWeekNum = math.mod(pastDate.daysBetween(nextDeliveryDate), 7);
			
			system.debug('*** -- dayOfWeekNum for delievery : ' + dayOfWeekNum);
			
			if(dayOfWeekNum == 5){ //if Saturday add 2 more days
				nextDeliveryDate = nextDeliveryDate.addDays(2);
			}else if(dayOfWeekNum == 6){ // if Sunday add 1 more days
				nextDeliveryDate = nextDeliveryDate.addDays(1);
			}
		}

		cashOrder.Delivery_Date__c = nextDeliveryDate;
		
		pageNum = 2;

	}

	
	public void calculateCashTotal(){
		
		cashTotal = 0;
		
		if(cashOrder.X50_Amount__c != null) cashTotal += cashOrder.X50_Amount__c;
		if(cashOrder.X20_Amount__c != null) cashTotal += cashOrder.X20_Amount__c;
		if(cashOrder.X10_Amount__c != null) cashTotal += cashOrder.X10_Amount__c;
		if(cashOrder.X5_Amount__c != null) cashTotal += cashOrder.X5_Amount__c;
		if(cashOrder.X2_Amount__c != null) cashTotal += cashOrder.X2_Amount__c;
		if(cashOrder.X1_Amount__c != null) cashTotal += cashOrder.X1_Amount__c;
		if(cashOrder.X50p_Amount__c != null) cashTotal += cashOrder.X50p_Amount__c;
		if(cashOrder.X20p_Amount__c != null) cashTotal += cashOrder.X20p_Amount__c;
		if(cashOrder.X10p_Amount__c != null) cashTotal += cashOrder.X10p_Amount__c;
		if(cashOrder.X5p_Amount__c != null) cashTotal += cashOrder.X5p_Amount__c;
		if(cashOrder.X2p_Amount__c != null) cashTotal += cashOrder.X2p_Amount__c;
		if(cashOrder.X1p_Amount__c != null) cashTotal += cashOrder.X1p_Amount__c;

	}
	
	public void validateAmounts(){
		
		for(CMSCashOrderCurrencySettings__c value : currencySettings.values()){
			
			Integer fieldValue = integer.valueOf(cashOrder.get(value.Cash_Order_API_Field_Label__c));
			
			if(fieldValue != null && fieldValue != 0 && fieldValue < value.Minimum_Value__c){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, value.Denomination__c + ' Denomination Amount does not meet minimum order of ' + value.Minimum_Value__c));
			}else if(fieldValue == null){
				cashOrder.put(value.Cash_Order_API_Field_Label__c, 0);
			}
		}
		
		if(cashOrder.Sell_Off_Amount__c == null) cashOrder.Sell_Off_Amount__c = 0;
		
		decimal remainCashOrderAmount = cashTotal - cashOrder.Sell_Off_Amount__c;
		
		
		Balance_Entry__c mostRecentBalanceEntry = new Balance_Entry__c();
		decimal dailyBalance = 0; 
		try{
			mostRecentBalanceEntry = [SELECT Name, Balance__c, Branch__c, Date__c
										FROM Balance_Entry__c
										WHERE Branch__c = :selectedBranch.Id
										ORDER BY Date__c DESC LIMIT 1
										];
			dailyBalance = mostRecentBalanceEntry.Balance__c;				
		}catch(exception e){}
		
		decimal totalAnticipatedCashOrder = remainCashOrderAmount + dailyBalance;
		
		if(totalAnticipatedCashOrder > selectedBranch.Branch_Limit__c){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Cash order amount is above branch limit'));
		}
			
	}
	
	public void calculateDeliveryCharge(){
		
		CMS_Delivery_Charge__c deliveryChargeSetting = CMS_Delivery_Charge__c.getValues('Default');
		
		decimal numCashOrderCharges = cashTotal / deliveryChargeSetting.Cash_Order_Amount_Range__c;
		numCashOrderCharges = numCashOrderCharges.round(roundingMode.UP);
		
		decimal cashOrderChargeValue =  deliveryChargeSetting.Cash_Order_Amount_Charge_Value__c * numCashOrderCharges;
		
		if(cashOrder.Sell_Off_Amount__c == null){
			cashOrder.Sell_Off_Amount__c = 0;
		}
		
		decimal numCollectionCharges = cashOrder.Sell_Off_Amount__c / deliveryChargeSetting.Collection_Amount_To_Range__c;
		numCollectionCharges = numCollectionCharges.round(roundingMode.UP);
		
		decimal CollectionChargeValue =  deliveryChargeSetting.Collection_Amount_Charge_Value__c * numCollectionCharges;
		
		if(cashOrder.Num_Coin_Bags__c == null){
			cashOrder.Num_Coin_Bags__c = 0;
		}
		decimal bagCollectionCharge = cashOrder.Num_Coin_Bags__c * deliveryChargeSetting.Coin_Bag_Charge__c;
		
		decimal bagOrderCharge = 0;
		integer noCoinBagOrders = 0; 
		for(CMSCashOrderCurrencySettings__c value : currencySettings.values()){
			
			object fieldValueObj = cashOrder.get(value.Cash_Order_API_Field_Label__c);
			
			string fieldValueStr;
			if(fieldValueObj != null){
				fieldValueStr = string.valueOf(fieldValueObj);
			}
			
			decimal fieldValue = 0;
			
			if(string.IsNotBlank(fieldValueStr)){
				fieldValue = decimal.valueOf(string.valueOf(fieldValueStr));
			}
			
			system.debug('*** -- fieldValue ' + fieldValue);
			system.debug('*** -- value.Has_Coin_Bag_Delivery_Charge__c ' + value.Has_Coin_Bag_Delivery_Charge__c);
			
			if(fieldValue != null && fieldValue != 0 && value.Has_Coin_Bag_Delivery_Charge__c){
				decimal orderCharge = fieldValue / value.Minimum_Value__c;
				
				system.debug('*** -- orderCharge ' + orderCharge);
				
				orderCharge = orderCharge.round(roundingMode.UP);
				
				system.debug('*** -- orderCharge rounded ' + orderCharge);
				
				noCoinBagOrders += integer.valueOf(orderCharge);
				
				system.debug('*** -- NoCoinBagOrders Total ' + NoCoinBagOrders);
			}
		}
		
		bagOrderCharge = noCoinBagOrders * deliveryChargeSetting.Coin_Bag_Charge__c;
		system.debug('*** -- bagOrderCharge ' + bagOrderCharge);
		
		cashOrder.Delivery_Charge__c = cashOrderChargeValue + CollectionChargeValue + bagCollectionCharge + bagOrderCharge;
		
		
		decimal cashOrderGrandTotalIncSellOff = cashTotal + cashOrder.Sell_Off_Amount__c;
		
		// Checks to make sure total is divisible by range value if not info message displayed
		if(math.mod(cashOrderGrandTotalIncSellOff.longValue(), deliveryChargeSetting.Cash_Order_Amount_Range__c.longValue()) != 0){ 
		    showDiliveryChargeMsg = true;
		}else{
			showDiliveryChargeMsg = false;
		}

	}
	
	
	public void next(){
		
		validateAmounts();
		
		if(cashOrder.Delivery_Date__c <= date.today()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Delivery Date cannot be today, in the past or a holiday date.  Please select another date.'));
		}
		
		if(ApexPages.hasMessages()){
			return;
		}
		
		//Sets the delivery charge
		if(cashTotal > 0){
			calculateDeliveryCharge();
		}else{
			cashOrder.Delivery_Charge__c = 0;
		}
		
		pageNum = 3;
	}
	
	public void amend(){
		pageNum = 2;
	}
	
	public PageReference save(){

		cashOrder.Order_Date__c = date.today();
		
		if(string.IsBlank(cashOrder.Id)){
			
			Date pastDate = date.newInstance(1900, 1, 1);
			Integer dayOfWeekNum = math.mod(pastDate.daysBetween(date.today()), 7);
			
			Date weekStart = date.today().addDays(-dayOfWeekNum);
			weekStart = weekStart.addDays(7);
			
			system.debug('*** -- weekStart ' + weekStart);
			
			//datetime weekStartTime = datetime.newinstance(weekStart.year(), weekStart.month(), weekStart.day(), 00, 00, 00);
			//datetime weekStartEnd = datetime.newinstance(weekStart.year(), weekStart.month(), weekStart.day(), 23, 59, 59);
			
			//Get Royal Mail Order Record for the week
			Royal_Mail_Cash_Order_Request__c rmOrder = new Royal_Mail_Cash_Order_Request__c();
			
			if(cashRecType.Name == 'Standard Cash Order'){				
				try{
					rmOrder = [SELECT Id
									FROM Royal_Mail_Cash_Order_Request__c
									WHERE
										Status__c = 'New' 
										AND Type__c = 'Standard Cash Order' 
										AND(Delivery_Week__c =: weekStart OR (Delivery_Week__c = TODAY AND CreatedDate != TODAY))
										ORDER BY CreatedDate DESC
										LIMIT 1];
				}catch(exception e){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Royal Mail Order Record Available (Order may have already been sent)'));
					return null;
				}
				
			}else if(cashRecType.Name == 'Emergency Cash Order'){
				rmOrder.Type__c = 'Emergency Cash Order';
				rmOrder.Delivery_Week__c = cashOrder.Delivery_Date__c;
				insert rmOrder;
			}
			
			cashOrder.Royal_Mail_Cash_Order_Request__c = rmOrder.Id;
			try{
				insert cashOrder;
			}catch(exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
				return null;
			}
		}else{
			try{
				update cashOrder;
			}catch(exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
				return null;
			}
		}
		
		// Create an approval request
		Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
		approvalReq.setObjectId(cashOrder.id);
		
		// Submit the approval request
		Approval.ProcessResult approvalResult = Approval.process(approvalReq);
		
		PageReference branchSummary = Page.BranchSummary;
		branchSummary.getParameters().put('branchID', selectedBranchID);
		
		return branchSummary;
	}
	
	public PageReference cancel(){
	
		PageReference branchSummary = Page.BranchSummary;
		branchSummary.getParameters().put('branchID', selectedBranchID);
		
		return branchSummary;
	}
	
	
}