global class Teller_Reporting
{
	global class ActivityDetails
	{
		Public String Name {Get;Set;}
		public String PrintedReciept {Get;Set;}
		Public List<object> Details {Get;Set;}
		Public Map<String, List<object>> AdditionalInfo {Get;Set;}
		Public Teller_Function_Overrides.ApprovalDisplayFlags DisplayFlags {Get;Set;}
		
		Public ActivityDetails()
		{
			Details = new List<object>();
			AdditionalInfo = new Map<String, List<object>>();
			DisplayFlags = new Teller_Function_Overrides.ApprovalDisplayFlags();
		}
	}
	
	global class ActivityDetail
	{
		Public String Label {Get;Set;}
		Public String Name {Get;Set;}
		Public Object Value {Get;Set;}
		Public Object Type {Get; Set;}
		public String SfdcUrl {Get;Set;}
	}	
	
	global class TellerActivtyFilterLists
	{
		List<SearchCriteria> Favourites {Get;Set;}
		List<Branch__c> Branches {Get;Set;}
		List<String> Currencies {Get;Set;}
		List<Teller_Depository__c> Tills {Get;Set;}
		List<String> Status {Get;Set;}
		List<Teller_Function__c> TransactionTypes {Get;Set;}
		List<User> Tellers {Get;Set;}
		
		public TellerActivtyFilterLists()
		{
			Branches = new List<Branch__c>();
			Tills = new List<Teller_Depository__c>();
			TransactionTypes = new List<Teller_Function__c>();
			Currencies = new List<String>();
			Status = new List<String>();
		}		
	}
	
	global class SearchCriteria
    {
		public String Id;
		public String SearchName;
		
		//Sort
		Public Boolean OrderDescending {Get;Set;}
		Public String OrderByFieldName {Get;Set;}
		
		//Filter
		Public String Branch_Number {Get; Set;}
		Public String From_Activity_Amount {Get; Set;}
		Public String To_Activity_Amount {Get; Set;}
		Public String Activity_Currency {Get; Set;}
		Public String Description {Get; Set;}
		Public String Status {Get; Set;}
		Public String Activity_Type {Get; Set;}
		Public String Created_By_User_Id {Get; Set;}
        Public String To_Activity_Date_Time {Get;Set;}
		Public String From_Activity_Date_Time {Get;Set;}	
		Public String Till_Name {Get; Set;}
		Public String Credit_Account {Get; Set;}
		Public String Debit_Account {Get; Set;}
		Public String Transaction_Type {Get; Set;}
		Public String DML_Operation {Get;Set;}
		
		//Paging
		Public Integer PageSize {Get;Set;}
		Public Integer PageOffset {Get;Set;}
		
        public SearchCriteria()
        {			
            PageSize = 0;   
			PageOffset = 0;			
			OrderDescending = false;
			OrderByFieldName = '';
			
			Activity_Currency = '';
        }       
    }   
	
	global static SearchCriteria InitialiseSearchCriteria(Integer pSize, Integer pOffset)
	{
		SearchCriteria result =  new SearchCriteria();
		
		result.PageSize = pSize;
		result.PageOffset = pOffset;
		result.OrderDescending = true;
		result.OrderByFieldName = 'Activity_Date_Time__c';
		
		result.Branch_Number = '';
		result.From_Activity_Amount = '';
		result.To_Activity_Amount = '';
		result.Activity_Currency = '';
		result.Description = '';
		result.Status = '';
		result.Activity_Type = '';
		result.Created_By_User_Id = '';
        result.To_Activity_Date_Time = '';
		result.From_Activity_Date_Time = '';
		result.Till_Name = '';
		result.Credit_Account = '';
		result.Debit_Account = '';
		result.Transaction_Type = '';
		result.DML_Operation = '';
				
		return result;
	}
	
	private static SearchCriteria EscapeSearchCriteria(SearchCriteria searchCriteria)
	{
		searchCriteria.Branch_Number = EscapeString(searchCriteria.Branch_Number);
		searchCriteria.From_Activity_Amount = EscapeString(searchCriteria.From_Activity_Amount);
		searchCriteria.To_Activity_Amount = EscapeString(searchCriteria.To_Activity_Amount);
		searchCriteria.Activity_Currency = EscapeString(searchCriteria.Activity_Currency);
		searchCriteria.Description = EscapeString(searchCriteria.Description);
		searchCriteria.Status = EscapeString(searchCriteria.Status);
		searchCriteria.Activity_Type = EscapeString(searchCriteria.Activity_Type);
		searchCriteria.Created_By_User_Id = EscapeString(searchCriteria.Created_By_User_Id);
        searchCriteria.To_Activity_Date_Time = EscapeString(searchCriteria.To_Activity_Date_Time);
		searchCriteria.From_Activity_Date_Time = EscapeString(searchCriteria.From_Activity_Date_Time);
		searchCriteria.Till_Name = EscapeString(searchCriteria.Till_Name);
		searchCriteria.Credit_Account = EscapeString(searchCriteria.Credit_Account);
		searchCriteria.Debit_Account = EscapeString(searchCriteria.Debit_Account);
		searchCriteria.Transaction_Type = EscapeString(searchCriteria.Transaction_Type);
		searchCriteria.DML_Operation = EscapeString(searchCriteria.DML_Operation);
		
		return searchCriteria;
	}
	
	private static String EscapeString(String item)
	{
		if(item != null)
			return String.escapeSingleQuotes(item);
		return item;
	}
	
	global static TellerActivtyFilterLists InitialiseFilterLists()
	{
		TellerActivtyFilterLists lists = new TellerActivtyFilterLists();
		lists.Branches = [SELECT Name, Branch_Number__c FROM Branch__c];
		lists.Tills = [SELECT Name FROM Teller_Depository__c WHERE storage_type__c = 'Till'];

		List<Teller_Filters__c> currencyList = [SELECT Value__c FROM Teller_Filters__c WHERE Name__c = 'Currency' AND Type__c = 'Activity Audit'];
		if(currencyList.size() > 0)
		{
			currencyList[0].Value__c = currencyList[0].Value__c.replaceAll(' ', '');
			lists.Currencies = currencyList[0].Value__c.split(',');
		}
		
		List<Teller_Filters__c> statusList = [SELECT Value__c FROM Teller_Filters__c WHERE Name__c = 'Status' AND Type__c = 'Activity Audit'];
		if(statusList.size() > 0)
		{
			//statusList[0].Value__c = statusList[0].Value__c.replaceAll(' ', '');
			List<String> statuses = statusList[0].Value__c.split(',');
			lists.Status = new List<String>();
			for(String s : statuses)
			{
				lists.Status.add(s.trim());
			}
		}
		
		lists.Tellers = [SELECT Id, Name FROM User WHERE Teller_Branch_Number__c != null];		
		lists.TransactionTypes = [SELECT Id, Name FROM Teller_Function__c WHERE Teller_Group__r.Name = 'Teller Transactions'];
		
		lists.Favourites = GetFavoriteSearches();
		
		return lists;		
	}
		
	global static List<Teller_Activity_Audit__c> GetTellerActivityAudit(SearchCriteria searchCriteria)
	{
		String soql = 'SELECT Activity_Amount__c, Activity_Blob__c, Activity_Currency__c, Activity_Date_Time__c, Activity_Description__c, Activity_Type__c, Branch_Number__c, Till_Name__c, Debit_Account__c, Credit_Account__c,' + 
		              'Created_By_User__c, Created_By_User__r.Name, DML_Operation__c, Object_Id__c, Status__c FROM Teller_Activity_Audit__c ';
				
		if(searchCriteria != null)
		{
			searchCriteria = EscapeSearchCriteria(searchCriteria);
			
			//Filters
			List<String> WhereClauses = new List<String>();		
			
			if(!String.isEmpty(searchCriteria.To_Activity_Date_Time))
			{
				Datetime toDateTime = Datetime.parse(searchCriteria.To_Activity_Date_Time);
				WhereClauses.add('Activity_Date_Time__c <= ' + toDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ');
			}
			
			if(!String.isEmpty(searchCriteria.From_Activity_Date_Time))
			{
				Datetime fromDateTime = Datetime.parse(searchCriteria.From_Activity_Date_Time);
				WhereClauses.add('Activity_Date_Time__c >= '+ fromDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ');
			}

			if(!String.isEmpty(searchCriteria.Created_By_User_Id))
			{		
				WhereClauses.add('Created_By_User__c = \''+ searchCriteria.Created_By_User_Id + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.Activity_Currency))
			{		
				WhereClauses.add('Activity_Currency__c = \''+ searchCriteria.Activity_Currency + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.From_Activity_Amount))
			{
				WhereClauses.add('Activity_Amount__c >= ' + searchCriteria.From_Activity_Amount + ' ');
			}
			
			if(!String.isEmpty(searchCriteria.To_Activity_Amount))
			{
				WhereClauses.add('Activity_Amount__c <= ' + searchCriteria.To_Activity_Amount + ' ');
			}
			
			if(!String.isEmpty(searchCriteria.Description))
			{
				WhereClauses.add('(Activity_Description__c like \'%'+  searchCriteria.Description + '%\' )');
			}
			
			if(!String.isEmpty(searchCriteria.Activity_Type))
			{
				WhereClauses.add('Activity_Type__c = \'' + searchCriteria.Activity_Type + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.Status))
			{
				WhereClauses.add('Status__c = \'' + searchCriteria.Status + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.DML_Operation))
			{
				WhereClauses.add('DML_Operation__c = \'' + searchCriteria.DML_Operation + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.Branch_Number))
			{
				WhereClauses.add('Branch_Number__c = \'' + searchCriteria.Branch_Number + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.Till_Name))
			{
				WhereClauses.add('Till_Name__c = \'' + searchCriteria.Till_Name + '\' ');
			}		
			
			if(!String.isEmpty(searchCriteria.Credit_Account))
			{
				WhereClauses.add('Credit_Account__c = \'' + searchCriteria.Credit_Account + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.Debit_Account))
			{
				WhereClauses.add('Debit_Account__c = \'' + searchCriteria.Debit_Account + '\' ');
			}
			
			if(!String.isEmpty(searchCriteria.Transaction_Type))
			{
				WhereClauses.add('(Activity_Description__c like \'%'+  searchCriteria.Transaction_Type + '%\' )');
			}
			
			if(WhereClauses.size() > 0)
			{
				soql += 'WHERE ';		
				for (Integer i = 0; i < WhereClauses.size(); i++) 
				{
	    			soql += WhereClauses[i];
					if(WhereClauses.size() > (i + 1))
					{
						soql += ' AND ';
					}
				}
			}
			
			if(!String.isEmpty(searchCriteria.OrderByFieldName))
			{
				soql += 'ORDER BY ' + searchCriteria.OrderByFieldName;
				if(searchCriteria.OrderDescending)
				{
					soql += ' DESC ';
				}
			}
			
			if(searchCriteria.PageSize != null)
			{
				soql += ' LIMIT ' + searchCriteria.PageSize;
			}
			
			if(searchCriteria.PageOffset != null)
			{
				soql += ' OFFSET ' + searchCriteria.PageOffset;
			}
		}
		
		System.debug(searchCriteria);
		System.debug(soql);
		List<Teller_Activity_Audit__c> result = Database.query(soql);
		System.debug(result.size());
		return result;
	}
	
	global static List<Teller_Activity_Audit__c> GetCurrentTellerActivityForToday()
	{
		SearchCriteria criteria = InitialiseSearchCriteria(null, null);
		
		Datetime today = Datetime.now();		
		criteria.From_Activity_Date_Time = today.format('dd/MM/yyyy') + ' 00:00';
		criteria.To_Activity_Date_Time = today.format('dd/MM/yyyy') + ' 23:59';
		criteria.Created_By_User_Id = UserInfo.getUserId();
		criteria.PageSize = null;
		criteria.PageOffset = null;	
		criteria.OrderDescending = false;
		return GetTellerActivityAudit(criteria);
	}
		
	global static Map<String, ActivityDetail> GenerateActivityDetail(String objectName, SObject data, Type dataType)
	{
		Map<String, ActivityDetail> details = new Map<String, ActivityDetail>();
			
		Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType sobjType = gd.get(objectName); 
		Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
		Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
		List<Schema.SObjectField> fieldsMapValues = fieldsMap.values();
		
		for(Schema.SObjectField s : fieldsMapValues)
		{
			Boolean skipItem = false;
			ActivityDetail item = new ActivityDetail();
			item.Label = s.getDescribe().getLabel();
			item.Name = s.getDescribe().getName();
			item.Type = s.getDescribe().getType();
			
			try
			{
				if(objectName == 'Teller_Transaction__c')
				{
					if(item.Name == 'Printed_HTML_Reciept__c')
					{
						skipItem = true;
					}
				}
				
				if(string.valueOf(s.getDescribe().getType()) == 'REFERENCE')
				{			
					if(objectName == 'Teller_Transaction__c')
					{
						if(item.Name == 'Teller_Function__c')
						{
							item.Name = 'Teller_Function__r.Name';
							item.Value = ((Teller_Transaction__c)data).Teller_Function__r.Name;
							
							ActivityDetail ai = new ActivityDetail();
							ai.Label = s.getDescribe().getLabel() + ' Id';
							ai.Name = s.getDescribe().getName();
							ai.Type = s.getDescribe().getType();
							ai.Value = ((Teller_Transaction__c)data).Teller_Function__r.Id;		
							details.put(ai.Name, ai);
						}
						else if(item.Name == 'Branch__c')
						{
							item.Value = ((Teller_Transaction__c)data).Branch__r.Name;
						}
						else if(item.Name == 'Teller_Depository__c')
						{
							item.Value = ((Teller_Transaction__c)data).Teller_Depository__r.Name;
						}
						else if(item.Name == 'Cancellation_Teller_Depository__c')
						{
							item.Value = ((Teller_Transaction__c)data).Cancellation_Teller_Depository__r.Name;
						}
						else if(item.Name == 'Cancelled_By__c')
						{
							item.Value = ((Teller_Transaction__c)data).Cancelled_By__r.Name;
						}
						else if(item.Name == 'CreatedById')
						{
							item.Label = 'Created By';
							item.Value = ((Teller_Transaction__c)data).CreatedBy.Name;
						}
						else if(item.Name == 'Credit_Account_with_IBB__c')
						{
							item.Value = ((Teller_Transaction__c)data).Credit_Account_with_IBB__r.Name;
						}
						else if(item.Name == 'Debit_Account_with_IBB__c')
						{
							item.Value = ((Teller_Transaction__c)data).Debit_Account_with_IBB__r.Name;
						}
						else if(item.Name == 'From_Depository__c')
						{
							item.Value = ((Teller_Transaction__c)data).From_Depository__r.Name;
						}
						else if(item.Name == 'To_Depository__c')
						{
							item.Value = ((Teller_Transaction__c)data).To_Depository__r.Name;
						}
						else
						{		
							item.Value = data.get(item.Name);
						}						
					}			
					
					else if(objectName == 'Teller_Depository_Action__c')
					{
						if(item.Name == 'First_Authorisor__c')
						{
							item.Value = ((Teller_Depository_Action__c)data).First_Authorisor__r.Name;
						}
						else if(item.Name == 'Second_Authorisor__c')
						{
							item.Value = ((Teller_Depository_Action__c)data).Second_Authorisor__r.Name;
						}
						else if(item.Name == 'Teller_Depository__c')
						{
							item.Value = ((Teller_Depository_Action__c)data).Teller_Depository__r.Name;
						}	
						else if(item.Name == 'CreatedById')
						{
							item.Label = 'Created By';
							item.Value = ((Teller_Depository_Action__c)data).CreatedBy.Name;
						}
						else
						{
							item.Value = data.get(item.Name);
						}						
					}
					
					else if(objectName == 'Customer_Image__c')
					{
						if(item.Name == 'Account__c')
						{
							item.Value = ((Customer_Image__c)data).Account__r.Name;
						}
						else if(item.Name == 'Added_By__c')
						{
							item.Value = ((Customer_Image__c)data).Added_By__r.Name;
						}	
						else if(item.Name == 'Approved_By__c')
						{
							item.Value = ((Customer_Image__c)data).Approved_By__r.Name;
						}	
						else if(item.Name == 'CreatedById')
						{
							item.Label = 'Created By';
							item.Value = ((Customer_Image__c)data).CreatedBy.Name;
						}
						else
						{
							item.Value = data.get(item.Name);
						}						
					}
					
					else if(objectName == 'Teller_Transaction_Override__c')
					{
						if(item.Name == 'Override_User__c')
						{
							item.Value = ((Teller_Transaction_Override__c)data).Override_User__r.Name;
						}
					}
														
					else
					{
						item.Value = data.get(item.Name);
					}
					
				}
				else
				{
					item.Value = data.get(item.Name);
				}
			}
			catch(Exception e)
			{}
						
			if(skipItem == false)
				details.put(item.Name, item);
		}
		
		return details;
	}
	
	private static Map<Integer, ActivityDetail> CustomSortActivityItem(Map<String, ActivityDetail> ActivityItem)
	{
		Map<Integer, ActivityDetail> result = new  Map<Integer, ActivityDetail>();
		
		result.put(0, ActivityItem.get('Debit_Account_Currency__c'));
		ActivityItem.remove('Debit_Account_Currency__c');		
		result.put(1, ActivityItem.get('Debit_Account_No__c'));
		ActivityItem.remove('Debit_Account_No__c');		
		result.put(2, ActivityItem.get('Beneficiary_Sort_Code__c'));
		ActivityItem.remove('Beneficiary_Sort_Code__c');
		result.put(3, ActivityItem.get('Beneficiary_Account_No__c'));
		ActivityItem.remove('Beneficiary_Account_No__c');
		result.put(4, ActivityItem.get('Payment_Purpose__c'));
		ActivityItem.remove('Payment_Purpose__c');
		result.put(5, ActivityItem.get('Transaction_Amount__c'));
		ActivityItem.remove('Transaction_Amount__c');		
		result.put(7, ActivityItem.get('CreatedDate'));
		ActivityItem.remove('CreatedDate');		
		result.put(8, ActivityItem.get('Response_Reference__c'));
		ActivityItem.remove('Response_Reference__c');
		
		System.debug(result);
		
		Integer index = 9;
		for(ActivityDetail item : ActivityItem.values())
		{
			result.put(index, item);
			index++;
		}
		
		return result;
	}
	
	global static ActivityDetails GetActivityItem(String activityType, String referenceId)
	{
		ActivityDetails result = new ActivityDetails();
		System.debug(activityType + ' ' + referenceId);		
		
		if(activityType == 'Transaction')
		{
			result.Name = activityType;
			List<Teller_Transaction__c> query = [SELECT Id, Amount_Type__c, Authenticated__c, Authenticated_Date_Time__c, Beneficiary_Account_No__c, Beneficiary_Detail_Lines__c, Beneficiary_Sort_Code__c, Branch__c, Branch__r.Name,
							  Cancellation_Teller_Depository__c, Cancellation_Teller_Depository__r.Name, Cancelled_By__c, Cancelled_By__r.Name, Cancelled_Date__c,  Charge_Amount__c, Charge_Code__c, Cheque_Serial_No__c, Cheque_Type__c, CreatedById, CreatedDate,
							  Credit_Account_Currency__c, Credit_Account_No__c, Credit_Account_with_IBB__c, Credit_Account_with_IBB__r.Name, Credit_System_Parameter__c, Debit_Account_Currency__c, Debit_Account_No__c,
							  Debit_Account_with_IBB__c, Debit_Account_with_IBB__r.Name, Debit_System_Parameter__c, From_Depository__c, From_Depository__r.Name, Issuing_Bank__c, Narrative_Lines__c, No_Of_Cheques__c, Payment_Purpose__c, 
							  Payment_Type__c, Response_Reference__c, Teller_Depository__c, Teller_Depository__r.Name, Teller_Function__c, Teller_Function__r.Name, Template_Id__c, To_Depository__c, To_Depository__r.Name, Transaction_Amount__c, Transaction_Reference__c,
							  Transaction_Status__c, Transfer_Due_Date__c, Printed_HTML_Reciept__c, Transaction_Status_Description__c, Credit_Amount__c, Debit_Amount__c, Deposit_Currency__c, Exchange_Amount__c, Exchange_Rate__c,
							  Remainder_Amount__c, Remainder_Currency__c, Remainder_Exchange_Rate__c, Teller_Transfer_Currency__c, Time_taken_for_transaction_minutes__c, Transaction_Currency__c, Withdrawal_Currency__c  FROM Teller_Transaction__c WHERE Id = :referenceId];
			
			System.debug(query);
			
			if(query != null && !query.isEmpty())
			{
				Map<String, ActivityDetail> raw = GenerateActivityDetail('Teller_Transaction__c', query[0], Teller_Transaction__c.class);
								System.debug('result: ' + raw);
				Map<Integer, ActivityDetail> details = CustomSortActivityItem(raw);	
				result.Details = details.values();
				result.PrintedReciept = query[0].Printed_HTML_Reciept__c;
			}
			
			//Denominations
			List<Teller_Transaction_Denomination__c> denominations = [select CreatedById, CreatedBy.Name, Name, Depository_Updated__c, Direction__c, Number_of_Denomination__c, Teller_Transaction__c, Total_Value_of_Denomination__c, Value_of_Denomination__c FROM Teller_Transaction_Denomination__c WHERE Teller_Transaction__c = :referenceId];
			if(denominations != null && !denominations.isEmpty())
			{
				List<ActivityDetail> denomList = new List<ActivityDetail>();
				Decimal total = 0;
				for(Teller_Transaction_Denomination__c denom :  denominations)
				{
					ActivityDetail item = new ActivityDetail();
					item.Name = String.valueOf(denom.Value_of_Denomination__c);
					item.Label = 'Denomination: ' + denom.Value_of_Denomination__c;
					item.Value = denom.Number_of_Denomination__c;
					total += denom.Total_Value_of_Denomination__c;
					denomList.add(item);
				}
				
				ActivityDetail item = new ActivityDetail();
				item.Name = '0';
				item.Label = 'Total';
				item.Value = total;
				denomList.add(item);			

				result.AdditionalInfo.put('Denominations', denomList);
			}
			else
			{
				result.AdditionalInfo.put('Denominations', new List<String>());
			}
			
			//Overrides
			List<Teller_Transaction_Override__c> overrides = [select Id, Authorisor_Type__c, Case__c, Limit_Applied__c, Override_Type__c, Override_User__c, Override_User__r.Name, Status__c, Teller_Transaction__c FROM Teller_Transaction_Override__c WHERE Teller_Transaction__c = :referenceId];
			if(overrides != null && !overrides.isEmpty())
			{
				List<ActivityDetail> ovrList = new List<ActivityDetail>();				
				for(Teller_Transaction_Override__c ovr :  overrides)
				{
					Map<String, ActivityDetail> ovrdetails = GenerateActivityDetail('Teller_Transaction_Override__c', ovr, Teller_Transaction_Override__c.class);		
					ActivityDetail item = new ActivityDetail();
					item.Name = ovr.Id;
					item.Label = 'Override';
					item.Value = ovrdetails.values();
					ovrList.add(item);
				}

				result.AdditionalInfo.put('Overrides', ovrList);
			}
			else
			{
				result.AdditionalInfo.put('Overrides', new List<String>());
			}
			
			
			//Signatories
			List<Teller_Transaction_Signatory__c> signatories = [select Id, CreatedById, CreatedBy.Name, Name, Account_Holder__c, Account_Holder__r.Id, Account_Holder__r.Prospect_Customer__c, Account_Holder__r.Prospect_Customer__r.Name, Photo_Image_URL__c, Signature_Image_URL__c, Teller_Transaction__c from Teller_Transaction_Signatory__c where Teller_Transaction__c = :referenceId];
			if(signatories != null && !signatories.isEmpty())
			{				 
				List<ActivityDetail> sigList = new List<ActivityDetail>();
				for(Teller_Transaction_Signatory__c sig :  signatories)
				{
					ActivityDetail item = new ActivityDetail();
					item.Name = sig.Id;
					item.Label = 'Signatory';
					item.Value = sig;						
					System.debug('signatory: ' + sig);
					String customerId = sig.Account_Holder__r.Prospect_Customer__c;
					System.debug('prospect: ' + customerId);
					if(customerId == null)
					{
						customerId = sig.Account_Holder__r.Id;
						System.debug('acc holder: ' + customerId);
					}
					
					if(customerId != null && customerId.length() >= 15)
					{
						item.SfdcUrl = 'https://' + System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/' + customerId + '?nooverride=1&isdtp=vw#' + customerId.substring(0,15) + '_RelatedHistoryList_target';
					}
										
					System.debug(item);
					sigList.add(item);
				}

				result.AdditionalInfo.put('Signatories', sigList);
			}
			else
			{
				result.AdditionalInfo.put('Signatories', new List<String>());
			}
			
			result.DisplayFlags = Teller_Function_Overrides.GetApprovalDisplayFlags(referenceId);
		}
		
		if(activityType == 'Depository')
		{
			result.Name = activityType;
			List<Teller_Depository_Action__c> query = [SELECT Id, Name, First_Authorisor__c, First_Authorisor__r.Name, Second_Authorisor__c, Second_Authorisor__r.Name, Denominations__c, Function_Name__c, Status__C, Status_Description__c, Teller_Depository__c, Teller_Depository__r.Name, CreatedDate, CreatedBy.Name FROM Teller_Depository_Action__c WHERE Id = :referenceId];			
			System.debug(query);
			
			if(query != null && !query.isEmpty())
			{
				Map<String, ActivityDetail> details = GenerateActivityDetail('Teller_Depository_Action__c', query[0], Teller_Depository_Action__c.class);
				result.Details = details.values();
			}
		}
		
		if(activityType == 'Mandate')
		{
			System.debug(activityType);
			result.Name = activityType;
			List<Account_Mandate__c> query = [SELECT Id, Name, Account_with_IBB__c, Account_with_IBB__r.Name, Added_Date__c, Currency__c, Limit__c, CreatedDate, CreatedBy.Name FROM Account_Mandate__c WHERE Id = :referenceId];			
			System.debug(query);
			if(query != null && !query.isEmpty())
			{
				Map<String, ActivityDetail> details = GenerateActivityDetail('Account_Mandate__c', query[0], Account_Mandate__c.class);
				result.Details = details.values();
			}
		}
		
		if(activityType == 'Mandate Item')
		{
			result.Name = activityType;
			List<Teller_Depository_Action__c> query = [SELECT Id, Name, Authorisor__c, Authorisor__r.Name, Denominations__c, Function_Name__c, Status__C, Status_Description__c, Teller_Depository__c, Teller_Depository__r.Name, CreatedDate, CreatedBy.Name FROM Teller_Depository_Action__c WHERE Id = :referenceId];			
			System.debug(query);
			if(query != null && !query.isEmpty())
			{
				Map<String, ActivityDetail> details = GenerateActivityDetail('Teller_Depository_Action__c', query[0], Teller_Depository_Action__c.class);
				result.Details = details.values();
			}
		}
		
		if(activityType == 'Customer Image')
		{
			result.Name = activityType;
			List<Customer_Image__c> query = [SELECT Id, Account__c, Account__r.Name, Added_By__c, Added_By__r.Name, Added_Date__c, Approved_By__c, Approved_By__r.Name, Approved_Date__c, Current_Image__c, Image_Id__c, Image_Type__c, Status__c, CreatedBy.Name, CreatedDate FROM Customer_Image__c WHERE Id = :referenceId];			
			System.debug(query);
			if(query != null && !query.isEmpty())
			{
				Map<String, ActivityDetail> details = GenerateActivityDetail('Customer_Image__c', query[0], Customer_Image__c.class);
				result.Details = details.values();				
				result.AdditionalInfo.put('Images', new List<String>{'/servlet/servlet.FileDownload?file=' + query[0].Image_Id__c});
			}
		}
		
		return result;
	}
	
	global static List<SearchCriteria> GetFavoriteSearches()
	{		
		Teller_AccountFunctions functions = new Teller_AccountFunctions();
		Teller_AccountFunctions.TellerInfo info = functions.GetTellerInfo();
		
		String query = 'SELECT Id,name,branch__c,user__c,till__c,currency__c,amount_from__c,amount_to__c,datetime_from__c,datetime_to__c,account_credit__c,account_debit__c,status__c,description__c,activity_type__c,transaction_type__c,current_user__c,current_user_branch__c,sort_by__c,sort_order__c FROM Teller_Activity_Search__c ' + 
					   'WHERE (Roles__c Like \'%' + info.RoleName +'%\' OR Roles__c = null OR Roles__c = \'\')';
		
		List<Teller_Activity_Search__c> searches = Database.query(query);
	
		List<SearchCriteria> result = new List<SearchCriteria>();
		if(!searches.isEmpty())
		{
			for(Teller_Activity_Search__c s : searches)
			{
				SearchCriteria item  = new SearchCriteria();				
				item.Id = s.Id;
				item.SearchName = s.name;
		
				item.OrderDescending = (s.sort_order__c == 'Descending') ? true : false;
				item.OrderByFieldName = s.sort_by__c;

				item.Branch_Number = (s.branch__c != null) ? s.branch__r.branch_number__c : null;
				item.From_Activity_Amount = (s.amount_from__c != null) ? s.amount_from__c : null;
				item.To_Activity_Amount = (s.amount_to__c != null) ? s.amount_to__c : null;
				item.Activity_Currency = (s.currency__c != null) ? s.currency__c : null;
				item.Description = (s.description__c != null) ? s.description__c : null;
				item.Status = (s.status__c != null) ? s.status__c : null;
				item.Activity_Type = (s.activity_type__c != null) ? s.activity_type__c : null;
				item.Created_By_User_Id = (s.user__c != null) ? s.user__r.Id : null;
		        item.To_Activity_Date_Time = (s.datetime_to__c != null) ? s.datetime_to__c.format('dd/MM/yyyy hh:mm') : null;
				item.From_Activity_Date_Time = (s.datetime_from__c != null) ?  s.datetime_from__c.format('dd/MM/yyyy hh:mm') : null;	
				item.Till_Name = (s.till__c != null) ? s.till__r.name : null;
				item.Credit_Account = (s.account_credit__c != null) ? s.account_credit__c : null;
				item.Debit_Account = (s.account_debit__c != null) ? s.account_debit__c : null;
				item.Transaction_Type = (s.transaction_type__c != null) ? s.transaction_type__r.name : null;
				
				if(s.current_user__c)
				{
					item.Created_By_User_Id = UserInfo.getUserId();
				}
				
				if(s.current_user_branch__c)
				{
					item.Branch_Number = info.BranchNumber;
				}
			
				result.add(item);		
			}
		}
		
		return result;
	}
	
	global static List<Teller_Activity_Audit__c> GetSubmittedForAuthorisationForAccount(String accountNo)
	{
		List<Teller_Activity_Audit__c> result =  new List<Teller_Activity_Audit__c>();
		String query = 'SELECT Id FROM Teller_Transaction__c WHERE Transaction_Status__c = \'Submitted for Authorisation\' AND (Debit_Account_No__c = \'' + accountNo + '\' OR Credit_Account_No__c = \'' + accountNo + '\')';		
		List<Teller_Transaction__c> transactions = Database.query(query);

		if(transactions.isEmpty() == false)
		{
			String id_list = '';
			for(Teller_Transaction__c trans : transactions)
			{
				id_list += '\'' + trans.Id + '\',';				
			}				
			id_list = id_list.removeEnd(',');

			query = 'SELECT Activity_Amount__c, Activity_Blob__c, Activity_Currency__c, Activity_Date_Time__c, Activity_Description__c, Activity_Type__c, Branch_Number__c, Till_Name__c, Debit_Account__c, Credit_Account__c,' + 
		            'Created_By_User__c, Created_By_User__r.Name, DML_Operation__c, Object_Id__c, Status__c FROM Teller_Activity_Audit__c WHERE Status__c = \'Submitted for Authorisation\' AND Object_Id__c IN (' + id_list + ') ' +
					'ORDER BY Activity_Date_Time__c DESC LIMIT 50 OFFSET 0';
			result = Database.query(query);
		}
		
		return result;
	}
}