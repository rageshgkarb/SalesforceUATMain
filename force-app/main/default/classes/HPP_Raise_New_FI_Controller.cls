/**********************************************************************************
Class Name: HPP_Raise_New_FI_Controller 
Author: Raiyan
Created Date:
Purpose: This is a controller class for VF page HPP_Raise_New_FI, 
        Used in standard detail page as a link for raising new FI for Credit ops team.
************************************************************************************/ 
public with sharing class HPP_Raise_New_FI_Controller {

    public String retUrl {get;set;}
    public String hppId {get;set;}
    public HPP_Raise_New_FI_Controller(){
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        hppId = ApexPages.currentPage().getParameters().get('caseid');
    }
    /**********************************************************************************
    Method Name: updateHpp
    Purpose: Update the FI date with today's date and all othe credit opd team fielss values to null
             As the details are refreshed for new FI
             Create a new date change record for the newly raised FI
    *********************************************************************************** */
    public PageReference updateHpp(){
        PageReference retPage = new PageReference(retUrl);
        
        HPP_extended_opportunity__c hpp = [SELECT id,FI_ID__c,Raise_New_FI_Request__c,Opportunity__c,Opportunity__r.name,SS_Most_Recent_F_I_Received_Cust__c,FI_Assed_date__c,SLA_Sales_Support__c FROM HPP_extended_opportunity__c WHERE id=:hppId LIMIT 1];
        
        if(!hpp.Raise_New_FI_Request__c.containsIgnoreCase('cannot raise')){
            system.debug('****'+hpp);
            
            
            HPP_EXT_Opp_Date_changes__c dateChange = new HPP_EXT_Opp_Date_changes__c();            
            dateChange.SS_Most_Recent_F_I_Received_Cust__c = Date.Today();
            dateChange.User_Modified_by__c = UserInfo.getUserName();
            dateChange.Opportunity__c = Hpp.Opportunity__c;
            dateChange.HPP_extended_opportunity__c = hpp.id;
            dateChange.Opportunity_name__c = hpp.Opportunity__r.name;
            dateChange.FI_Request_ID__c = hpp.FI_ID__c + 1;
            dateChange.SS_Most_Recent_F_I_Received_Cust__c = date.today();
            dateChange.F_I_Received_Cust_Modified_date__c  = system.now();
            insert dateChange;
            
            hpp.SS_Most_Recent_F_I_Received_Cust__c = Date.Today();            
            hpp.SLA_Sales_Support__c  = null;            
            hpp.FI_Assed_date__c = null;
            
            try{
                update hpp;
            }catch(exception e){ system.debug('*****exception while updating hpp:'+e.getMessage());}
            
        }
        
        return retPage;
    }

}