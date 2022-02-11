/* --------------------------------------------------------------------------------------- */
/* C00227 Create event logs for adhoc events  - LB                                         */
/* --------------------------------------------------------------------------------------- */

public class HPP2ndCreditCheck extends HPPBaseEventController
{
    public List<Credit_Score__c > Credits{get;set;}
    
    public PageReference Setup()
    {
        LoadCreditScores();
         IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp,Acc);
        return null;
    }
    
    private void LoadCreditScores()
    {
        Credits =  [select Decision_ID__c, Decision__c, createddate, Prospect_Customer__r.Name from Credit_Score__c where Opportunity__c=:opp.id order by createddate desc ];           
    }

    public boolean RotAcceptable
    {
        get{
            return true;
            //return ExOpp.ROT_acceptable__c == 'Yes';
        }
    }
    
    public boolean Allow2ndCreditCheck
    {
        get{
            if(Exopp.Second_credit_check__c  != null)
                return false;
            
            return RotAcceptable;
        }
    }
    
    public PageReference CallCredit()
    {
          Actions.ActionSecondDecisionEngine DecisionEngineAction= new Actions.ActionSecondDecisionEngine();
         IBBEvents.CompleteEventArgs args = DecisionEngineAction.RunAction(opp.id);
        
        system.debug('DEResponse : ' +args.DEResponse.Decision);
        
        
        
        if(args.DEResponse.Decision.equalsIgnoreCase('Failed IN EBS') ||
            args.DEResponse.Decision.equalsIgnoreCase('SYSTEMERROR'))
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'Unfortunately your request to decision engine has been unsuccessful, please contact I.T. Helpdesk and quote the opportunity number as stated above'));
           return null;
        }    
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,'Your request to decision engine has been successful : ' + args.DEResponse.Decision));
        
        LoadCreditScores();
        ExOpp.Second_credit_check__c = Date.Today();
        ExOpp.Second_credit_check_decision__c  = args.DEResponse.Decision;
        update exopp;
        
        //CP00227 Start
        IBBEvents.CreateAdhocEvent(OppId,'Adhoc 2nd Credit Check');
        //CP00227 End
        return null;
    }

}