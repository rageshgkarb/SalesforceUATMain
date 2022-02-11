/* -----------------------------------------------------------------------------------------------------------  */
/* C0531    Updates to DSX                                                                                      */
/* -----------------------------------------------------------------------------------------------------------  */

global class DMCaseMethods
{
    @future (callout=true)
    global static void UpdateDSX(string theCaseID)
    { 
        Case theCase = [select  DM_Document_UDI__c,
                                DM_Customer_Number__c,
                                DM_EBS_ID__c,
                                DM_Account_Number__c,
                                DM_Buffer_ID__c,
                                DM_Branch__c,
                                DM_FirstName__c,
                                DM_LastName__c,
                                DM_PostCode__c,
                                DM_Document_Reference__c,
                                DM_Action_Status__c,
                                DM_Work_Location__c,
                                CaseNumber,
                                DM_Document_Name__c,
                                DM_Completion_Date__c,
                                DM_Document_Date__c,
                                DM_Document_Time__c,
                                Account.EBS_ID__c,
                                Account.BillingPostalCode,
                                Account.firstname,
                                Account.LastName,
                                Account.SFDC_ID__c,
                                DM_Customer_account__r.Branch_Code__c,
                                DM_Customer_account__r.EBS_ID__c,
                                HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c,
                                HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c,
                                Opportunity__r.Account_with_IBB__r.EBS_ID__c,
                                Opportunity__r.Account_with_IBB__r.Branch_Code__c
                            FROM Case
                            WHERE Id = :theCaseID];
        
        
        system.debug('Teller_CustomerDetailsController.GetData Entry');
        Teller_Integration_EBS.DSXUpdate r = new Teller_Integration_EBS.DSXUpdate();
        Teller_Integration_Data.DSXUpdateRequest requestData = new Teller_Integration_Data.DSXUpdateRequest();
        //requestData.CustomerNo = ebsId;
        requestData.DocumentUDI = theCase.DM_Document_UDI__c;
        requestData.CustomerNo = String.isEmpty(theCase.Account.EBS_ID__c) ? theCase.DM_EBS_ID__c : theCase.Account.EBS_ID__c;
        //requestData.AccountNo = String.isEmpty(theCase.DM_Customer_Account__r.EBS_ID__c) ? theCase.DM_Account_Number__c : theCase.DM_Customer_Account__r.EBS_ID__c;
        
        //requestData.AccountNo = String.isEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c) ? theCase.DM_Customer_Account__r.EBS_ID__c : theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c;
        if (String.IsEmpty(theCase.Opportunity__r.Account_with_IBB__r.EBS_ID__c))
        {
            if (String.IsEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c))
            {
                requestData.AccountNo = theCase.DM_Customer_Account__r.EBS_ID__c;
            }
            else
            {
                requestData.AccountNo = theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c;
            }
        }
        else
        {
            requestData.AccountNo = theCase.Opportunity__r.Account_with_IBB__r.EBS_ID__c;
        }
        
        requestData.BufferID = theCase.DM_Buffer_ID__c;
        
        //requestData.Branch = String.isEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c) ? theCase.DM_Customer_account__r.Branch_Code__c : theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c;
        
         if (String.IsEmpty(theCase.Opportunity__r.Account_with_IBB__r.Branch_Code__c))
        {
            if (String.IsEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c))
            {
                requestData.Branch = theCase.DM_Customer_Account__r.Branch_Code__c;
            }
            else
            {
                requestData.Branch = theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c;
            }
        }
        else
        {
            requestData.Branch = theCase.Opportunity__r.Account_with_IBB__r.Branch_Code__c;
        }
        
        requestData.FirstName = String.isEmpty(theCase.Account.firstname) ? theCase.DM_FirstName__c : theCase.Account.firstname;
        requestData.LastName = String.isEmpty(theCase.Account.lastname) ? theCase.DM_LastName__c : theCase.Account.lastname;
        requestData.PostCode = String.isEmpty(theCase.Account.BillingPostalCode) ? theCase.DM_PostCode__c : theCase.Account.BillingPostalCode;
        requestData.DocumentReference = theCase.DM_Document_Reference__c;
        requestData.ActionStatus = theCase.DM_Action_Status__c;
        requestData.WorkLocation = theCase.DM_Work_Location__c;
        requestData.CaseReference = theCase.CaseNumber;
        //requestData.ProcessStatus = theCase.DM_P
        requestData.DocumentName = theCase.DM_Document_Name__c;
        requestData.CompletionDate = theCase.DM_Completion_Date__c;
        requestData.DocumentDate = theCase.DM_Document_Date__c;
        requestData.DocumentTime = theCase.DM_Document_Time__c;
        
        
        Teller_Integration_Data.DSXUpdateResponse data = r.UpdateDSX(requestData);
        system.debug('DSXUpdate data' + data);

        //return data;
    }
    
    @future (callout=true)
    global static void UpdatesDSX(List<String> theCaseIDs)
    {
        System.debug ('The Case IDs 2 ' + theCaseIDs);
        List<Case> theCases = [select   DM_Document_UDI__c,
                                DM_Customer_Number__c,
                                DM_Account_Number__c,
                                DM_Buffer_ID__c,
                                DM_Branch__c,
                                DM_FirstName__c,
                                DM_LastName__c,
                                DM_PostCode__c,
                                DM_Document_Reference__c,
                                DM_Action_Status__c,
                                DM_Work_Location__c,
                                CaseNumber,
                                DM_Document_Name__c,
                                DM_Completion_Date__c,
                                DM_Document_Date__c,
                                DM_Document_Time__c,
                                Account.EBS_ID__c,
                                Account.BillingPostalCode,
                                Account.firstname,
                                Account.LastName,
                                Account.SFDC_ID__c,
                                DM_Customer_account__r.Branch_Code__c,
                                DM_Customer_account__r.EBS_ID__c,
                                HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c,
                                HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c,
                                Opportunity__r.Account_with_IBB__r.EBS_ID__c,
                                Opportunity__r.Account_with_IBB__r.Branch_Code__c
                            FROM Case
                            WHERE Id in :theCaseIDs];
        
        Teller_Integration_EBS.DSXUpdates r = new Teller_Integration_EBS.DSXUpdates();
        Teller_Integration_Data.DSXUpdateRequests requestData = new Teller_Integration_Data.DSXUpdateRequests();
        List<Teller_Integration_Data.DSXUpdateRequest2> requestList = new List<Teller_Integration_Data.DSXUpdateRequest2>();
        for (Case theCase : theCases)
        {
            Teller_Integration_Data.DSXUpdateRequest2 reqData =     new Teller_Integration_Data.DSXUpdateRequest2();
            //requestData.CustomerNo = ebsId;
            reqData.DocumentUDI = theCase.DM_Document_UDI__c;
            reqData.CustomerNo = String.isEmpty(theCase.Account.EBS_ID__c) ? theCase.DM_Customer_Number__c : theCase.Account.EBS_ID__c;
            //reqData.AccountNo = String.isEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c) ? theCase.DM_Customer_account__r.EBS_ID__c : theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c;
            
            if (String.IsEmpty(theCase.Opportunity__r.Account_with_IBB__r.EBS_ID__c))
            {
                if (String.IsEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c))
                {
                    reqData.AccountNo = theCase.DM_Customer_Account__r.EBS_ID__c;
                }
                else
                {
                    reqData.AccountNo = theCase.HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c;
                }
            }
            else
            {
                reqData.AccountNo = theCase.Opportunity__r.Account_with_IBB__r.EBS_ID__c;
            }
            
            reqData.BufferID = theCase.DM_Buffer_ID__c;
            
            //requestData.Branch = String.isEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c) ? theCase.DM_Customer_account__r.Branch_Code__c : theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c;
            
             if (String.IsEmpty(theCase.Opportunity__r.Account_with_IBB__r.Branch_Code__c))
            {
                if (String.IsEmpty(theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c))
                {
                    reqData.Branch = theCase.DM_Customer_Account__r.Branch_Code__c;
                }
                else
                {
                    reqData.Branch = theCase.HPP_Opportunity__r.Account_with_IBB__r.Branch_Code__c;
                }
            }
            else
            {
                reqData.Branch = theCase.Opportunity__r.Account_with_IBB__r.Branch_Code__c;
            }
        
            
            
            
            reqData.FirstName = String.isEmpty(theCase.Account.firstname) ? theCase.DM_FirstName__c : theCase.Account.firstname;
            reqData.LastName = String.isEmpty(theCase.Account.lastname) ? theCase.DM_LastName__c : theCase.Account.lastname;
            reqData.PostCode = String.isEmpty(theCase.Account.BillingPostalCode) ? theCase.DM_PostCode__c : theCase.Account.BillingPostalCode;
            reqData.DocumentReference = theCase.DM_Document_Reference__c;
            reqData.ActionStatus = theCase.DM_Action_Status__c;
            reqData.WorkLocation = theCase.DM_Work_Location__c;
            reqData.CaseReference = theCase.CaseNumber;
            //requestData.ProcessStatus = theCase.DM_P
            reqData.DocumentName = theCase.DM_Document_Name__c;
            reqData.CompletionDate = theCase.DM_Completion_Date__c;
            reqData.DocumentDate = theCase.DM_Document_Date__c;
            reqData.DocumentTime = theCase.DM_Document_Time__c;
            requestList.add(reqData);
        }
        System.debug ('this is the request LIST ' + requestList);
        requestData.DSXupdRequests = requestList;
        System.debug ('this is the requestData ' + requestData.DsxupdRequests);
        Teller_Integration_Data.DSXResponses data = r.UpdatesDSX(requestData);
        System.debug ('this is the response data ' + data);
        
    }
    
    global static void ProcessCases ()
    {
        Trigger_Helper.TriggerItem itemCase = new Trigger_Helper.TriggerItem();
        itemCase.Name = 'Case';
        itemCase.IgnoreAudit = true;
        itemCase.IgnoreTrigger = true;
        
        Trigger_Helper.Items.Add(itemCase);
        
        List<Case> theCases = [SELECT   Id,
                                        DM_Customer_Number__c,
                                        DM_EBS_ID__c,
                                        DM_Account_Number__c,
                                        Status,
                                        Account.EBS_ID__c,
                                        DM_Customer_Account__r.EBS_ID__c,
                                        HPP_Opportunity__r.Account_with_IBB__r.EBS_ID__c,
                                        HPP_Opportunity__r.Account_With_IBB__c,
                                        Opportunity__r.Account_with_IBB__r.EBS_ID__c,
                                        Opportunity__r.Account_With_IBB__c
                                FROM    Case
                                WHERE   Status = 'Closed'
                                AND     IsClosed = true
                                AND     (DM_Document_Name__c != '' AND DM_Document_Name__c != null)
                                AND     (DM_Customer_Number__c = '' OR DM_Customer_Number__c = null)
                                AND     (Account.EBS_ID__c != '' AND Account.EBS_ID__c != null)];
        System.debug ('These are the Cases ' + theCases);
        
        if (theCases.size() > 0)
        {
            List<String> caseIDs = new List<String>();
            
            for (Case theCase : theCases)
            {
                caseIDs.add(theCase.Id);
                theCase.DM_Customer_Number__c = theCase.Account.EBS_ID__c;
                theCase.DM_Customer_Account__c = String.isEmpty(theCase.Opportunity__r.Account_With_IBB__c) ? theCase.HPP_Opportunity__r.Account_with_IBB__c : theCase.Opportunity__r.Account_With_IBB__c;
                //theCase.DM_Account_Number__c = theCase.DM_Customer_Account__r.EBS_ID__c;
            }
            
            
            UpdatesDSX (caseIDs);
            update theCases;
        }
        
        
    }
    
    global static void CleardownBacklog ()
    {
        Trigger_Helper.TriggerItem itemCase = new Trigger_Helper.TriggerItem();
        itemCase.Name = 'Case';
        itemCase.IgnoreAudit = true;
        itemCase.IgnoreTrigger = true;
        
        Trigger_Helper.Items.Add(itemCase);

        List<Case> cases = [SELECT id, CaseNumber, Subject, Status, DM_Account_Number__c 
                            from case 
                            where Status != 'Closed' 
                            // ??? 

                            and (DM_Account_Number__c != '' or DM_Action_Status__c = 'COMPLETED')
                            and IsClosed = false  
                            
                            and  (subject = 'SUBJECT DSX - Account Maintenance' OR
                                 subject = 'SUBJECT DSX - Customer and Account Opening' OR
                                 subject = 'SUBJECT DSX - Transfer Authority form' OR
                                 subject = 'SUBJECT DSX - Payments' OR
                                 subject = 'SUBJECT DSX - Account Closures' OR
                                 subject = 'SUBJECT DSX - Change of Address' OR
                                 subject = 'SUBJECT DSX - Change of Name' OR
                                 subject = 'SUBJECT DSX - Notice Withdrawal' OR
                                 subject = 'SUBJECT DSX - Online Banking' OR
                                 subject = 'SUBJECT DSX - Signature Slips' OR
                                 subject = 'SUBJECT DSX - DM Payments' OR
                                 subject = 'SUBJECT DSX - Post Completion' OR
                                 /*subject = 'SUBJECT DSX - Customer Complaints' OR */
                                 subject = 'SUBJECT DSX - General Correspondance'  OR
                                 subject = 'SUBJECT DSX - ISA Transfer In' OR    
                                 subject = 'SUBJECT DSX - ISA Transfer Out' OR    
                                 subject = 'SUBJECT DSX - Notice Withdrawal' OR   
                                 subject = 'SUBJECT DSX - Returned Mail' OR 
                                 subject = 'SUBJECT DSX - Product Switch' OR                                      
                                 subject = 'SUBJECT DSX - Council Tax'                                
                                 ) LIMIT 200];
        
        for (Case c:cases)
        {
            c.Subject = c.Subject + ' Closed by EA';
            c.Status = 'Closed';
            system.debug ('The case number ' + c.CaseNumber);
            //c.IsClosed = true;
        }
        
        List<Database.SaveResult> results = Database.update(cases, false);
            
        for (Database.SaveResult result : results)
        {
            if (!result.isSuccess ())
            {
                List<Database.Error> dbErr = result.GetErrors ();
                Database.Error e = dbErr [0];
                            
                System.debug ( 'This is DB exception ' + e.getMessage());
            }
        }
        //update cases;

    }
}