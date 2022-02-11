public without sharing class CMSTestUtility {
    
    public static list<Branch__c> createBranches(Integer numBranches){
        list<Branch__c> branches = new list<Branch__c>();
        
        User approver = [SELECT Id FROM User WHERE (Profile.Name = 'System Administrator' or Profile.Name = 'System Administrator IP' )AND IsActive = true limit 1];
        List<User> deputyBranchManager = [SELECT Id FROM User WHERE UserRole.Name LIKE '%Deputy Branch Manager%' AND IsActive = true limit 1];

        for(Integer i=0 ; i < numBranches ; i++){
            Branch__c branch = new Branch__c();
            branch.Name = 'Branch ' + i;
            branch.Branch_Location__c = 'ABC Street';
            branch.Branch_Limit__c = 100000;
            branch.Cash_order_Approver__c = approver.Id;
            if(deputyBranchManager.size()>0){
                branch.Deputy_Branch_Manager__c = deputyBranchManager[0].Id;
            }
            branch.Branch_Open_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday; Saturday';
            /* C0257 */
            branch.D_number__c = 'Test';
            branches.add(branch);
        }
        
        insert branches;
        
        return branches;    
    }
    
    public static list<Balance_Entry__c> createBalanceEntries(list<Branch__c> branches, Integer numDays){
        list<Balance_Entry__c> balanceEntries = new list<Balance_Entry__c>();
            
        for(Branch__c branch : branches){
            for(Integer i=0 ; i < numDays ; i++){
                Balance_Entry__c balanceEntry = new Balance_Entry__c();
                balanceEntry.Branch__c = branch.Id;
                balanceEntry.Balance__c = 50000;
                balanceEntry.Date__c = date.today().addDays(-i);
                balanceEntries.add(balanceEntry);
            }
        }
        
        insert balanceEntries;
        
        return balanceEntries;  
    }
    
    public static list<Cash_Order__c> createCashOrders(list<Branch__c> branches, Integer numRecords, Royal_Mail_Cash_Order_Request__c rmOrder, string recordTypeName, boolean submitForApproval){
        list<Cash_Order__c> cashOrders = new list<Cash_Order__c>();
        
        RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Cash_Order__c' AND Name =: recordTypeName];
            
        for(Branch__c branch : branches){
            for(Integer i=0 ; i < numRecords ; i++){
                Cash_Order__c cashOrder = new Cash_Order__c();
                cashOrder.Cash_Order_Approver__c = branch.Cash_order_Approver__c;
                cashOrder.Branch__c = branch.Id;
                cashOrder.RecordTypeId = recType.Id;
                cashOrder.Royal_Mail_Cash_Order_Request__c = rmOrder.Id;
                cashOrder.Delivery_Date__c = date.today();
                cashOrder.Order_Date__c = date.today();
                cashOrders.add(cashOrder);
                
                
            }
        }
        
        insert cashOrders;
        
        if(submitForApproval){
            for(Cash_Order__c cashOrder : cashOrders){
                // Create an approval request
                Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setObjectId(cashOrder.id);
                
                // Submit the approval request
                Approval.ProcessResult approvalResult = Approval.process(approvalReq);
            }
        }
        
        return cashOrders;  
    }
    
    /*public static void createHolidays(list<date> dates){
        list<Holiday> holidays = new list<Holiday>();

        
        for(Date holidayDt : dates){
            Holiday holiday = new Holiday();
            holiday.Name = 'Test ' + string.valueOf(holidayDt);
            holiday.ActivityDate = holidayDt;
            holidays.add(holiday);
        }
        
        insert holidays;
    }*/
    
}