public without sharing class CMSApprovalsController extends CMSBaseController {
    
    public map<string, Cash_Order__c> cashOrdersThisWeek{
        get{
            if(cashOrdersThisWeek == null){
                cashOrdersThisWeek = new map<string, Cash_Order__c>([SELECT  Id, Name, Branch__c, Branch__r.Name, Total_Cash_Amount__c, RecordTypeId, RecordType.Name, Status__c, Royal_Mail_Cash_Order_Request__c, Delivery_Date__c, 
                                                                        Sell_Off_Amount__c 
                                                                        FROM Cash_Order__c
                                                                        WHERE Delivery_Date__c = THIS_WEEK 
                                                                        AND RecordType.Name = 'Standard Cash Order'
                                                                        ORDER BY CreatedDate ASC]);
            }
            return cashOrdersThisWeek;
        }
        set;
    }
    
    public list<CashOrderApproval> approvals {
        get{
            if(approvals == null){
                approvals = new list<CashOrderApproval>();
                
                list<Cash_Order__c> alphaOrderedCashOrdersThisWeek = new list<Cash_Order__c>();
                
                // C0257 - 08/05/2015 Gurdeep Singh : Dereferencing a null object fix 
                if(cashOrdersThisWeek != null && cashOrdersThisWeek.size() > 0)
                {
                    alphaOrderedCashOrdersThisWeek = cashOrdersThisWeek.values();
                    alphaOrderedCashOrdersThisWeek.sort();
                }
                /*
                if(cashOrdersThisWeek.size() >0){
                    alphaOrderedCashOrdersThisWeek = cashOrdersThisWeek.values();
                    alphaOrderedCashOrdersThisWeek.sort();
                }
                */
                
                for(Branch__c branch : branches)
                {
                    //C0257
                    if (String.isEmpty(branch.D_Number__c))
                        continue;
                    // C0257 end
                    
                    Cash_Order__c tempCashOrder = new Cash_Order__c();
                    
                    for(Cash_Order__c cashOrder : alphaOrderedCashOrdersThisWeek){
                        if(cashOrder.Branch__c == branch.Id){
                            tempCashOrder = cashOrder;
                        }
                    }
                    
                    if(tempCashOrder.Id != null){
                        approvals.add(new CashOrderApproval(branch, tempCashOrder));
                    }else{
                        approvals.add(new CashOrderApproval(branch, null));
                    }
                }
            }
            return approvals;
        }
        set;
    }
    
    public boolean allOrdersApproved {
        get{
            integer numOrdersApproved = 0;
            
            for(CashOrderApproval approval : approvals){
                if(approval.isApproved){
                    numOrdersApproved ++;
                }
            }
            
            if(numOrdersApproved == approvals.size()){
                allOrdersApproved = true;
            }else{
                allOrdersApproved = false;
            }
            
            return allOrdersApproved;
        }
        set;
    }
    
    public Royal_Mail_Cash_Order_Request__c rmOrder {
        get{
            if(rmOrder == null && cashOrdersThisWeek.size() > 0){
                rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c
                            FROM Royal_Mail_Cash_Order_Request__c
                            WHERE Id =: cashOrdersThisWeek.values().get(0).Royal_Mail_Cash_Order_Request__c];
            }
            return rmOrder;
        }
        set;
    }
        
    /*public set<string> cashOrderIDs {
        get{
            if(cashOrderIDs == null){
                cashOrderIDs = new set<string>();
                
                for(Cash_Order__c cashOrder : cashOrdersThisWeek.values()){
                    cashOrderIDs.add(cashOrder.Id);
                }
            }
            return cashOrderIDs;
        }
        set;
    }
    
    public list<Approval> approvals {
        get{
            if(approvals == null){
                approvals = new list<Approval>([SELECT  Status, RequestComment, ParentId, Parent.Name, OwnerId, Id, ApproveComment 
                                                    FROM Approval
                                                    WHERE ParentId IN : cashOrderIDs]);
            }
            return approvals;
        }
        set;
    }*/
    
    //INNER CLASS
    public class CashOrderApproval{
        public Cash_Order__c cashOrder {get;set;}
        public Branch__c branch {get;set;}
        public boolean hasCashOrder {get;set;}
        public boolean isApproved {get;set;}
        public string deliveryDateFormatted {get;set;}
        
        public string approvalStatus {get;set;}
        public list<SelectOption> approvalStatusOptions {
            get{
                if(approvalStatusOptions == null){
                    approvalStatusOptions = CMSApprovalsController.getPicklistValues(cashOrder, 'Status__c');
                }
                return approvalStatusOptions;
            }
            set;
        }
        
        public List<ProcessInstance> approvalProcess {get; set;}
        public List<ProcessInstanceHistory> stepOrWorkItem {get; set;}
        
        public CashOrderApproval(Branch__c inBranch, Cash_Order__c inCashOrder){
            this.branch = inBranch;
            this.cashOrder = inCashOrder;
            this.isApproved = false;
            this.hasCashOrder = false;
                        
            if(this.cashOrder != null){
                this.hasCashOrder = true;
                this.approvalStatus = this.cashOrder.Status__c;
                
                if(this.cashOrder.Status__c == 'Accepted'){
                    this.isApproved = true;
                }
                
                date deliveryDT = inCashOrder.Delivery_Date__c;
                datetime deliveryDTime = date.newInstance(deliveryDT.year(), deliveryDT.month(), deliveryDT.day());  
                
                this.deliveryDateFormatted = deliveryDTime.format('E dd/MM/yyyy');
            }
        }
    }
    
    //CONSTUCTOR
    public CMSApprovalsController(){
    
        
    }
    
    
    
    public void updateApprovals(){
        
        list<Approval.ProcessWorkitemRequest> approvalRequests = new list<Approval.ProcessWorkitemRequest>();
        list<ProcessInstanceWorkitem> approvalItems = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN: cashOrdersThisWeek.keyset()];
        map<Id,ProcessInstanceWorkitem> approvalItemMap = new map<Id,ProcessInstanceWorkitem>();

        for(ProcessInstanceWorkitem approvalItem : approvalItems){
            approvalItemMap.put(approvalItem.ProcessInstance.TargetObjectId, approvalItem);
        }

        list<Cash_Order__c> cancelOrderList = new list<Cash_Order__c>();

        for(CashOrderApproval approval : approvals){            
            //Checks if status has changed to Approve or decline record
            if(approval.hasCashOrder && approval.approvalStatus != 'Pending' && approval.approvalStatus != 'Submitted for Approval' && approval.approvalStatus != cashOrdersThisWeek.get(approval.cashOrder.Id).Status__c){
    
                Approval.ProcessWorkitemRequest approvalReq = new Approval.ProcessWorkitemRequest();
                
                if(approval.approvalStatus == 'Accepted'){
                    
                    approvalReq.setAction('Approve');        
                    approvalReq.setWorkitemId(approvalItemMap.get(approval.cashOrder.Id).Id);
                    approval.isApproved = true;

                    if(approval.cashOrder.Total_Cash_Amount__c == 0 && (approval.cashOrder.Sell_Off_Amount__c == null || approval.cashOrder.Sell_Off_Amount__c == 0)){
                        cancelOrderList.add(approval.cashOrder);
                    }
                    
                }else if(approval.approvalStatus == 'Declined'){
                    
                    approvalReq.setAction('Reject');        
                    approvalReq.setWorkitemId(approvalItemMap.get(approval.cashOrder.Id).Id);
                    approval.isApproved = false;
                }
                
                approvalRequests.add(approvalReq);
            }
        }
        system.debug('*** -- approvalRequests ' + approvalRequests);
        list<Approval.ProcessResult> approvalResults = Approval.process(approvalRequests,false);

        if(cancelOrderList.size() > 0){
            CMSScheduledEmailsHandler cmsEmailHandler = new CMSScheduledEmailsHandler();
            cmsEmailHandler.royalMailCancelDelivery(cancelOrderList);
            cmsEmailHandler.sendEmail();
        }
    }
    
    public void submit(){
        
        CMSScheduledEmailsHandler cmsEmailHandler = new CMSScheduledEmailsHandler();
        cmsEmailHandler.royalMailCashOrder(rmOrder);
        cmsEmailHandler.sendEmail();        
    }
    
    public PageReference cancel(){
    
        PageReference branchSummary = Page.BranchSummary;
        branchSummary.getParameters().put('branchID', selectedBranchID);
        
        return branchSummary;
    }
    
    public pageReference goToCashOrderRecord(){
        PageReference cashOrderRecord = new PageReference('/' + ApexPages.currentPage().getParameters().get('cashOrderID'));
        return cashOrderRecord;
    }
    
    public static list<SelectOption> getPicklistValues(SObject obj, String fld){
        list<SelectOption> options = new list<SelectOption>();
        
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType(); 
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){
            if(objDescribe.getName() == 'Cash_Order__c' && a.getLabel() == 'Pending'){
                //dont add to picklist  
            }else{
                options.add(new SelectOption(a.getLabel(), a.getValue())); 
            }
        }
        return options;
    }
}