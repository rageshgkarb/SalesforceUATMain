/* ------------------------------------------------------------------------------------------------- */
/* C00233    Submit to Decision Engine                                                               */    
/* ------------------------------------------------------------------------------------------------- */
/* C0359    Web logs                                                                                 */
/* ------------------------------------------------------------------------------------------------- */

public class BAA_Application_Signed_Controller extends HPPBaseEventController
{
    public Opportunity Opp {get;set;}
    public HPP_extended_opportunity__c ExOpp {get;set;}
    public Account Acc {get;set;}

    public string OppId {get;set;}
    public Boolean DeResponce {get;set;}

    public PageReference Setup()
    {
         Opp = [select id, Accountid, General_comments_box__c from opportunity where id=:opportunityId];
        //OppId = ApexPages.currentPage().getParameters().get('OppId');
        //system.debug ( 'This is the oppid A ' + oppid);
        //Opp = [select id, AccountId, General_comments_box__c from opportunity where id=:oppId];    // reinstate above ASAP
        
        ExOpp = [SELECT     Application_form_signed__c, 
                            Documents_Received__c, 
                            All_customer_documents_recieved__c
                 FROM       HPP_Extended_Opportunity__c
                 WHERE      opportunity__c = :opp.Id];
                 
        Acc = [SELECT    Id
                FROM    Account
                WHERE    Id = :Opp.AccountId];
                 
        // IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp,Acc);
        IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp,Acc, 'BAA');    // C0359
        return null;
    }

    public PageReference Complete()
    {
        try
        {
            CompleteEvent();
        }
        catch(Exception ex)
        {
        
        }
        return GoToNextEvent();
    }
    
    public PageReference SubmitToDe()
    {            
        
        //Call decision engine  
            
        Actions.ActionBAADecisionEngine DecisionEngineAction = new Actions.ActionBAADecisionEngine ();
        system.debug ('This is the opp id ' + opp.id);
        IBBEvents.CompleteEventArgs args = DecisionEngineAction.RunAction(opp.id);
        
        system.debug('DEResponse : ' +args.DEResponse.Decision);
        
        
        
        if(args.DEResponse.Decision.equalsIgnoreCase('Failed IN EBS') ||
            args.DEResponse.Decision.equalsIgnoreCase('SYSTEMERROR')) 
            
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'Unfortunately your request to decision engine has been unsuccessful, please contact I.T. Helpdesk and quote the opportunity number as stated above'));
           return null;
        }
        else if(args.DEResponse.Decision.equalsIgnoreCase('ADDRESSMISMATCH') )
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'The address you have entered for the customer could not be found during the credit check. Please check the address on Royal Mail Postcode search. If this error continues to occur, please contact IT on 0121-452-7333'));
           return null;
        }
        else if (!args.DEResponse.Decision.equalsIgnoreCase('REFER') && 
            !args.DEResponse.Decision.equalsIgnoreCase('DECLINE') &&
            !args.DEResponse.Decision.equalsIgnoreCase('SUCCESS') )
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'Unfortunately your request to decision engine has been unsuccessful, please contact I.T. Helpdesk and quote the opportunity number as stated above'));
           return null;
        }
        
            
        DeResponce  = true;
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,'Your request to decision engine has been successful, please complete the event'));
        return null;
    }
    
    public List<Applicant__c> AppAccs
    {
        get
        {            
            List<Applicant__c> tempAccs = [select id,
                                                Prospect_Customer__r.name,
                                                Prospect_Customer__c,
                                                Prospect_Customer__r.firstname,
                                                Prospect_Customer__r.lastname,
                                                Prospect_Customer__r.salutation,
                                                Prospect_Customer__r.Middle_Name__pc,
                                                Prospect_Customer__r.Gender__c,
                                                Prospect_Customer__r.Home_Telephone_No__c,
                                                Prospect_Customer__r.Phone,
                                                Prospect_Customer__r.PersonEmail,
                                                Prospect_Customer__r.IsPersonAccount,
                                                CPF_Relationship__r.Shareholder_Percentage__c,
                                                CPF_Relationship__r.Position_Held__c,
                                                CPF_Relationship__r.Is_Director__c,
                                                CPF_Relationship__r.Is_Shareholder__c,
                                                CPF_Relationship__r.Is_Signatory__c,
                                                Is_Director__c,
                                                Is_ShareHolder__c,
                                                Is_Signatory__c
                                        //from Applicant__c where Opportunity__C=: opportunityId];
                                        from Applicant__c where Opportunity__C=: oppId];
            return tempAccs;
        }
    }
}