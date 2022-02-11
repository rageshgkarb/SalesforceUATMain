public class checkIfAuditCaptured_controller {
     public Account acc {get; set;}
     public boolean redirect{get;set;}
     public string url{get;set;}

    public checkIfAuditCaptured_controller(ApexPages.StandardController controller) {
         this.acc = (Account)controller.getRecord();
    }
    
    public PageReference autoRedirectPage(){
        Datetime dtAccountLastAccessed = Datetime.now().addMinutes(-5);
        
        List<Audit__c> lstAudit = [Select Id from Audit__c where Prospect_Customer__c =:acc.Id and Field_Updated__c = 'Record Access Reason' and CreatedDate >= :dtAccountLastAccessed and Updated_By__c =:Userinfo.getUserId()];
        
        if(lstAudit == null || lstAudit.isEmpty())
        {
            redirect = true;
            //Pagereference pageRef = new Pagereference('/apex/AccountViewingReason?id=' + this.acc.Id + '&sfdc.override=1');
            //return pageRef;  
            
            PageReference acctPage = new ApexPages.StandardController(acc).view();
            acctPage.setRedirect(true);
            url = '/apex/AccountViewingReason?id=' + this.acc.Id + '&sfdc.override=1';
            //return acctPage;
        }
        
        if(ApexPages.currentPage().getUrl().contains('sfdcIFrameOrigin'))
       {
            //Redirect to Engage customer summary page
            //System.debug('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/Teller_Core#/customer/customersummary?mode=page&id=' + this.acc.Id);
           // return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/apex/Teller_Core#/customer/customersummary?mode=page&id=' + this.acc.Id);
            redirect = false;
        } 
    
        //do not show the account reason if the user is fcu
        
        Profile p = [select Name from profile where id = :userinfo.getProfileId()];
        
        if(p.name.equalsIgnoreCase('FCU Manager (POST PROFILE REVIEW)') || p.name.equalsIgnoreCase('FCU Staff (POST PROFILE REVIEW)'))
        {
            redirect = false;    
        }
        
        return null;
    }

}