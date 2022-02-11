/***************/
/*  C0644      */
/***************/
public class HPP_BTLLC_ApplicationSignedController extends HPPBaseEventController
{
    public Boolean DeResponse {get;set;}
    public Boolean ShowDeButton{get;set;}
	   
    public string getRelationship() {        

        // With BTLLC, All Applicants must be Directors so default relationship to Director
		string  rel ='';
		List<EBS_Relationship__c> relationships = [select code__c, text__c from EBS_Relationship__c where text__c='Director' order by code__c];
        if(relationships.size()>0)
		{
			rel=relationships[0].code__c;
		}
        return rel;
    }
    
    public PageReference Setup()
    {
        PageReference pf = CorrectPage('HPP_BTLLC_ApplicationSigned');
        if(pf != null)
            return pf;
        
        ShowDeButton = false;
		

        IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp,Acc);
        
        Logger.Save();
        
        return null;
    }
    
    public PageReference DoAffordibility()
    {
        Boolean error =false;
    
        if(oDirector.IsMMR__c)
        {
            //Call affordability class
            MMR_Affordability afford = new MMR_Affordability(Opp, ExOpp, prod,IsBTL,BudgetPlannerVersion);
            afford.incomeMultiplier();
            afford.affordabilityCalculation();
            afford.useApplicantsBudgetPlanner = true; // C0586 at this stage we should not use 'Value_To_Be_Used__c' as they contain ONS figures
            afford.budgetPlanner();
            afford.saveResults();

            if(afford.failedBP)
            {
                // Show Stop message
                ShowDeButton = false;
            }
            else
            {
                ShowDeButton = true;
            }
        }
        else
        {
            //Call affordability class
            Affordability afford = new Affordability(Opp, ExOpp, prod);
            afford.incomeMultiplier();
            afford.affordabilityCalculation();
            afford.budgetPlanner();
            afford.saveResults();
            ShowDeButton = true;
        }
        
        return null;
    }

    public PageReference SubmitToDe()
    {            
    
		//CO303 FTI Check
		if(!HPPHelperFTI.CheckFTIIsValid(Opp)) return null;
      
        //Call decision engine  
            
        Actions.ActionDecisionEngine DecisionEngineAction= new Actions.ActionDecisionEngine ();
        IBBEvents.CompleteEventArgs args = DecisionEngineAction.RunAction(opp.id);
        
        system.debug('DEResponse : ' +args.DEResponse.Decision);
        
        
        
        if(args.DEResponse.Decision.equalsIgnoreCase('Failed IN EBS') ||
            args.DEResponse.Decision.equalsIgnoreCase('SYSTEMERROR'))
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'Unfortunately your request to decision engine has been unsuccessful, please contact I.T. Helpdesk and quote the opportunity number as stated above'));
           return null;
        }
        if(args.DEResponse.Decision.equalsIgnoreCase('ADDRESSMISMATCH') )
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'The address you have entered for the customer could not be found during the credit check. Please check the address on Royal Mail Postcode search. If this error continues to occur, please contact IT on 0121-452-7333'));
           return null;
        }
            
        DeResponse  = true;
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,'Your request to decision engine has been successful, please complete the event'));
        return null;
    }
    
    public PageReference Complete()
    {              
        string rel = getRelationship();
		Map<String,String> relations = new Map<String,String>();
        if(Opp.Number_of_People_Applying__c >1)
            relations.put(Accounts[1].id,rel );
        if(Opp.Number_of_People_Applying__c >2)
            relations.put(Accounts[2].id,rel );
        if(Opp.Number_of_People_Applying__c >3)
            relations.put(Accounts[3].id,rel );
		if(Opp.Number_of_People_Applying__c >4)
            relations.put(Accounts[4].id,rel );
		
		HPPApplicationSignedHelper helper = new HPPApplicationSignedHelper(Accounts, Opp,Prod,relations);
        helper.Run();
        
        CompleteEvent();
        return GoToNextEvent();        
    } 
}