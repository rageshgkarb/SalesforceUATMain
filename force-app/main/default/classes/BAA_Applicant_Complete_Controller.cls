public class BAA_Applicant_Complete_Controller extends HPPBaseEventController
{
    public Opportunity Opp{get;set;}
    
    public PageReference Setup()
    {
        Opp = [select id, General_comments_box__c from opportunity where id=:opportunityId];
        return null;
    }

    public PageReference Complete()
    {
        try
        {
            List<Applicant__c> applicants= [select id,Applicant_Number__c
                        from Applicant__c where Opportunity__C=: opportunityId and  Applicant_Number__c != 1];
        
            Integer i = 2;
            for(Applicant__c applicant : applicants)
            {
                applicant.Applicant_Number__c = i;
                i++;
            }
            update applicants;
        
            update opp;
            CompleteEvent();
        }
        catch(Exception ex)
        {
            throw ex;
        }
        return GoToNextEvent();
    }
    
    public List<Applicant__c> AppAccs{
        get{            
            List<Applicant__c> tempAccs = [select id,Prospect_Customer__r.name,Prospect_Customer__c,Prospect_Customer__r.firstname,Prospect_Customer__r.lastname,Prospect_Customer__r.salutation, Prospect_Customer__r.Middle_Name__pc,
                        Prospect_Customer__r.Gender__c, Prospect_Customer__r.Home_Telephone_No__c, Prospect_Customer__r.Phone, Prospect_Customer__r.PersonEmail, Prospect_Customer__r.IsPersonAccount,
                        CPF_Relationship__r.Shareholder_Percentage__c, CPF_Relationship__r.Position_Held__c , CPF_Relationship__r.Is_Director__c ,CPF_Relationship__r.Is_Shareholder__c ,CPF_Relationship__r.Is_Signatory__c,
                        Is_Director__c, Is_ShareHolder__c, Is_Signatory__c 
                        from Applicant__c where Opportunity__C=: opportunityId];
            return tempAccs;
        }
    }
}