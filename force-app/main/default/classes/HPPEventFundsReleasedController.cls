/* --------------------------------------------------------------------------------------- */
/* C00179 Show Original funds sent date if it exists                                       */
/* --------------------------------------------------------------------------------------- */
/* C00222    Add do not refresh etc on failure                                             */
/* --------------------------------------------------------------------------------------- */
/* C0635     Removed common elements to BaseEventController                                */
/* --------------------------------------------------------------------------------------- */


public class HPPEventFundsReleasedController extends HPPBaseEventController {
    public String pageMessage { get; private set; }
    public String approverComments { get; set; }
    public Boolean haveFundsBeenReleased { get; private set; }
    
    public Boolean showOriginalFundsSent {get;set;} // C00179
    
    public HPPEventFundsReleasedController() {
        if (String.isBlank(exOpp.Payment_Reference__c)) {
            haveFundsBeenReleased = false;
        }
        else {
            haveFundsBeenReleased = true;
        }
        
        if (String.isBlank(exOpp.IBB_Solicitor__c)) {
            if (String.isBlank(prodSet.Name)) {
                exOpp.IBB_Solicitor__c = null;
            }
            else if (prodSet.Name == 'Home Purchase Plan Scotland' || prodSet.Name == 'Buy To Let Purchase Plan Scotland' ) {
               //C0662 - set Shepherd and Wedderburn to default
                //exOpp.IBB_Solicitor__c = 'Todds Murray';
                //exOpp.IBB_Solicitor__c = 'Shepherd and Wedderburn';
                //C0730 - Set Optima Legal (Scotland) Limited to default
                exOpp.IBB_Solicitor__c = 'Optima Legal (Scotland) Limited'; 
            } // C0644 Added in check for BTL Ltd Co. Products
            else if (prodSet.Name == 'Home Purchase Plan' || prodSet.Name == 'Home Purchase Plan Premier' || prodSet.Name == 'Buy To Let Limited Company Purchase Plan' || prodSet.Name.startsWith('Buy To Let Purchase Plan')) {
                //C0662 - set Shakespeare Martineau LLP to default
                //exOpp.IBB_Solicitor__c = 'SGH Martineau';
                exOpp.IBB_Solicitor__c = 'Shakespeare Martineau LLP';
            }
            else {
                exOpp.IBB_Solicitor__c = null;
            }
        }
        /* C00179 */
        if ( exOpp.Original_funds_sent_date__c != null)
        {
            showOriginalFundsSent = true;
        }
        else
        {
            showOriginalFundsSent = false;
        }
        /* C00179 end */
    }
    
    private Integer requiredNumberOfLevel123Authorisations {
        get {
            if (Opp.Finance_Required__c < 1000000) {
                return 2;
            }
            else {
                return 1;
            }
        }
    }
    
    private Integer requiredNumberOfLevel45Authorisations {
        get {
            if (Opp.Finance_Required__c < 1000000) {
                return 1;
            }
            else {
                return 2;
            }
        }
    }
    
    private User currentUser {
        get {
            if (currentUser == null) {
                currentUser = [
                    SELECT Name, HPPAuthorityLevel__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1
                ];
            }
            return currentUser;
        }
        private set;
    }
    
    private List<User> existingApprovers {
        get {
            if (existingApprovers == null) {
                List<Id> approverIDs = new List<Id>();
                approverIDs.add(exOpp.ApproverName1__c);
                approverIDs.add(exOpp.ApproverName2__c);
                approverIDs.add(exOpp.ApproverName3__c);
                approverIDs.add(exOpp.ApproverName4__c);
                
                existingApprovers = [
                    SELECT Name, HPPAuthorityLevel__c
                    FROM User
                    WHERE Id IN :approverIDs
                ];
            }
            return existingApprovers;
        }
        set;
    }
    
    private Set<Id> existingApproverIDs { 
        get {
            existingApproverIDs = new Set<Id>();
            existingApproverIDs.add(exOpp.ApproverName1__c);
            existingApproverIDs.add(exOpp.ApproverName2__c);
            existingApproverIDs.add(exOpp.ApproverName3__c);
            existingApproverIDs.add(exOpp.ApproverName4__c);
            
            return existingApproverIDs;
        } 
        private set; 
    }
    
    public Boolean IsPremier
    {
        get{
            return prodSet.ProductSetType__c.equalsIgnoreCase('Premier'); 
        }
    }
    
    
    public Boolean canApprove {
        get {
            if (currentUser.HPPAuthorityLevel__c != null) {
                if (existingApproverIDs.contains(currentUser.Id)) {
                    return false;
                }
                if (currentUser.HPPAuthorityLevel__c == '1' || currentUser.HPPAuthorityLevel__c == '2' || currentUser.HPPAuthorityLevel__c == '3') {
                    if (numberOfLevel123Authorisations >= requiredNumberOfLevel123Authorisations) {
                        return false;
                    }
                    else {
                        return true;
                    }
                }
                else if (currentUser.HPPAuthorityLevel__c == '4' || currentUser.HPPAuthorityLevel__c == '5') {
                    if (numberOfLevel45Authorisations >= requiredNumberOfLevel45Authorisations) {
                        return false;
                    }
                    else {
                        return true;
                    }
                }
                else {
                    return false;
                }
            }
            else {
                return false;
            }
        }
    }
    
