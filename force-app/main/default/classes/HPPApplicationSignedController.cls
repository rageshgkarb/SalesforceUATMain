public class HPPApplicationSignedController extends HPPBaseEventController
{
    public String RelationshipApp2 {get;set;}
    public String RelationshipApp3 {get;set;}
    public String RelationshipApp4 {get;set;}     
    public Boolean DeResponce {get;set;}
    public Boolean ShowDeButton{get;set;}
    public Boolean ShowBTLIAAFailMessage {get;set;} // C0586
    public Boolean ShowBTLIAAReRunButton {get;set;} // C0586
    public Boolean isIAAReRun {get;set;} //C0586
    public Decimal DeficitInIAA {get;set;} // C0586
   
    public List<SelectOption> getRelationships() {        
        List<SelectOption> options = new List<SelectOption>();
        List<EBS_Relationship__c> relationships = [select code__c, text__c from EBS_Relationship__c order by code__c];
        
        options.add(new SelectOption('','Please select'));
        for(EBS_Relationship__c r :  relationships)
        {
            options.add(new SelectOption(r.Code__c,r.text__c));
        }            

        return options;
    }
   
    public PageReference Setup()
    {
        Logger.Info('Setup Method called');
        
        PageReference pf = CorrectPage('HPPApplicationSigned');
        if(pf != null)
            return pf;
        
        ShowDeButton = false;
        ShowBTLIAAReRunButton = false;  // C0586
        IBBDependentObjectFactory.CreateDecisionEngineStubs(Opp,Acc);
        
        Logger.Save();
        
        return null;
    }
    
    public PageReference DoAffordibility()
    {
        Boolean isIAAReRun = false;
        Boolean error =false;
         /* C0068
        if(!ExOpp.Application_form_signed__c)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'"Has the signed application form been received" must be ticked.'));
           error = true;
        }
        if(!ExOpp.Documents_Received__c)
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'"Has the signed application form been received" must be ticked.'));
            error = true;
        }
        
        if(ExOpp.All_customer_documents_recieved__c > date.today())
        {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'"Date recieved" can not be in the future.'));
            error = true;
        }

        if(error)
            return null;
    */
    
        if(oDirector.IsMMR__c)
        {
            //Call affordability class
            MMR_Affordability afford = new MMR_Affordability(Opp, ExOpp, prod,IsBTL,BudgetPlannerVersion);
            afford.incomeMultiplier();
            afford.affordabilityCalculation();
            afford.useApplicantsBudgetPlanner = true; // C0586 at this stage we should not use 'Value_To_Be_Used__c' as they contain ONS figures
            afford.budgetPlanner();
            //integer i = 1 / 0;
            afford.saveResults();
            // C0586 Start
            if(Opp.Income_Assisted_Application__c == true)
            {
                
                ShowBTLIAAReRunButton=true;
                System.debug('ShowBTLIAAReRunButton='+ShowBTLIAAReRunButton);
            
                DeficitInIAA = afford.IAADeficit;
            }
            else
            {
                if(afford.failedBP && isIAAReRun)
                {
                    // Show Stop message
                    ShowBTLIAAFailMessage = true;
                }
                else
                {
                    ShowDeButton = true;
                }
                
            }
            // C0586 End
            //integer i = 1 / 0;
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

    public PageReference DoReRunAffordibility()
    {
        Boolean isIAAReRun = true;
        
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
            // C0586 Start
            if(Opp.Income_Assisted_Application__c == true && !isIAAReRun)
            {
                ShowBTLIAAReRunButton=true;
                DeficitInIAA = afford.IAADeficit;
            }
            else
            {
                System.debug('Is Re Run: Do not show rerun');
                ShowBTLIAAReRunButton=false;
                if(afford.failedBP && isIAAReRun)
                {
                    // Show Stop message
                    ShowBTLIAAFailMessage = true;
                }
                else
                {
                    ShowDeButton = true;
                }
                
            }
            // C0586 End
            
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
            
        DeResponce  = true;
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,'Your request to decision engine has been successful, please complete the event'));
        return null;
    }
    
    public PageReference Complete()
    {              
        
        Map<String,String> relations = new Map<String,String>();
        if(Opp.Number_of_People_Applying__c >1)
            relations.put(Accounts[1].id,RelationshipApp2 );
        if(Opp.Number_of_People_Applying__c >2)
            relations.put(Accounts[2].id,RelationshipApp3 );
        if(Opp.Number_of_People_Applying__c >3)
            relations.put(Accounts[3].id,RelationshipApp4 );
        
        //C0782 REAC Changes start
        if(!opp.Interested_in__c.Contains('REAC')){
        HPPApplicationSignedHelper helper = new HPPApplicationSignedHelper(Accounts, Opp,Prod,relations  );
        helper.Run();
         }
        //C0782 REAC Changes end
        CompleteEvent();
        return GoToNextEvent();        
    } 
}