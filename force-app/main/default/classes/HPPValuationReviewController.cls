/* ----------------------------------------------------------------------------------------------------- */
/* C0068    New COntroller class                                                                         */
/* ----------------------------------------------------------------------------------------------------- */

public class HPPValuationReviewController extends HPPBaseEventController
{
    public List<Valuation_Notification__c> ValNotifications  {get;set;}
    public Valuation_Report__c ValReport{get;set;}  
    public List<Attachment> atts{get;set;} 
    public Boolean ShowUWButton{get;set;} // C0586
    public Boolean ShowBTLIAAFailMessage {get;set;} // C0586
    public Boolean ShowBTLIAAReRunButton {get;set;} // C0586
    public Boolean isIAAReRun {get;set;} //C0586
    public Decimal DeficitInIAA {get;set;} // C0586
    
    public HPPValuationReviewController ()
    {
        
    }
    
    public PageReference Setup()
    {
        // C0586 Start - Setup BTL Buttons for Affordability 
        // Need to determine whether this is a BTL product
        if (IsBTL) 
        {
            // BTL So set button status
            ShowUWButton = false;
            ShowBTLIAAFailMessage = false;
            ShowBTLIAAReRunButton = false;
        }
        else
        {
            // Non-BTL So set button status
            ShowUWButton = true;
            ShowBTLIAAFailMessage = false;
            ShowBTLIAAReRunButton = false;
        }
        // C0586 Start - Setup BTL Buttons for Affordability 
        
        ValReport = [select id,
                            Property_Type__c,
                            Property_Location_Type__c,
                            Number_of_Bedrooms__c,
                            Number_of_Floors__c,
                            Property_Tenure__c,
                            Rate_Market_Demand_for_Property__c,
                            Unexpired_Term__c,
                            Market_Value_Present_Condition__c,
                            Year_Built__c,
                            MV_of_property__c,//included for C0760
                            Market_Value_After_Repairs_Completion__c 
                           ,Walls__c,Roof__c
                           ,Residential_Dwelling__c
                           ,Service_Maintenance_Charges__c
                           ,Parking__c
                           ,How_Many_Parking_Spaces__c
                           ,Ground_Rent__c
                           ,Garage__c
                           ,Floor_Number__c
                           ,Fair_Market_Rental_pcm__c
                           ,Building_reinstatement_value__c
                    from Valuation_Report__c 
                    where opportunity__c=:opp.id 
                    order by createddate desc  limit 1];
          
       
            atts = [select id
                            , name 
                    from attachment 
                    where ParentId =:  ValReport.id];
                    
            ValNotifications  = [select id
                                        , name
                                        , Status__c
                                        , General_Comments__c
                                        , Date_of_Valuation__c 
                                  from Valuation_Notification__c 
                                  where Valuation_Report__r.Opportunity__c =: opp.id ];
    
        return null;
    }
    
    public PageReference Save()
    {
        update opp;
        UpdateBudgetPlannerWithServiceCharges(); 
        return null;
    }
    //<!-- C0174-->
    public PageReference Complete()
    {
        //CO303 FTI Check
         if(!HPPHelper.CheckFTVIsValid(Opp)) return null;
        if(!HPPHelperFTI.CheckFTIIsValid(Opp)) return null;
        update opp;
        update exopp;
        UpdateBudgetPlannerWithServiceCharges();
        CompleteEvent();
        
        return GoToNextEvent();
        
    }

    // C0635 Need to save BTL Ground Rent / Service Charges at Valuation stage into the Budget Planner
    private void UpdateBudgetPlannerWithServiceCharges()
    {
        MMR_HPPBudgetPlannerHelper helper = new MMR_HPPBudgetPlannerHelper(Opp.Id);
        helper.SaveBTLValuationBPItems(ValReport.Ground_Rent__c,ValReport.Service_Maintenance_Charges__c);
    }

    // C0586 Start - New Methods for IAA Affordability stages

    public PageReference DoAffordibility()
    {
        Boolean isIAAReRun = false;
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
            if(Opp.Income_Assisted_Application__c == true)
            {
                
                ShowBTLIAAReRunButton=true;
                System.debug('VR ShowBTLIAAReRunButton='+ShowBTLIAAReRunButton);
            
                DeficitInIAA = afford.IAADeficit;
                DeficitInIAA.setScale(2);
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
                    ShowUWButton = true;
                }
                
            }
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
            ShowUWButton = true;
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
            if(Opp.Income_Assisted_Application__c == true && !isIAAReRun)
            {
                System.debug('VR - Is Re Run: Show rerun');
                ShowBTLIAAReRunButton=true;
                DeficitInIAA = afford.IAADeficit;
                DeficitInIAA.setScale(2);
            }
            else
            {
                
                ShowBTLIAAReRunButton=false;
                if(afford.failedBP && isIAAReRun)
                {
                    // Show Stop message
                    System.debug('VR - Is Re Run: Failed BP');
                    ShowBTLIAAFailMessage = true;
                }
                else
                {
                    System.debug('VR - Is Re Run: Passed - Show UW Button');
                    ShowUWButton = true;
                }
                
            }

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
            ShowUWButton = true;
        }
        
        return null;
    }

    // C0586 End - New Methods for IAA Affordability stages
    
}