    private Integer numberOfLevel123Authorisations {
        get {
            numberOfLevel123Authorisations = 0;
            
            for (User approver : existingApprovers) {
                if (approver.HPPAuthorityLevel__c == '1' || approver.HPPAuthorityLevel__c == '2' || approver.HPPAuthorityLevel__c == '3') {
                    ++numberOfLevel123Authorisations;
                }
            }
            
            return numberOfLevel123Authorisations;
        }
        private set;
    }
    
    private Integer numberOfLevel45Authorisations {
        get {
            numberOfLevel45Authorisations = 0;
            
            for (User approver : existingApprovers) {
                if (approver.HPPAuthorityLevel__c == '4' || approver.HPPAuthorityLevel__c == '5') {
                    ++numberOfLevel45Authorisations;
                }
            }
            
            return numberOfLevel45Authorisations;
        }
        private set;
    }
    
    public Boolean hasRequiredAuthorisationBeenMet {
        get {
            System.debug('numberOfLevel123Authorisations => ' + numberOfLevel123Authorisations);
            System.debug('requiredNumberOfLevel123Authorisations => ' + requiredNumberOfLevel123Authorisations);
            System.debug('numberOfLevel45Authorisations => ' + numberOfLevel45Authorisations);
            System.debug('requiredNumberOfLevel45Authorisations => ' + requiredNumberOfLevel45Authorisations);
            
            if (numberOfLevel123Authorisations >= requiredNumberOfLevel123Authorisations && numberOfLevel45Authorisations >= requiredNumberOfLevel45Authorisations) {
                return true;
            }
            else {
                return false;
            }
        }
        private set;
    }
    
    public PageReference approve() {
        if (canApprove) {
            if (exOpp.ApproverName1__c == null) {
                exOpp.ApproverName1__c = currentUser.Id;
                exOpp.DateApprover1__c = Date.today();
                exOpp.CommentsApprover1__c = approverComments;
            }
            else if (exOpp.ApproverName2__c == null) {
                exOpp.ApproverName2__c = currentUser.Id;
                exOpp.DateApprover2__c = Date.today();
                exOpp.CommentsApprover2__c = approverComments;
            }
            else if (exOpp.ApproverName3__c == null) {
                exOpp.ApproverName3__c = currentUser.Id;
                exOpp.DateApprover3__c = Date.today();
                exOpp.CommentsApprover3__c = approverComments;
            }
            else if (exOpp.ApproverName4__c == null) {
                exOpp.ApproverName4__c = currentUser.Id;
                exOpp.DateApprover4__c = Date.today();
                exOpp.CommentsApprover4__c = approverComments;
            }
            
            //  Clear Lists
            existingApprovers = null;
            //  existingAuthorisationLevels = null;
            
            update exOpp;
        }
        
        return null;
    }
    
    public Boolean canReleaseFunds {
        get {
            if (hasRequiredAuthorisationBeenMet && !haveFundsBeenReleased) {
                return true;
            }
            else {
                return false;
            }
        }
    }
    
    public PageReference releaseFunds() {
        if (hasRequiredAuthorisationBeenMet && !haveFundsBeenReleased) {
            Actions.ActionAddOutwardPayment outwardPaymentAction = new Actions.ActionAddOutwardPayment();
            IBBEvents.CompleteEventArgs outwardPaymentArgs = outwardPaymentAction.RunAction(Opp.Id);
            
            System.debug('outwardPaymentArgs.ErrorMessage => ' + outwardPaymentArgs.ErrorMessage);
            System.debug('outwardPaymentArgs.ReturnValue => ' + outwardPaymentArgs.ReturnValue);
            
            if (outwardPaymentArgs.ReturnValue == 'SUCCESS') {
                pageMessage = 'Funds Released.';
                haveFundsBeenReleased = true;
                /* C00222 */
                exOpp.Date_Funds_sent__c = Date.Today();
                update exOpp;
                /* C00222 end */
            }
            else {
                pageMessage = 'Error occured: ' + outwardPaymentArgs.ErrorMessage ;
               
                haveFundsBeenReleased = false;
            }
        }
        else if (hasRequiredAuthorisationBeenMet && haveFundsBeenReleased) {
            pageMessage = 'Funds have already been released.';
        }
        else {
            pageMessage = 'Insufficient authorisation has been received to release the funds.';
        }
        
        return null;
    }
    
    public PageReference complete() {
        PageReference pageRef = null;
        
        if (hasRequiredAuthorisationBeenMet && haveFundsBeenReleased) {
            CompleteEvent();
        
            if (CreatedEvent != null) {
                pageRef = new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
            }
        }
        
        return pageRef;
    }
    
    public PageReference autoRun() {
        IBBDependentObjectFactory.CreateAOPStubs(Opp);
        return null;
    }
}