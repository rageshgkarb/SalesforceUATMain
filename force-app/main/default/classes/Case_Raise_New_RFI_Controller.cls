/**********************************************************************************
Class Name: Case_Raise_New_RFI_Controller 
Author: Raiyan
Created Date:
Purpose: This is a controller class for VF page Case_Raise_New_RFI, 
        Used in standard detail page as a link for raising new RFI for KYC team.
************************************************************************************/ 
public with sharing class Case_Raise_New_RFI_Controller {

    public String retUrl {get;set;}
    public String caseId {get;set;}
    public Case_Raise_New_RFI_Controller(){
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        caseId = ApexPages.currentPage().getParameters().get('caseid');
    }
    /**********************************************************************************
    Method Name: updateCase
    Purpose: Update the RFI date with today's date and all othe KYC team fiels values to null
             As the details are refreshed for new RFI
             Create a new date change record for the newly raised RFI
    ************************************************************************************/
    public PageReference updateCase(){
        PageReference retPage = new PageReference(retUrl);
        
        case cs = [SELECT id,Accountid,Raise_New_RFI_Request__c,SLA_Duration_KYC__c,Most_recent_RFI_raised_date__c,Most_recent_RFI_received_date__c,RFI_Assessed_Date__c,RFI_ID__c,Reason__c FROM case WHERE id=:caseId LIMIT 1];
        
        if(!cs.Raise_New_RFI_Request__c.containsIgnoreCase('cannot raise')){
            system.debug('****'+cs);
            
            
            Case_Date_Chnages__c dateChange = new Case_Date_Chnages__c();            
            dateChange.Most_recent_RFI_raised_date__c = Date.Today();
            dateChange.User_Modified_by__c = UserInfo.getUserName();
            dateChange.Account__c = cs.Accountid;
            dateChange.Case__c = cs.id;
            dateChange.RFI_ID__c = cs.RFI_ID__c + 1;
            dateChange.Reason__c = cs.Reason__c ;
            insert dateChange;
            
            cs.Most_recent_RFI_raised_date__c= Date.Today();
            
            cs.SLA_Duration_KYC__c = null;
            cs.Most_recent_RFI_received_date__c = null;
            cs.RFI_Assessed_Date__c   = null;
            //cs.Reason__c = null;
            try{
                update cs;
            }catch(exception e){ system.debug('*****exception while updating case:'+e.getMessage());}
            
        }
        
        return retPage;
    }

}