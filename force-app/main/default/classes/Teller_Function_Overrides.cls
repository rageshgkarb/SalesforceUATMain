global class Teller_Function_Overrides {

    global static Limits LoadLimits(Teller_Function_Controller.FunctionPageData request)
    {
        system.debug('Teller_Function_Overrides.LoadLimits');
 
        Teller_Limits__c limitToApply = GetLimitToApply(request, 'T');

        system.debug('limitToApply: ' + limitToApply);

        Limits response = new Limits(UserInfo.getName());
        response.LimitCheckRequired = false;

        if (String.isNotEmpty(limitToApply.Second_Authorisor__c))
        {
            response.SecondAuthorisors = GetAuthorisors(limitToApply.Second_Authorisor__c, true);
			response.SecoundAuthorisorRoles = limitToApply.Second_Authorisor__c;
            response.LimitCheckRequired = true;
        }
        if (String.isNotEmpty(limitToApply.Third_Authorisor__c))
        {
            response.ThirdAuthorisors = GetAuthorisors(limitToApply.Third_Authorisor__c, true);
			response.ThirdAuthorisorRoles = limitToApply.Third_Authorisor__c;
            response.LimitCheckRequired = true;
        }
        if (String.isNotEmpty(limitToApply.Fourth_Authorisor__c))
        {
            response.FourthAuthorisors = GetAuthorisors(limitToApply.Fourth_Authorisor__c, true);
			response.FourthAuthorisorRoles = limitToApply.Fourth_Authorisor__c;
            response.LimitCheckRequired = true;
        }
        response.AllowSubmitForApproval = (Boolean) limitToApply.Allow_Submit_For_Approval__c;
 
        return response;
    }

    public static Boolean AdditionalNotesCheckPassed(Teller_Function_Controller.FunctionPageData request)
    {
        system.debug('Teller_Function_Overrides.AdditionalNotesCheckPassed Entry');

        Teller_Limits__c limitToApply = GetLimitToApply(request, 'A');
        system.debug('limitToApply: ' + limitToApply);
        Boolean response = false;

        if (limitToApply == null)
        {
            response = true;
        }
        else if ((limitToApply != null) && (String.isNotEmpty(request.AdditionalNotes)))
        {
            response = true;
        }

        system.debug('response: ' + response);
        return response;
    }

    public static Teller_Data.GenericResponse PasswordVerification(String userName, String password)
    {
		//SAJ - Check for null or empty password
		if(password == null || password == '')
		{
			return new Teller_Data.GenericResponse(false,'Password cannot be blank');
		}
		
        Teller_Data.GenericResponse response;
        Util_Authorize auth = new Util_Authorize('Limit Authorisation');

        if (!auth.Authorize(username, password))
        {
			system.debug('Failed auth');
            response = new Teller_Data.GenericResponse(false,'Invalid username/password');
        }
        else
        {
			system.debug('Success auth');
            response = new Teller_Data.GenericResponse(true,'Successful Authorisation');
        }

        return response;
    }

	public static Teller_Function_Controller.FunctionPageData SubmitForApproval(Teller_Function_Controller.FunctionPageData request, Limits approvalLimits)
    {
		system.debug('Teller_Function_Overrides.SubmitForApproval Entry');
		String failMessage = 'Authorisors have not been verified';

        // Insert limits into Transaction Overrides object
        Teller_Limits__c limitToApply = GetLimitToApply(request, 'T');

        // Need to check limits have been authorised
        Boolean failed = false;
        Teller_Data.GenericResponse passwordVerificationResponse;
		
		if (approvalLimits.SecondAuthorisor != null)
        {
			if (String.isNotBlank(approvalLimits.SecondAuthorisor.Password))
            {
                passwordVerificationResponse = PasswordVerification(approvalLimits.SecondAuthorisor.Username, approvalLimits.SecondAuthorisor.Password);                
                if (passwordVerificationResponse.Success == false)
                {
	                failed = true;
	                system.debug('Second Authorisor Failed');
                }
            }
			else
            {
                approvalLimits.SecondAuthorisor = null;
            }			
        }
		if (approvalLimits.ThirdAuthorisor != null)
        {
            system.debug('approvalLimits.ThirdAuthorisor.Password: ' + approvalLimits.ThirdAuthorisor.Password);
            if (String.isNotBlank(approvalLimits.ThirdAuthorisor.Password))
            {
                passwordVerificationResponse = PasswordVerification(approvalLimits.ThirdAuthorisor.Username, approvalLimits.ThirdAuthorisor.Password);
                
                if (passwordVerificationResponse.Success == false)
                {
                    failed = true;
                    system.debug('Third Authorisor Failed 1');
                }
            }
			else if (String.isNotBlank((approvalLimits.ThirdAuthorisor.CaseRecord)))
			{
				if(IsCaseAuthorisorUnique(approvalLimits.ThirdAuthorisor.CaseRecord, approvalLimits.SecondAuthorisor.AuthorisorId, null, null) == false)
				{
					failMessage = 'Failed authorisation, Pre-Approved Case authorised by same User';
					failed = true;
				}
			}
            else
            {
                approvalLimits.ThirdAuthorisor = null;
            }
        }
		if (approvalLimits.FourthAuthorisor != null)
        {
            if (String.isNotBlank(approvalLimits.FourthAuthorisor.Password))
            {
                passwordVerificationResponse = PasswordVerification(approvalLimits.FourthAuthorisor.Username, approvalLimits.FourthAuthorisor.Password);
                
                if (passwordVerificationResponse.Success == false)
                {
                    failed = true;
                    system.debug('Fourth Authorisor Failed 1');
                }
            }
			else if (String.isNotBlank((approvalLimits.FourthAuthorisor.CaseRecord)))
			{
				if(IsCaseAuthorisorUnique(approvalLimits.FourthAuthorisor.CaseRecord, approvalLimits.SecondAuthorisor.AuthorisorId, approvalLimits.ThirdAuthorisor.AuthorisorId, null) == false)
				{
					failMessage = 'Failed authorisation, Pre-Approved Case authorised by same User';
					failed = true;
				}
			}
            else
            {
				approvalLimits.FourthAuthorisor = null;
            }
        }
				
		if(failed == false)
		{
			List<Teller_Transaction_Override__c> limitsToInsert = new List<Teller_Transaction_Override__c>();
            // Teller_Transaction_Override__c limitToInsert;
    
            if (approvalLimits.SecondAuthorisor != null)
            {
                Teller_Transaction_Override__c limitToInsert2 = new Teller_Transaction_Override__c();
    
                limitToInsert2.Authorisor_Type__c = 'Second';
                limitToInsert2.Case__c = approvalLimits.SecondAuthorisor.CaseRecord;
                limitToInsert2.Limit_Applied__c = limitToApply.Name;
                limitToInsert2.Override_Type__c = 'Limit';
                limitToInsert2.Override_User__c = approvalLimits.SecondAuthorisor.AuthorisorId;
                limitToInsert2.Teller_Transaction__c = request.TransactionId;
                limitToInsert2.Status__c = 'Approved';
                limitsToInsert.add(limitToInsert2);
            }
            if (approvalLimits.ThirdAuthorisor != null)
            {
                Teller_Transaction_Override__c limitToInsert3 = new Teller_Transaction_Override__c();
    
                limitToInsert3.Authorisor_Type__c = 'Third';
                limitToInsert3.Case__c = approvalLimits.ThirdAuthorisor.CaseRecord;
                limitToInsert3.Limit_Applied__c = limitToApply.Name;
                limitToInsert3.Override_Type__c = 'Limit';
                limitToInsert3.Override_User__c = approvalLimits.ThirdAuthorisor.AuthorisorId;
                limitToInsert3.Teller_Transaction__c = request.TransactionId;
                limitToInsert3.Status__c = 'Approved';
                limitsToInsert.add(limitToInsert3);
            }
            if (approvalLimits.FourthAuthorisor != null)
            {
                Teller_Transaction_Override__c limitToInsert4 = new Teller_Transaction_Override__c();
    
                limitToInsert4.Authorisor_Type__c = 'Fourth';
                limitToInsert4.Case__c = approvalLimits.FourthAuthorisor.CaseRecord;
                limitToInsert4.Limit_Applied__c = limitToApply.Name;
                limitToInsert4.Override_Type__c = 'Limit';
                limitToInsert4.Override_User__c = approvalLimits.FourthAuthorisor.AuthorisorId;
                limitToInsert4.Teller_Transaction__c = request.TransactionId;
                limitToInsert4.Status__c = 'Approved';
                limitsToInsert.add(limitToInsert4);
            }
    
            insert (limitsToInsert);
					
			
			// Update Transaction record
			Teller_Transaction__c tran = [select Transaction_Status__c
                                      from Teller_Transaction__c
                                      where Id=:request.TransactionId];
			tran.Transaction_Status__c = 'Submitted for Authorisation';
			update(tran);
		}
		else
        {
            request.Response_Success = false;
            request.Response_StatusDescription = failMessage;
        }

    	return request;
    }
	
	private static Boolean IsAuthorisorUnique(Limits approvalLimits)
	{
		Boolean result = true;
		if (approvalLimits.SecondAuthorisor != null)
		{
			if (approvalLimits.ThirdAuthorisor != null)
			{
				if(approvalLimits.SecondAuthorisor.AuthorisorId == approvalLimits.ThirdAuthorisor.AuthorisorId)
				{
					result = false;
				}
			}
			
			if (approvalLimits.FourthAuthorisor != null)
			{
				if(approvalLimits.SecondAuthorisor.AuthorisorId == approvalLimits.FourthAuthorisor.AuthorisorId)
				{
					result = false;
				}
			}
		}
		
		if(approvalLimits.ThirdAuthorisor != null)
		{
			if (approvalLimits.FourthAuthorisor != null)
			{
				if(approvalLimits.ThirdAuthorisor.AuthorisorId == approvalLimits.FourthAuthorisor.AuthorisorId)
				{
					result = false;
				}
			}
		}
		
		return result;
	}
	
	private static Boolean IsCaseAuthorisorUnique(Id caseId, Id SecondAuthorisorId, Id ThirdAuthorisorId, Id ForthAuthorisorId)
	{
		Boolean result = true;
		List<ProcessInstance> auths = [SELECT Id,TargetObjectid, Status, LastActorId FROM ProcessInstance where TargetObjectId =: caseId ];	
		if(auths.size() > 0)
		{
			if(SecondAuthorisorId != null && auths[0].LastActorId == SecondAuthorisorId)
			{
				result = false;
			}
			
			if(ThirdAuthorisorId != null && auths[0].LastActorId == ThirdAuthorisorId)
			{
				result = false;
			}
			
			if(ForthAuthorisorId != null && auths[0].LastActorId == ForthAuthorisorId)
			{
				result = false;
			}
		}
		
		return result;
	}
	
    public static Teller_Function_Controller.FunctionPageData LimitCheck(Teller_Function_Controller.FunctionPageData request, Limits approvalLimits)
    {
        system.debug('Teller_Function_Overrides.LimitCheck Entry');
		String failMessage = 'Authorisors have not been verified';

        // Insert limits into Transaction Overrides object
        Teller_Limits__c limitToApply = GetLimitToApply(request, 'T');

        // Need to check limits have been authorised
        Boolean authorised = true;
        Teller_Data.GenericResponse passwordVerificationResponse;
            
		if (approvalLimits.SecondAuthorisor != null)
        {
            passwordVerificationResponse = PasswordVerification(approvalLimits.SecondAuthorisor.Username, approvalLimits.SecondAuthorisor.Password);
            if (passwordVerificationResponse.Success == false)
            {
                authorised = false;
                system.debug('Second Authorisor Failed');
            }
        }
		if (approvalLimits.ThirdAuthorisor != null)
        {
            system.debug('approvalLimits.ThirdAuthorisor.Password: ' + approvalLimits.ThirdAuthorisor.Password);
            if (String.isNotBlank(approvalLimits.ThirdAuthorisor.Password))
            {
                passwordVerificationResponse = PasswordVerification(approvalLimits.ThirdAuthorisor.Username, approvalLimits.ThirdAuthorisor.Password);
                
                if (passwordVerificationResponse.Success == false)
                {
                    authorised = false;
                    system.debug('Third Authorisor Failed 1');
                }
            }
			else if (String.isNotBlank((approvalLimits.ThirdAuthorisor.CaseRecord)))
			{
				if(IsCaseAuthorisorUnique(approvalLimits.ThirdAuthorisor.CaseRecord, approvalLimits.SecondAuthorisor.AuthorisorId, null, null) == false)
				{
					failMessage = 'Failed authorisation, Pre-Approved Case authorised by same User';
					authorised = false;
				}
			}
            else if (String.isBlank((approvalLimits.ThirdAuthorisor.CaseRecord)))
            {
                authorised = false;
                system.debug('Third Authorisor Failed 2');
            }
        }
		if (approvalLimits.FourthAuthorisor != null)
        {
            if (String.isNotBlank(approvalLimits.FourthAuthorisor.Password))
            {
                passwordVerificationResponse = PasswordVerification(approvalLimits.FourthAuthorisor.Username, approvalLimits.FourthAuthorisor.Password);
                
                if (passwordVerificationResponse.Success == false)
                {
                    authorised = false;
                    system.debug('Fourth Authorisor Failed 1');
                }
            }
			else if (String.isNotBlank((approvalLimits.FourthAuthorisor.CaseRecord)))
			{
				if(IsCaseAuthorisorUnique(approvalLimits.FourthAuthorisor.CaseRecord, approvalLimits.SecondAuthorisor.AuthorisorId, approvalLimits.ThirdAuthorisor.AuthorisorId, null) == false)
				{
					failMessage = 'Failed authorisation, Pre-Approved Case authorised by same User';
					authorised = false;
				}
			}
            else if (String.isBlank((approvalLimits.FourthAuthorisor.CaseRecord)))
            {
                authorised = false;
                system.debug('Fourth Authorisor Failed 2');
            }
        }   	
		
		if(IsAuthorisorUnique(approvalLimits) == false)
		{
			authorised = false;
			failMessage = 'Failed authorisation, the same authorisor cannot authorise multiple times';
		}

        if (authorised)
        {
            // Update Transaction record
            Teller_Transaction__c tran = [select Transaction_Status__c
                                          from Teller_Transaction__c
                                          where Id=:request.TransactionId];
            tran.Transaction_Status__c = 'Authorised';
    
            // Save Limit records
            List<Teller_Transaction_Override__c> limitsToInsert = new List<Teller_Transaction_Override__c>();
           // Teller_Transaction_Override__c limitToInsert;
    
            if (approvalLimits.SecondAuthorisor != null)
            {
                Teller_Transaction_Override__c limitToInsert2 = new Teller_Transaction_Override__c();
    
                limitToInsert2.Authorisor_Type__c = 'Second';
                limitToInsert2.Case__c = approvalLimits.SecondAuthorisor.CaseRecord;
                limitToInsert2.Limit_Applied__c = limitToApply.Name;
                limitToInsert2.Override_Type__c = 'Limit';
                limitToInsert2.Override_User__c = approvalLimits.SecondAuthorisor.AuthorisorId;
                limitToInsert2.Teller_Transaction__c = request.TransactionId;
                limitToInsert2.Status__c = 'Approved';
                limitsToInsert.add(limitToInsert2);
            }
            if (approvalLimits.ThirdAuthorisor != null)
            {
                Teller_Transaction_Override__c limitToInsert3 = new Teller_Transaction_Override__c();
    
                limitToInsert3.Authorisor_Type__c = 'Third';
                limitToInsert3.Case__c = approvalLimits.ThirdAuthorisor.CaseRecord;
                limitToInsert3.Limit_Applied__c = limitToApply.Name;
                limitToInsert3.Override_Type__c = 'Limit';
                limitToInsert3.Override_User__c = approvalLimits.ThirdAuthorisor.AuthorisorId;
                limitToInsert3.Teller_Transaction__c = request.TransactionId;
                limitToInsert3.Status__c = 'Approved';
                limitsToInsert.add(limitToInsert3);
            }
            if (approvalLimits.FourthAuthorisor != null)
            {
                Teller_Transaction_Override__c limitToInsert4 = new Teller_Transaction_Override__c();
    
                limitToInsert4.Authorisor_Type__c = 'Fourth';
                limitToInsert4.Case__c = approvalLimits.FourthAuthorisor.CaseRecord;
                limitToInsert4.Limit_Applied__c = limitToApply.Name;
                limitToInsert4.Override_Type__c = 'Limit';
                limitToInsert4.Override_User__c = approvalLimits.FourthAuthorisor.AuthorisorId;
                limitToInsert4.Teller_Transaction__c = request.TransactionId;
                limitToInsert4.Status__c = 'Approved';
                limitsToInsert.add(limitToInsert4);
            }
    
            insert (limitsToInsert);
            update(tran);
            request.Response_Success = true;
        }
        else
        {
            request.Response_Success = false;
            request.Response_StatusDescription = failMessage;
        }
        return request;
    }

    global static void StoreOverride(Id transactionId, String overrideType, String overrideUser, String status)
    {
        Teller_Transaction_Override__c o = new Teller_Transaction_Override__c();
        o.Teller_Transaction__c = transactionId;
        o.Override_Type__c = overrideType;
        o.Override_User__c = overrideUser;
        o.Status__c = status;

        insert(o);
    }

    global static TillAuthorisors GetManagerAuthorisors()
    {
        system.debug('Teller_Function_Overrides.GetManagerAuthorisors Entry');
        TillAuthorisors response = new TillAuthorisors();
        List<Authorisor> authorisors = new List<Authorisor>();
        response.Authorisors = new List<Authorisor>();

        List<User> managers = [select Manager.Id, Manager.Name, Manager.Username, Manager.DelegatedApproverId, Manager.EBSUserId__c, SmallPhotoUrl from User where Id=:UserInfo.getUserId()];
        List<String> delegatedApproverIds = new List<String>();

        // Add Managers
        for(user manager : managers)
        {
            Authorisor a = new Authorisor(manager.Manager.id, manager.Manager.name, manager.Manager.username, manager.Manager.EBSUserId__c, manager.SmallPhotoUrl);
            authorisors.add(a);

            if (String.isNotEmpty(manager.Manager.DelegatedApproverId))
            {
                delegatedApproverIds.add(manager.Manager.DelegatedApproverId);
            }
        }

        // Add Manager Delegates
        List<User> managerDelegates = [select Id, Name, Username, EBSUserId__c, SmallPhotoUrl from user where Id in :delegatedApproverIds and Id <> :UserInfo.getUserId()];
        for(user delegate : managerDelegates)
        {
            Authorisor a = new Authorisor(delegate.id, delegate.name, delegate.username, delegate.ebsuserid__c, delegate.SmallPhotoUrl);
            authorisors.add(a);
        }

        system.debug('authorisors: ' + authorisors);

        Set<Authorisor> authorisorsSet = new Set<Authorisor>();
        authorisorsSet.addAll(authorisors);
        response.Authorisors.addAll(authorisorsSet);

        return response;
    }

    global static VaultAuthorisors GetVaultBalanceAuthorisors()
    {
        system.debug('Teller_Function_Overrides.GetVaultBalanceAuthorisors Entry');
        Teller_Limits__c vaultLimit = [select Name, CCY__c, First_Authorisor__c, Second_Authorisor__c
                                       from Teller_Limits__c
                                       where (Limit_Type__c ='V') and (Name='Vault Balance')];

        VaultAuthorisors response = new VaultAuthorisors();

        response.FirstAuthorisors = GetAuthorisors(vaultLimit.First_Authorisor__c, false);
        response.SecondAuthorisors = GetAuthorisors(vaultLimit.Second_Authorisor__c, true);

        return response;
    }
    
    global static Teller_Function_Overrides.ApprovalDisplayFlags SendTransactionToHost(String TransactionId)
    {
        ApprovalDisplayFlags response = new ApprovalDisplayFlags();
        String functionName = 'Send Transaction To Host';
        
        if (Teller_Security.IsPermitted(functionName))
        {
            Teller_Function_Controller.FunctionPageData data = Teller_Function_Controller.LoadFunctionPageData(TransactionId);
            data = Teller_Function_Controller.ProcessStage(data, 'SendToEBS');
            
            response.Success = data.Response_Success;
            response.ErrorMessage = data.Response_StatusDescription;
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }
        
        return response;
    }

    global static Teller_Function_Overrides.ApprovalDisplayFlags GetApprovalDisplayFlags(String TransactionId)
    {
        ApprovalDisplayFlags response = new ApprovalDisplayFlags();
        Boolean approved = IsTransactionApproved(TransactionId);
        Teller_Transaction__c tran = [select Transaction_Status__c from Teller_Transaction__c where Id=:TransactionId];
        
        if ((tran.Transaction_Status__c == 'Created') || (tran.Transaction_Status__c == 'Complete') || (tran.Transaction_Status__c == 'Declined'))
        {
            // Do not need to show any buttons
            response.DisplayApprovalFlag = false;
            response.DisplayDeclineFlag = false;
            response.DisplaySendToHostFlag = false;
        }
        else if (approved == true)
        {
            // Only need to display Send to Host Button
            response.DisplayApprovalFlag = false;
            response.DisplayDeclineFlag = false;
            response.DisplaySendToHostFlag = true;
        }
        else if (approved == false)
        {
            // Need to display just approval and decline flags
            response.DisplayApprovalFlag = true;
            response.DisplayDeclineFlag = true;
            response.DisplaySendToHostFlag = false;
        }
        
        return response;
    }

        
    public static Teller_Function_Overrides.ApprovalDisplayFlags DeclineTransaction(String TransactionId, String Password, String Notes)
    {
        Teller_Function_Overrides.ApprovalDisplayFlags response = new Teller_Function_Overrides.ApprovalDisplayFlags();
        String functionName = 'Decline Transaction';
        
        if (Teller_Security.IsPermitted(functionName))
        {
            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(UserInfo.getUserName() , Password);
                    
            if (passwordVerificationResponse.Success == true)
            {
                Teller_Transaction_Override__c overrideRec = new Teller_Transaction_Override__c();
                overrideRec.Teller_Transaction__c = TransactionId;
                overrideRec.Override_Type__c = 'Limit';
                overrideRec.Override_User__c = UserInfo.getUserId();
                overrideRec.Status__c = 'Declined';
                insert(overrideRec);
    
                // Update Transaction
                Teller_Transaction__c tran = [select Id, Transaction_Notes__c, Transaction_Status__c from Teller_Transaction__c where Id=:TransactionId];
                tran.Transaction_Notes__c = Notes;
                tran.Transaction_Status__c = 'Declined';
                update(tran);
    
                response = GetApprovalDisplayFlags(TransactionId);
                response.Success = true;
            }
            else
            {
                response.Success = false;
                response.ErrorCode = 'SEC002';
                response.ErrorMessage = 'Password incorrect for approver';
            }
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }
        
        return response;
    }
    
    public static Teller_Function_Overrides.ApprovalDisplayFlags ApproveTransaction(String TransactionId, String Password, String Notes)
    {
        system.debug('Teller_Function_Overrides.ApproveTransaction Entry');
        Teller_Function_Overrides.ApprovalDisplayFlags response = new Teller_Function_Overrides.ApprovalDisplayFlags();
        String functionName = 'Approve Transaction';
        
        if (Teller_Security.IsPermitted(functionName))
        {
            system.debug('UserInfo.getUserName(): ' + UserInfo.getUserName());
            system.debug('Password: ' + Password);
            Teller_Data.GenericResponse passwordVerificationResponse = Teller_Function_Overrides.PasswordVerification(UserInfo.getUserName() , Password);
                    
            if (passwordVerificationResponse.Success == true)
            {
                Teller_Function_Controller.FunctionPageData data = Teller_Function_Controller.LoadFunctionPageData(TransactionId);
                Teller_Limits__c limitToApply = GetLimitToApply(data, 'T');
                List<Teller_Transaction_Override__c> overrides = [select Id, Authorisor_Type__c, Override_User__r.Id, Status__c
                                                                  from Teller_Transaction_Override__c
                                                                  where Teller_Transaction__r.Id=:TransactionId and Override_Type__c='Limit' and Override_User__r.Id=:UserInfo.getUserId()];
                
                // Check whether user already has a record setup for overriding
                if (overrides.size() == 0)
                {
                    List<Authorisor> secondAuthorisors = GetAuthorisors(limitToApply.Second_Authorisor__c, false);
                    List<Authorisor> thirdAuthorisors = GetAuthorisors(limitToApply.Third_Authorisor__c, false);
                    List<Authorisor> fourthAuthorisors = GetAuthorisors(limitToApply.Fourth_Authorisor__c, false);
                    
                    Boolean found = false;
                    String authorisorType = '';
                    for (Authorisor a : secondAuthorisors)
                    {
                        if (a.AuthorisorId == UserInfo.getUserId())
                        {
                            found = true;
                            authorisorType = 'Second';
                        }
                    }
                    
                    for (Authorisor a : thirdAuthorisors)
                    {
                        if (a.AuthorisorId == UserInfo.getUserId())
                        {
                            found = true;
                            authorisorType = 'Third';
                        }
                    }
                    
                    for (Authorisor a : fourthAuthorisors)
                    {
                        if (a.AuthorisorId == UserInfo.getUserId())
                        {
                            found = true;
                            authorisorType = 'Fourth';
                        }
                    }                    
                    
                    if (found)
                    {                    
            			// Add override record
                        Teller_Transaction_Override__c overrideRec = new Teller_Transaction_Override__c();
                        overrideRec.Teller_Transaction__c = TransactionId;
                        overrideRec.Authorisor_Type__c = authorisorType;
                        overrideRec.Override_Type__c = 'Limit';
                        overrideRec.Override_User__c = UserInfo.getUserId();
                        overrideRec.Status__c = 'Approved';
                        insert(overrideRec);
            
                        // Check if Transaction fully approved
                        if (IsTransactionApproved(TransactionId))
                        {
                            // Update Transaction
                            Teller_Transaction__c tran = [select Id, Transaction_Notes__c, Transaction_Status__c from Teller_Transaction__c where Id=:TransactionId];
                            tran.Transaction_Notes__c = tran.Transaction_Notes__c + UserInfo.getName() + ': ' + Notes +'; ';
                            tran.Transaction_Status__c = 'Approved';
                            update(tran);
                        }
                        
                        response = GetApprovalDisplayFlags(TransactionId);
                        response.Success = true;
                    }
                    else
                    {
                        response.Success = false;
                        response.ErrorCode = 'OVER002';
                        response.ErrorMessage = 'User not found in authorisation limits';
                    }
                }
                else
                {
                    response.Success = false;
                    response.ErrorCode = 'OVER001';
                    response.ErrorMessage = 'User already has an override record set';
                }
            }
            else
            {
                response.Success = false;
                response.ErrorCode = 'SEC002';
                response.ErrorMessage = 'Password incorrect for approver';
            }
        }
        else
        {
            response.Success = false;
            response.ErrorCode = 'SEC001';
            response.ErrorMessage = 'Access not permitted for User';
        }
        
        system.debug('response: ' + response);
        return response;
    }
    
    public static Boolean IsTransactionApproved(String TransactionId)
    {
        Boolean response = true;
        Teller_Function_Controller.FunctionPageData data = Teller_Function_Controller.LoadFunctionPageData(TransactionId);
        Teller_Limits__c limitToApply = GetLimitToApply(data, 'T');
        List<Teller_Transaction_Override__c> overrides = [select Id, Authorisor_Type__c, Override_User__r.Id, Status__c
                                                          from Teller_Transaction_Override__c
                                                          where Teller_Transaction__r.Id=:TransactionId and Override_Type__c='Limit'];
        
        List<Authorisor> secondAuthorisors = GetAuthorisors(limitToApply.Second_Authorisor__c, false);
        List<Authorisor> thirdAuthorisors = GetAuthorisors(limitToApply.Third_Authorisor__c, false);
        List<Authorisor> fourthAuthorisors = GetAuthorisors(limitToApply.Fourth_Authorisor__c, false);
        
        Boolean secondAuthorisorFound = false;
        for (Authorisor a : secondAuthorisors)
        {
            for (Teller_Transaction_Override__c o : overrides)
            {
                if ((a.AuthorisorId == o.Override_User__r.Id) && (o.Status__c <> 'Declined') && (o.Authorisor_Type__c == 'Second'))
                {
                    secondAuthorisorFound = true;
                }
            }
        }

        Boolean thirdAuthorisorFound = false;
        for (Authorisor a : thirdAuthorisors)
        {
            for (Teller_Transaction_Override__c o : overrides)
            {
                if ((a.AuthorisorId == o.Override_User__r.Id) && (o.Status__c <> 'Declined') && (o.Authorisor_Type__c == 'Third'))
                {
                    thirdAuthorisorFound = true;
                }
            }
        }
        
        Boolean fourthAuthorisorFound = false;
        for (Authorisor a : fourthAuthorisors)
        {
            for (Teller_Transaction_Override__c o : overrides)
            {
                if ((a.AuthorisorId == o.Override_User__r.Id) && (o.Status__c <> 'Declined') && (o.Authorisor_Type__c == 'Fourth'))
                {
                    fourthAuthorisorFound = true;
                }
            }
        }
        
        if (((secondAuthorisorFound) || (secondAuthorisors.size() == 0)) && 
            ((thirdAuthorisorFound) || (thirdAuthorisors.size() == 0)) && 
            ((fourthAuthorisorFound) || (fourthAuthorisors.size() == 0)))
        {
            response = true;
        }
        else
        {
            response = false;
        }
        
        return response;
    }
    
    public static List<Teller_Function_Overrides.PreApprovedCase> GetPreApprovedCases(Teller_Function_Controller.FunctionPageData request, Integer AuthorisorNo, String AuthorisorId)
    {
        system.debug('Teller_Function_Overrides.GetPreApprovedCases Entry');

        List<PreApprovedCase> casesList = new List<PreApprovedCase>();
        Teller_Settings__c preApprovedCaseAllowableDayssetting = Teller_Settings__c.getValues('PreApprovedCaseAllowableDays');
        Teller_Settings__c preApprovedCaseRecordTypesetting = Teller_Settings__c.getValues('PreApprovedCaseRecordType');

        system.debug('preApprovedCaseAllowableDayssetting: ' + preApprovedCaseAllowableDayssetting);
        system.debug('preApprovedCaseRecordTypesetting: ' + preApprovedCaseRecordTypesetting);

        Integer allowableDays = Integer.valueOf(preApprovedCaseAllowableDayssetting.Value__c);
        Date targetDate = Date.today().addDays(allowableDays * -1);

        system.debug('targetDate: ' + targetDate);

        String accountNo = request.CreditAccountNo;
        if(request.MandateCheckedAgainst.contains('Debit')){
            accountNo = request.DebitAccountNo;
        }
        String branchCode = accountNo.left(4);
        String basicNumber = accountNo.mid(4, 6);
        String mnemonc =accountNo.right(3);

        system.debug('branchCode: ' + branchCode);
        system.debug('basicNumber: ' + basicNumber);
        system.debug('mnemonc: ' + mnemonc);

        // Perform query for Cases
/*        List<Case> preApprovedCases = [select id, type, caseNumber, type_of_withdrawal__c, status, amount_Required__c, branch_code__c, customer_Account_Number__c, x3_digit_account_type__c, createddate
                                       from case 
                                       where recordtypeid in (Select id From recordType where sobjecttype = 'Case' and name in (:preApprovedCaseRecordTypesetting.Value__c)) and 
                                             status='Approved' and (createddate > :targetDate) and 
											 branch_code__c=:branchCode and customer_Account_Number__c=:basicNumber and x3_digit_account_type__c=:mnemonc                                           
		
                                       order by createddate desc
                                       limit 10];*/
		
        List<Case> preApprovedCases = [select id, type, caseNumber, type_of_withdrawal__c, status, transaction_amount__c, branch_code__c, customer_Account_Number__c, x3_digit_account_type__c, createddate
                               from case 
                               where recordtypeid in (Select id From recordType where sobjecttype = 'Case' and name in (:preApprovedCaseRecordTypesetting.Value__c)) and 
                                     status='Approved' and (createddate > :targetDate) and 
									 account_relating_to__r.Name=:accountNo and
									 transaction_type1__c=:request.FunctionId

                               order by createddate desc
                               limit 10];

        system.debug('preApprovedCases: ' + preApprovedCases);

        // Create list of Case Ids
        List<Id> caseIdList = new List<Id>();
        for (Case c : preApprovedCases)
        {
            caseIdList.add(c.Id);
        }

        system.debug('caseIdList: ' + caseIdList);

        // Perform query for Process Instances
        List<ProcessInstance> processInstanceList = [select targetobjectid, lastactorid
                                                     from processInstance
                                                     where targetobjectid in :caseIdList and status='Approved'];

        system.debug('processInstanceList: ' + processInstanceList);
        Map<String, String> approversMap = new Map<String, String >();
        // Populate approversMap
        for (ProcessInstance pi  : processInstanceList)
        {
            approversMap.put(pi.targetobjectid, pi.lastactorid);
        }

        // Get Limit that is being applied
        Teller_Limits__c limitToApply = GetLimitToApply(request, 'T');

		System.debug('authorisor no: ' + AuthorisorNo);
        // Need to send only cases approved by AuthorisorNo approver
        List<Authorisor> limitAuthorisors = new List<Authorisor>();
        if (AuthorisorNo == 2)
        {
            limitAuthorisors = GetAuthorisors(limitToApply.Second_Authorisor__c, true);
        }
        else if (AuthorisorNo == 3)
        {
            limitAuthorisors = GetAuthorisors(limitToApply.Third_Authorisor__c, true);
        }
        else if (AuthorisorNo == 4)
        {
            limitAuthorisors = GetAuthorisors(limitToApply.Fourth_Authorisor__c, true);
        }

		System.debug(limitAuthorisors);
		System.debug(request);
		
        for (Case c : preApprovedCases)
        {
            String authId = approversMap.get(c.Id);
            Boolean authorisorFound = false;

            for (Authorisor a : limitAuthorisors)
            {				
                if (a.AuthorisorId == authId)
                {
                    if(a.AuthorisorId == AuthorisorId)
					{					
						authorisorFound = true;
					}
                }
            }

            // If Case has been authorised by the correct limit approver
            if (authorisorFound)
            {
                PreApprovedCase pac = new PreApprovedCase();
                pac.CaseId = c.Id;
                pac.CaseNo = c.CaseNumber;
                pac.AmountRequired = (Decimal) c.transaction_amount__c;
                pac.CreatedDateTime = Datetime.valueOf(c.createddate).formatLong();

                casesList.add(pac);
            }
        }

        system.debug('casesList: ' + casesList);
        return casesList;
    }

    /* =============================================================================================================== */
    /* Trigger Methods Start                                                                                           */
    /* =============================================================================================================== */

    global static void SubmitForApproval(Teller_Transaction_Override__c overrideRec)
    {

        if (overrideRec.Status__c != 'Approved')
        {
            // Update status on Transaction object
            Teller_Transaction__c tran = [select Id, Transaction_Status__c from Teller_Transaction__c where Id=:overrideRec.Teller_Transaction__c];
            tran.Transaction_Status__c = 'Submitted for Authorisation';
            
            update(tran);
        }
    }
    
    global static void OverrideApproval(Teller_Transaction_Override__c oldOverrideRec, Teller_Transaction_Override__c newOverrideRec)
    {
        if ((newOverrideRec.Status__c == 'Approved') && (oldOverrideRec.Status__c != 'Approved'))
        {
            // Need to check if all other Transaction Override objects attached to the parent Transaction object are also approved
            List<Teller_Transaction_Override__c> notApprovedTTO = [select Id from Teller_Transaction_Override__c where Teller_Transaction__r.Id=:newOverrideRec.Teller_Transaction__r.Id and Status__c != 'Approved'];
            
            if (notApprovedTTO.size() > 0)
            {
                // There are still Transaction Override records that are not approved
            }
            else
            {
                // All Transaction Override records have been approved
                // Need to update the Transaction record status
                Teller_Transaction__c tran = [select Id, Transaction_Status__c from Teller_Transaction__c where Id=:newOverrideRec.Teller_Transaction__r.Id];
                tran.Transaction_Status__c = 'Authorised';
                
                update(tran);
            }
        }
        else if ((newOverrideRec.Status__c == 'Declined') && (oldOverrideRec.Status__c != 'Declined'))
        {
            Teller_Transaction__c tran = [select Id, Transaction_Status__c from Teller_Transaction__c where Id=:newOverrideRec.Teller_Transaction__r.Id];
            tran.Transaction_Status__c = 'Declined';
            
            update(tran);
        }
    }

    /* =============================================================================================================== */
    /* Trigger Methods End                                                                                             */
    /* =============================================================================================================== */

    private static Teller_Limits__c GetLimitToApply(Teller_Function_Controller.FunctionPageData request, String limitType)
    {
        system.debug('Teller_Function_Overrides.GetLimitToApply Entry');
        Decimal transactionAmount = request.TransactionAmount==0?1:request.TransactionAmount;
        List<Teller_Limits__c> defaultLimits = [select Name, CCY__c, Function_Name__c, Branch_No__c, First_Authorisor__c, Second_Authorisor__c, Third_Authorisor__c, Fourth_Authorisor__c, Allow_Submit_For_Approval__c
                                                from Teller_Limits__c
                                                where (Default__c = true) and (Limit_Type__c=:limitType) and (Lower_Limit__c < :transactionAmount) and ((Upper_Limit__c >= :transactionAmount) or (Upper_Limit__c = null))
                                                    and ((CCY__c=:request.CreditAccountCurrency) or (CCY__c=:request.DebitAccountCurrency) or (CCY__c='')) 
                                                    and ((Function_Name__c=:request.FunctionName) or (Function_Name__c='')) 
                                                    and ((Branch_No__c=:request.BranchNo) or (Branch_No__c=''))];
        system.debug('defaultLimits: ' + defaultLimits);

        List<Teller_Limits__c> otherLimits = new List<Teller_Limits__c>();

        if (Teller_Function_Controller.FXRatesRequiredForFunction(request.FunctionId)){
            // FX Limits

            // Need to figure out currency amount pair
            LimitCurrencyAmountPair limitPair = GetLimitCurrencyAmountPair(request);
            String limitBaseCurrency = Teller_TillController.DefaultCCY();
            Decimal limitBaseAmount = 0.0;

            if (limitPair.LimitCurrency != limitBaseCurrency){
                // Will need to convert to base currency
                Teller_Function_Controller.FXRates rates = Teller_Core_Controller.GetFXRates();

                // Figure out Currency to Base
                Decimal exchangeRate = 0.0;
                for (Teller_Function_Controller.FXRateDetailItem rate : rates.FXRateDetail){
                    if ((rate.BuyCurrency == limitPair.LimitCurrency) && (rate.SellCurrency == limitBaseCurrency)){
                        exchangeRate = Decimal.valueOf(rate.ExchangeRate);
                    }
                }
                limitBaseAmount = exchangeRate * limitPair.LimitAmount;
            }

            otherLimits = [select Name, CCY__c, Function_Name__c, Branch_No__c, First_Authorisor__c, Second_Authorisor__c, Third_Authorisor__c, Fourth_Authorisor__c, Allow_Submit_For_Approval__c
                           from Teller_Limits__c
                           where (Default__c = false) 
                                and (Limit_Type__c=:limitType)
                                and ((Function_Name__c=:request.FunctionName) or (Function_Name__c='')) 
                                and ((Branch_No__c=:request.BranchNo) or (Branch_No__c=''))
                                and (((Lower_Limit__c < :limitPair.LimitAmount) and ((Upper_Limit__c >= :limitPair.LimitAmount) or (Upper_Limit__c = null)) and (CCY__c=:limitPair.LimitCurrency))
                                or  ((Lower_Limit__c < :limitBaseAmount) and ((Upper_Limit__c >= :limitBaseAmount) or (Upper_Limit__c = null)) and ((CCY__c=:limitBaseCurrency) or (CCY__c=''))))
                                and ((CCY__c=:request.CreditAccountCurrency) or (CCY__c=:request.DebitAccountCurrency) or (CCY__c=''))];
        }
        else {
            // Normal Base Currency Transaction Limits
            otherLimits = [select Name, CCY__c, Function_Name__c, Branch_No__c, First_Authorisor__c, Second_Authorisor__c, Third_Authorisor__c, Fourth_Authorisor__c, Allow_Submit_For_Approval__c
                           from Teller_Limits__c
                           where (Default__c = false) and (Limit_Type__c=:limitType) and (Lower_Limit__c < :transactionAmount) and ((Upper_Limit__c >= :transactionAmount) or (Upper_Limit__c = null))
                                and ((CCY__c=:request.CreditAccountCurrency) or (CCY__c=:request.DebitAccountCurrency) or (CCY__c='')) 
                                and ((Function_Name__c=:request.FunctionName) or (Function_Name__c='')) 
                                and ((Branch_No__c=:request.BranchNo) or (Branch_No__c=''))];
        }

        system.debug('otherLimits: ' + otherLimits);

        Teller_Limits__c limitToApply;

        if (otherLimits.size() > 1)
        {
            limitToApply = GetMostImportantLimit(otherLimits);
        }
        else if (otherLimits.size() == 1)
        {
            limitToApply = otherLimits.get(0);
        }
        else if (limitType == 'T') // Only need to check for transactional limits
        {
            // Should only ever be one limit for defaults
            limitToApply = defaultLimits.get(0);
        }

        system.debug('limitToApply: ' + limitToApply);

        return limitToApply;
    }

    private static Teller_Limits__c GetMostImportantLimit(List<Teller_Limits__c> limits)
    {
        system.debug('Teller_Function_Overrides.GetMostImportantLimit Entry');
        // Assign first limit to holding variable
        Teller_Limits__c mostImportantLimit = limits.get(0);
        List<Teller_Limits_Matrix__c> matrix = Teller_Limits_Matrix__c.getAll().values();

        Map<String, Teller_Limits_Matrix__c> matrixMap = new Map<String, Teller_Limits_Matrix__c>();
        // Populate matrixMap
        for (Teller_Limits_Matrix__c tlm : matrix)
        {
            matrixMap.put(tlm.Code__c, tlm);
        }

        for (Teller_Limits__c l : limits)
        {
            if (GetMatrixWeighting(l, matrixMap) < GetMatrixWeighting(mostImportantLimit, matrixMap))
            {
                mostImportantLimit = l;
            }
        }

        system.debug('mostImportantLimit: ' + mostImportantLimit);

        return mostImportantLimit;
    }

    private static Integer GetMatrixWeighting(Teller_Limits__c tellerLimit, Map<String, Teller_Limits_Matrix__c> matrixMap)
    {
        String matrixCode='';
        // Build matrix code
        if (String.isNotEmpty(tellerLimit.Branch_No__c))
        {
            matrixCode='B';
        }
        if (String.isNotEmpty(tellerLimit.CCY__c))
        {
            matrixCode = matrixCode + 'C';
        }
        if (String.isNotEmpty(tellerLimit.Function_Name__c))
        {
            matrixCode = matrixCode + 'F';
        }

        Teller_Limits_Matrix__c matrix = matrixMap.get(matrixCode);

        return (Integer) matrix.Weighting__c;
    }

    private static List<Authorisor> GetAuthorisors(String roles, Boolean suppressCurrentUser)
    {
        system.debug('Teller_Function_Overrides.GetAuthorisors Entry');
        system.debug('roles: ' + roles);

        List<Authorisor> authorisors = new List<Authorisor>();
        
		if(roles != null)
		{
			String[] rolesArray = roles.split(',');
			system.debug('rolesArray: ' + rolesArray);

			String rolesString = '\'' + String.join(rolesArray, '\',\'') + '\'';
			system.debug('rolesString: ' + rolesString);
			rolesString = rolesString.replace('\' ', '\''); // Bug in Salesforce String.Join that requires this line
			system.debug('rolesString: ' + rolesString);

			String soql = 'select id, name, username, ebsuserid__c, SmallPhotoUrl from user where IsActive=true and userrole.name in (' + rolesString + ')';

            if (suppressCurrentUser)
            {
                soql += ' and Id <> \'' + UserInfo.getUserId() + '\'';
            }
			system.debug('soql: ' + soql);

			List<User> users = Database.query(soql);
			system.debug('users: ' + users);

			for (User u : users)
			{
            Authorisor a = new Authorisor(u.id, u.name, u.username, u.ebsuserid__c, u.SmallPhotoUrl);
            authorisors.add(a);
			}
		}

        system.debug('authorisors: ' + authorisors);
        return authorisors;
    }

    private static LimitCurrencyAmountPair GetLimitCurrencyAmountPair(Teller_Function_Controller.FunctionPageData request)
    {
        LimitCurrencyAmountPair response = new LimitCurrencyAmountPair();
        String fxLimitAmountFieldToCheck;
        String fxLimitCurrencyFieldToCheck;

        Teller_Function__c func = [select Id, Teller_Function_Root__r.FX_Limit_Amount_Field_to_Check__c, Teller_Function_Root__r.FX_Limit_Currency_Field_to_Check__c
                                        from Teller_Function__c
                                        where Id=:request.FunctionId];
        
        fxLimitAmountFieldToCheck = func.Teller_Function_Root__r.FX_Limit_Amount_Field_to_Check__c;
        fxLimitCurrencyFieldToCheck = func.Teller_Function_Root__r.FX_Limit_Currency_Field_to_Check__c;

        if (fxLimitCurrencyFieldToCheck == 'DebitAccountCurrency') { response.LimitCurrency = request.DebitAccountCurrency; }
        else if (fxLimitCurrencyFieldToCheck == 'CreditAccountCurrency') { response.LimitCurrency = request.CreditAccountCurrency; }
        else if (fxLimitCurrencyFieldToCheck == 'DepositCurrency') { response.LimitCurrency = request.DepositCurrency; }
        else if (fxLimitCurrencyFieldToCheck == 'WithdrawalCurrency') { response.LimitCurrency = request.WithdrawalCurrency; }

        if (fxLimitAmountFieldToCheck == 'TransactionAmount') { response.LimitAmount = request.TransactionAmount; }
        else if (fxLimitAmountFieldToCheck == 'ExchangeAmount') { response.LimitAmount = request.ExchangeAmount; }

        return response;
    }

    global class Limits
    {
    	String FirstAuthorisor{get;set;}
    	List<Authorisor> SecondAuthorisors {get;set;}
		String SecoundAuthorisorRoles {get;Set;}
    	List<Authorisor> ThirdAuthorisors {get;set;}
		String ThirdAuthorisorRoles {get;Set;}
    	List<Authorisor> FourthAuthorisors {get;set;}
		String FourthAuthorisorRoles {get;Set;}
    	Boolean AllowSubmitForApproval {get;set;}

    	Boolean LimitCheckRequired {get;set;}

        Authorisor SecondAuthorisor {get;set;}
        Authorisor ThirdAuthorisor {get;set;}
        Authorisor FourthAuthorisor {get;set;}

        String ThirdAuthorisorPreApprovedCase {get;set;}
        String FourthAuthorisorPreApprovedCase {get;set;}

    	public Limits(String firstAuth)
    	{
    		FirstAuthorisor = firstAuth;
    	}
    }

    global class VaultAuthorisors
    {
        public List<Authorisor> FirstAuthorisors {get;set;}
        public Authorisor selectedFirstAuthorisor {get;set;}
        public List<Authorisor> SecondAuthorisors {get;set;}
        public Authorisor selectedSecondAuthorisor {get;set;}
    }

    global class TillAuthorisors
    {
        public List<Authorisor> Authorisors {get;set;}
        public Authorisor selectedAuthorisor {get;set;}
    }

    global class Authorisor
    {
    	public Id AuthorisorId {get;set;}
    	public String Name {get;set;}
        public String EBSUserId {get;set;}
    	public String Username {get;set;}
        public String Password {get;set;}
        public Id CaseRecord {get;set;}
        public Boolean Verified {get;set;}
        public Boolean IncorrectPassword {get;set;}
		public String ImageUrl {get;Set;}

    	public Authorisor(Id AuthId, String AuthName, String AuthUsername, String EBSUserIdentifier, String photoUrl)
    	{
    		AuthorisorId = AuthId;
    		Name = AuthName;
    		Username = AuthUsername;
            EBSUserId = EBSUserIdentifier;
            Password = '';
            Verified = false;
			ImageUrl = photoUrl;
    	}
		
		public Authorisor(Id AuthId, String AuthName, String AuthUsername, String EBSUserIdentifier)
    	{
    		AuthorisorId = AuthId;
    		Name = AuthName;
    		Username = AuthUsername;
            EBSUserId = EBSUserIdentifier;
            Password = '';
            Verified = false;
    	}
    }
    
    global class ApprovalDisplayFlags
    {
        public Boolean Success{get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
        public Boolean DisplayApprovalFlag{get;set;}
        public Boolean DisplayDeclineFlag{get;set;}
        public Boolean DisplaySendToHostFlag{get;set;}
		
		public ApprovalDisplayFlags()
		{
			Success = false;
        	ErrorCode = '';
        	ErrorMessage = '';
			DisplayApprovalFlag = false;
			DisplayDeclineFlag = false;
			DisplaySendToHostFlag = false;
		}
    }

    global class PreApprovedCases
    {
        public List<PreApprovedCase> CaseList{get;set;}
    }

    global class PreApprovedCase
    {
        public Id CaseId{get;set;}
        public String CaseNo{get;set;}
        public Decimal AmountRequired{get;set;}
        public String CreatedDateTime{get;set;}
    }

    private class LimitCurrencyAmountPair
    {
        public String LimitCurrency{get;set;}
        public Decimal LimitAmount{get;set;}
    }
}