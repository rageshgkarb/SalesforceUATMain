/* --------------------------------------------------------------------------------------------------------- */
/* C0066                                                                                                     */
/* --------------------------------------------------------------------------------------------------------- */


public with sharing class RedirectCE
{
    public Boolean redirectPage {get; set;}
    private sObject record;
    ApexPages.StandardController std;
    ApexPages.StandardSetController stdSet;
    
    public RedirectCE(ApexPages.StandardController controller) 
    {
        this.std = controller;
        this.record = (sObject)controller.getRecord();
        system.debug(' record='+record);
        Id id = record.Id;
    }

    public RedirectCE(ApexPages.StandardSetController controller) 
    {
        this.stdSet = controller;
        //this.record = (sObject)controller.getRecord();
        //system.debug(' record='+record);
        //Id id = record.Id;
    }
    
    public String getProfileName()
    {
        String ProfileID = userInfo.getProfileId();
        
        Profile p = [select Name from Profile where Id = :ProfileId limit 1];
        return p.Name;
    }
    
    private Boolean notPortalUser()
    {
        boolean npu = false;
        
        if ( getProfileName() != 'External Flow & IFM Partner User' )
        {
            npu = true;
        }
        
        return npu;
    }    
    
    public PageReference redirectListPage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            //pageRef = new Pagereference('/' + record.Id + '/e?nooverride=1&retURL=%2F' + record.Id+ '%3Fnooverride%3D1');
        }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }
    
    public PageReference redirectEditPage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/' + record.Id + '/e?nooverride=1&retURL=%2F' + record.Id+ '%3Fnooverride%3D1');
        }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }
    
    public PageReference redirectAccountListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/001?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
        
    }
    
    public PageReference redirectOpportunityListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/006?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
        
    }
    
     public PageReference redirectAccountIBBListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/a0s?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectAccountIBBTabPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/a0s/o?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectViewPage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/' + record.Id + '?nooverride=1'); 
        }
       // else
       // {
       //    redirectPage = true;
       //     pageRef = new Pagereference('/secur/logout.jsp'); 
       // }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }
    
    public PageReference redirectDeletePage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            
//https://[instance].salesforce.com/setup/own/deleteredirect.jsp?delID=[recordID]
            pageRef = new Pagereference('/' + record.Id + '/o?nooverride=1');
            PageReference d = std.delete();
            system.debug(' from std delete='+d); 
        }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }
    
    /* C0066 start */
    
    public PageReference redirectCaseListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/500?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectContactListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/003?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectIBBProductListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/a0m?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectIBBProductSetListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/a0k?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectIBBProductSuitabilityListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/a0l?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    public PageReference redirectCreditScoreListPage()
    {
         Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {       
            redirectPage = true;
            pageRef = new Pagereference('/a0x?nooverride=1'); 
        }
            System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;     
    }
    
    /* C0066 end */

     /*   
    public PageReference redirectAccountViewPage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {
            Account acc = (Account)record;
        
            redirectPage = true;
            pageRef = new Pagereference('/' + acc.Id + '?nooverride=1'); 
        }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }

  
    public PageReference redirectAccountDeletePage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {
            Account acc = (Account)record;
        
            redirectPage = true;
            pageRef = new Pagereference('/' + acc.Id + '/d?nooverride=1'); 
        }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }

  
    public PageReference redirectOpportunityEditPage()
    {
        Pagereference pageRef = null;
        
        if ( notPortalUser() )
        {
            Opportunity opp = (Opportunity)record;
        
            redirectPage = true;
            pageRef = new Pagereference('/' + opp.Id + '/e?nooverride=1'); 
        }
        System.debug('## redirectPage : ' + redirectPage);
        
        return pageRef;
    }
    */
    
    /*
account_with_IBB__C  
Web_Integration_Logs__C
Leads
Contacts
IBB_Product__c
IBB_Product_Set__c
IBB_PRoduct_Suitability__c
XML_Message__c
*/
    
}