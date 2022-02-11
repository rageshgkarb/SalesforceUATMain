public virtual with sharing class CMSBaseController {
    public List<Branch__c> branches {
        get {
            if (branches == null) {
                branches = [
                    SELECT Name, Branch_Location__c, Branch_Limit__c// C0257
                , D_Number__c, 
                // C0257 end
                Cash_Order_Approver__c, Branch_Open_Days__c
                    FROM Branch__c
                
                // C0257
                WHERE D_Number__c <> ''
                // C0257
                    
                    ORDER BY Name ASC
                ];
            }
            
            return branches;
        }
        private set;
    }
    
    private Map<Id, Branch__c> branchesMap {
        get {
            if (branchesMap == null) {
                branchesMap = new Map<Id, Branch__c>(branches);
            }
            
            return branchesMap;
        }
        private set;
    }
    
    public Boolean hasAccessToZeroBranches {
        get {
            return branches.isEmpty();
        }
    }
    
    public Boolean hasAccessToOneBranch {
        get {
            return branches.size() == 1;
        }
    }
    
    public Boolean hasAccessToMultipleBranches {
        get {
            return branches.size() > 1;
        }
    }
    
    public Id selectedBranchID {
        get {
            if (hasAccessToOneBranch) {
                selectedBranchID = branches[0].Id;
            }
            else if (String.isNotBlank(ApexPages.currentPage().getParameters().get('branchID'))) {
                selectedBranchID = ApexPages.currentPage().getParameters().get('branchID');
            }
            
            System.debug('selectedBranchID => ' + selectedBranchID);
            return selectedBranchID;
        }
        private set;
    }
    
    public Branch__c selectedBranch {
        get {
            if (selectedBranch == null && String.isNotBlank(selectedBranchID)) {
                selectedBranch = branchesMap.get(selectedBranchID);
            }
            
            System.debug('selectedBranch => ' + selectedBranch);
            return selectedBranch;
        }
        private set;
    }
    
    public PageReference redirectToBranchSelector() {
        PageReference redirectPage = null;
        
        System.debug('hasAccessToMultipleBranches => ' + hasAccessToMultipleBranches);
        System.debug('selectedBranch => ' + selectedBranch);
        
        if (hasAccessToMultipleBranches && selectedBranch == null) {
            redirectPage = Page.BranchSelector;
        }
        
        return redirectPage;
    }
}