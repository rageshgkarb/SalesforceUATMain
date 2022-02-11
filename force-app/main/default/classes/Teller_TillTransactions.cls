global class Teller_TillTransactions
{

    global static void SaveTellerActivityAuditRecord(List<ActivityAudit> activityAudits)
    {
        system.debug('Teller_TillTransactions.SaveTellerActivityAuditRecord Entry');
        system.debug('activityAudits: ' + activityAudits);

        List<Teller_Activity_Audit__c> audits = new List<Teller_Activity_Audit__c>();

        for (ActivityAudit a : activityAudits)
        {
            if (!TellerActivityAuditPresent(a))
            {
                Teller_Activity_Audit__c audit = new Teller_Activity_Audit__c();
    
                audit.Activity_Amount__c = a.ActivityAmount;
                audit.Activity_Blob__c = a.ActivityBlob; 
                audit.Activity_Currency__c = a.ActivityCurrency;
                audit.Activity_Date_Time__c = DateTime.now();
                audit.Activity_Description__c = a.ActivityDescription;
                audit.Activity_Type__c = a.ActivityType;
                audit.Branch_Number__c = a.BranchNo;
                audit.Created_By_User__c = UserInfo.getUserId();
                audit.Credit_Account__c = a.CreditAccountNo;
                audit.Debit_Account__c = a.DebitAccountNo;
                audit.Name = a.ActivityType + ' - ' + a.FunctionName;
                audit.DML_Operation__c = a.DMLOperation;
                audit.Object_ID__c = a.ObjectId;
                audit.Status__c = a.Status;
                audit.Till_Name__c = a.TillName;
				
				//C0332 : Start
				audit.ActivityAuditIdentifier__c = audit.Object_ID__c + audit.Activity_Type__c + audit.Status__c + audit.Credit_Account__c + audit.Debit_Account__c + audit.Activity_Amount__c + audit.DML_Operation__c + audit.Created_By_User__c;
				//C0332 : End
				
                audits.add(audit);
            }
        }

        system.debug('audits: ' + audits);
        insert(audits);
    }

    private static Boolean TellerActivityAuditPresent(ActivityAudit request)
    {
		system.debug('Teller_TillTransactions.TellerActivityAuditPresent Entry');
        system.debug('request: ' + request);
        Boolean response = false;
				
		//C0332 : Start
		Teller_Settings__c existsCheck = Teller_Settings__c.getValues('ActivityAuditExistsCheck');
		if(existsCheck.Value__c.toLowerCase() == 'false')
		{
			return false;
		}
				
		/*      
		//Previous query  
		List<Teller_Activity_Audit__c> auditlist = [select Id
                                                    from Teller_Activity_Audit__c
                                                    where Activity_Amount__c=:request.ActivityAmount and Activity_Currency__c=:request.ActivityCurrency and Activity_Type__c=:request.ActivityType and Created_By_User__c=:UserInfo.getUserId() and
                                                   		  Credit_Account__c=:request.CreditAccountNo and Debit_Account__c=:request.DebitAccountNo and DML_Operation__c=:request.DMLOperation and Object_ID__c=:request.ObjectId and
                                                   		  Status__c=:request.Status and Till_Name__c=:request.TillName];
		*/
				
		Datetime datetimeBoundry = request.ActivityDateTime.addMonths(-1);
		String identifier = request.ObjectId + request.ActivityType + request.Status + request.CreditAccountNo + request.DebitAccountNo + request.ActivityAmount + request.DMLOperation + UserInfo.getUserId();	
        List<Teller_Activity_Audit__c> auditlist = [select Id, Activity_Date_Time__c
                                                    from Teller_Activity_Audit__c
                                                    where ActivityAuditIdentifier__c =: identifier and Activity_Date_Time__c > :datetimeBoundry];
		
		//C0332 : End
		
        if (auditList.size() > 0)
        {
			//C0332 : Start
			Teller_Settings__c timeFrame = Teller_Settings__c.getValues('ActivityAuditTimeFrameSec');
			Integer upperBound = Integer.valueOf(timeFrame.Value__c) / 2;
			Integer lowerBound = upperBound * -1;
			
			for(Teller_Activity_Audit__c audit : auditList)
			{	
				Datetime before = request.ActivityDateTime.addSeconds(lowerBound);
				Datetime after = request.ActivityDateTime.addSeconds(upperBound);
				
				System.debug(audit.Id + '  ' + audit.Activity_Date_Time__c + '    ' + String.valueOf(before) + '   ' +  String.valueOf(after));
				
				if(before < audit.Activity_Date_Time__c && audit.Activity_Date_Time__c < after)
				{
					response = true;
				}
			}
						
			//C0332 : End
			
            //response = true;
        }
        
        system.debug('response: ' + response);
        return response;
    }
    
    global class ActivityAudit
    {
        public Decimal ActivityAmount {get;set;}
        public String ActivityBlob {get;set;}
        public String ActivityCurrency {get;set;}
        public DateTime ActivityDateTime {get;set;}
        public String ActivityDescription {get;set;}
        public String ActivityType {get;set;}
        public String BranchNo {get;set;}
        public String CreditAccountNo {get;set;}
        public String DebitAccountNo {get;set;}
        public String FunctionName {get;set;}
        public String DMLOperation {get;set;}
        public String ObjectId {get;set;}
        public String Status {get;set;}
        public String TillName {get;set;}
    }
}