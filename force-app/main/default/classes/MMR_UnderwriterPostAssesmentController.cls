public class MMR_UnderwriterPostAssesmentController extends HPPBaseEventController
{
    public AffordabilityResults__c Affordability{get;set;} 
    public Asset_Relationship__c[] IBBAccounts{get;set;}
    public Asset_Relationship__c[] IBBAccountsPipeline{get;set;}
    public Asset_Relationship__c[] IBBAccountsLiability {get;set;}
    public List<Valuation_Notification__c> ValNotifications  {get;set;}
    public Valuation_Report__c ValReport{get;set;}  
    public List<Attachment> atts{get;set;}  
    public HPPEventConditionHelper helper{get;set;}
    public Board_Limits_v1__c Limits{get;set;}
    public List<Credit_Score__c> Credits{get;set;}
    public List<HPPUnderwritingBudgetData> BudgetItems{get;set;}
    private I_BudgetPlannerHelper budgetHelper;

    public MMR_UnderwriterPostAssesmentController ()
    {
         Init();
    }
    
    public String XmlViewerUrl{
        get{
            if(XmlViewerUrl== null)
            {
                XMLViewer__c xml = [select url__c from XMLViewer__c limit 1];
                XmlViewerUrl = xml.url__c;
            }
            return XmlViewerUrl;
        }
        set;
    }
    
    public List<SelectOption> AuthList
    {
        get{
            List<SelectOption> lst = new List<SelectOption>();
            String sAuthLevel = GetAuthLevel();
            Integer iAuthLevel = AuthRank(sAuthLevel );
            lst.add(new SelectOption('','-- Please select --' ));
        if(iAuthLevel <= AuthRank('Underwriter')  )
            lst.add(new SelectOption('Underwriter','Underwriter' ));
        if(iAuthLevel <= AuthRank('Lead Underwriter')  )
            lst.add(new SelectOption('Lead Underwriter','Lead Underwriter' ));
        if(iAuthLevel <= AuthRank('Head of Credit')  )
            lst.add(new SelectOption('Head of Credit','Head of Credit' ));
        if(iAuthLevel <= AuthRank('Managing Director')  )
            lst.add(new SelectOption('Managing Director','Managing Director' ));
        if(iAuthLevel <= AuthRank('Credit Committee')  )
            lst.add(new SelectOption('Credit Committee','Credit Committee' ));
        
            lst.add(new SelectOption('Board Risk Credit Committee','Board Risk Credit Committee' ));
        
        return lst;
        
        }
    }
    
    public PageReference RerunAffordability()
    {
        MMR_Affordability afford = new MMR_Affordability(Opp, ExOpp, prod,IsBTL,BudgetPlannerVersion);
        afford.incomeMultiplier();
        afford.affordabilityCalculation();
        afford.budgetPlanner();
        afford.saveResults();
        LoadAffordibility();
        return null;
    }
    
    public Map<String,String> Status {get;set;} 
    public List<Case> caseList{get;set;}
    private void Init()
    {
        Cases = new Map<String,List<Case>>();
         
         caseList = DataHelper.GetCases(Opp.id);   
        Status = new Map<String,String>();
        RecordType recType =  [select id from recordType where sobjectType='case' and DeveloperName = 'HPP_CAA_CASE' limit 1];
          if(ExOpp.Number_of_cars__c == null)
            ExOpp.Number_of_cars__c = 0;
        for(Account a : Accounts)
        {
            List<Case> caseDetailList = new List<Case>();
            
            for(Case c : caseList)
            {
                if(c.ContactId == a.PersonContactId && c.recordtypeId==recType.id )
                {
                    caseDetailList.add(c);
                }
            }
            
            Cases.put(a.id,caseDetailList );
            Status.put(a.id,'Approved');
        }
    }
    
    private void SaveDECases()
    {
        for(Account a : Accounts)
        {
            List<Case> c = Cases.get(a.id);
            update c;
        }
    }
    
    public PageReference SaveCases()
    {       
        SaveDECases();   
        return null;
    }
    
    public String JsonConditions
    {
        get{
            List<JsonCondition> lstCond = new List<JsonCondition>();
            JsonCondition jco = new JsonCondition();
                jco .id ='';
                jco .template = ' --None-- ';
                jco .Code = '-- None --';
                lstCond.add(jco );
            for(Special_Condition__c v : Helper.conditionsData)
            {
                JsonCondition jc = new JsonCondition();
                jc.id = v.id;
                jc.template = v.Stand_condition__c;
                jc.Code = v.category__c + v.version__c;
                lstCond.add(jc);
            }
            return Json.serialize(lstCond);    
        }
    }    
    
    
    public Integer delFI{get;set;}
    
    public PageReference DeleteFI()
    {
        system.debug('Del FI index : ' + delFI);    
        Case c = PostCases[delFI];        
        delete c;        
        PostCases = [select id,CaseNumber , Further_Information__c, Further_Info_Satisfied__c, underwriter_comments__c, BDM_comments__c,  createddate from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='POST' ];    
        return null;
    }    

    public void LoadAffordibility()
    {
        Affordability = [select GrossAnnualIncomeApplicant1__c,GrossAnnualIncomeApplicant2__c,GrossAnnualIncomeApplicant3__c,GrossAnnualIncomeApplicant4__c,
                                NetMonthlyIncomeApplicant1__c, NetMonthlyIncomeApplicant2__c, NetMonthlyIncomeApplicant3__c, NetMonthlyIncomeApplicant4__c,
                                IncomeMultiplier4_5Total__c, IncomeMultiplier5_1__c, AffordabilityPercentage__c,AffordabilityResult__c, BudgetPlannerSurplusOrDeficit__c
                                ,IncomeMultiplierResult__c ,BudgetPlannerResult__c,TotalCommitments__c ,additionalrentalincome__c ,StressedHPPRepayment__c
                                from AffordabilityResults__c
                         where opportunity__c=:opp.id order by createddate desc limit 1];
    }
    
    public PageReference Setup()
    {
        Limits = [select Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c     from Board_Limits_v1__c order by createddate desc limit 1];
        ValReport = [select id,Property_Type__c,Property_Location_Type__c,Number_of_Bedrooms__c,Number_of_Floors__c,Property_Tenure__c,Rate_Market_Demand_for_Property__c,Unexpired_Term__c,Market_Value_Present_Condition__c,Year_Built__c,Market_Value_After_Repairs_Completion__c 
                     ,Walls__c,Roof__c,Residential_Dwelling__c,Service_Maintenance_Charges__c,Parking__c,How_Many_Parking_Spaces__c,Ground_Rent__c,Garage__c,Floor_Number__c,Fair_Market_Rental_pcm__c,Building_reinstatement_value__c
                from Valuation_Report__c where opportunity__c=:opp.id order by createddate desc  limit 1];
          
       // atts = new List<Attachment>();
       // if(ValREport.size() > 0) 
            atts = [select id, name from attachment where ParentId =:  ValReport.id];
        ValNotifications  = [select id, name, Status__c, General_Comments__c, Date_of_Valuation__c from Valuation_Notification__c where Valuation_Report__r.Opportunity__c =: opp.id ];
    
          LoadAffordibility();
                         
        List<Asset_Relationship__c> tempIBBAccounts = [select Prospect_Customer__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Available_balance__c,
                       Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                      account_with_ibb__r.ibb_product_name__c, Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,Account_with_IBB__r.Opportunity__r.Finance_Required__c
                       from Asset_Relationship__c
                       where  Prospect_Customer__c in :lstAccountIds
                       and    Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                       and Account_with_IBB__r.Opportunity__r.isWon = True
                       and Account_with_IBB__r.Opportunity__c !=:Opp.id
                       ];  
                       
        IBBAccounts = RemoveDuplicateAccounts(tempIBBAccounts);               
                  
        List<Account_With_IBB__c> oldIBBAccounts = [SELECT   Primary_SFDC_Account__c,
                                                             IBB_Product__r.Name,
                                                             Name,
                                                             Available_Balance__c,
                                                             IBB_Product__r.IBB_Product_Set__r.assetorliability__c,
                                                             Primary_SFDC_Account__r.name,
                                                             ibb_product_name__c,
                                                             Primary_SFDC_Account__r.SFDC_ID__c,
                                                             Opportunity__r.StageName,
                                                             Opportunity__r.Finance_Required__c
                                                   FROM      Account_with_IBB__c
                                                   WHERE     Primary_SFDC_Account__c in :lstAccountIds
                                                   AND       IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset'
                                                   AND       Opportunity__c != :Opp.id];
                                                                                           

        List<Asset_Relationship__c> tempIBBAccountsPipeline = [select Prospect_Customer__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Available_balance__c,
                               Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                               Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,Account_with_IBB__r.Opportunity__r.Finance_Required__c
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                                      and Account_with_IBB__r.Opportunity__r.isWon = false
                                      and Account_with_IBB__r.Opportunity__r.IsClosed = false
                                      and Account_with_IBB__r.Opportunity__c !=:Opp.id
                                      and Primary_Account_Holder__c = true
                                      ]; 
                                      
        IBBAccountsPipeline = RemoveDuplicateAccounts(tempIBBAccountsPipeline);                                      
                                      
                                      
                                      
                                      
        List<Asset_Relationship__c> tempIBBAccountsLiability = [select Prospect_Customer__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Available_balance__c,
                               Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                               Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,Account_with_IBB__r.Opportunity__r.Finance_Required__c,
                               Account_with_IBB__r.IBB_product_name__c
                               
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Liability' 
                                      and Account_with_IBB__r.Opportunity__r.isWon = false
                                      and Account_with_IBB__r.Opportunity__r.IsClosed = false
                                      and Account_with_IBB__r.Opportunity__c !=:Opp.id
                                      ];     
        IBBAccountsLiability = RemoveDuplicateAccounts(tempIBBAccountsLiability);
        
        Helper = new HPPEventConditionHelper(Acc,Opp,ExOpp);
        Helper.Load();
        
        // C0635
        if(is_BP_V1)
        {
            budgetHelper = new HPPUnderwrittingBudgetHelper();
        }
        
        if(is_BP_V2)
        {
            budgetHelper = new MMR_BudgetPlanner_V2_Helper();
        } 
        
        if(ExOpp.Budget_Figures__c == null)
        {
            Integer NoDependants  = 0;
            for(Account a: Accounts)
            {
                if(a.No_of_depenents__c != null)
                {
                    NoDependants += 1;
                }  
            }
            ExOpp.Budget_Figures__c = budgetHelper.MinimumText(Accounts.size(),NoDependants  );
            update ExOpp;
        }

        budgetHelper.Load(Opp.id, ExOpp.Number_of_cars__c.intValue(), ExOpp.Budget_Figures__c,IsBTL);
        
        BudgetItems = budgetHelper.Items();
        
        List<Credit_score__c> creds = [select Decision_ID__c, createddate, Prospect_Customer__r.Name from Credit_Score__c where Opportunity__c=:opp.id  ];                            
        
        Credits = new List<Credit_score__c>();
        for(Account a : accounts)
        {
            Credit_score__c score;
            for(Credit_score__c c : creds)
            {
                if(c.Prospect_Customer__c == a.id)
                {
                    if(score != null)
                    {
                        if(c.createddate > score.createddate)
                        {
                            score = c;
                        }
                    }
                    else
                    {
                        score =  c;
                    }
                }
            }
            Credits.add(score);
        }
        
        Limits = [select Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c     from Board_Limits_v1__c order by createddate desc limit 1];
        PreCases = [select id,CaseNumber , Further_Information__c, Further_Info_Satisfied__c, underwriter_comments__c, BDM_comments__c,  createddate from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='PRE' ];
        PostCases = [select id,CaseNumber , Further_Information__c, Further_Info_Satisfied__c, underwriter_comments__c, BDM_comments__c,  createddate from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='POST' ];
        
        
        
        if(PreCases .size()==0)
            PreCases = new List<Case>();  
        if(PostCases .size()==0)
            PostCases = new List<Case>();                                     
                                      
                                                                       
         return null;
    }
    
    public Map<String,List<Case>> Cases{get;set;}
    
     public String JsonCarFields
    {
        get{
            List<String> carBills = new List<string>();
            for(HPPUnderwritingBudgetData item : BudgetItems)
            {
                if(item.item.budgetplannerconfig__r.car_bill__c)
                {
                    carBills.add(item.item.display_name__c);
                }
            }
            return Json.serialize(carBills);
        }
    }
    
    
    public Decimal TotalGross
    {
        get{
            return CheckNull(Affordability.GrossAnnualIncomeApplicant1__c) + CheckNull(Affordability.GrossAnnualIncomeApplicant2__c) + CheckNull(Affordability.GrossAnnualIncomeApplicant3__c) + CheckNull(Affordability.GrossAnnualIncomeApplicant4__c);
        }
    }
    
    public Decimal TotalNet    
    {
        get{
            return CheckNull(Affordability.NetMonthlyIncomeApplicant1__c) + CheckNull(Affordability.NetMonthlyIncomeApplicant2__c)+ CheckNull(Affordability.NetMonthlyIncomeApplicant3__c)+ CheckNull(Affordability.NetMonthlyIncomeApplicant4__c);
        }
    }  
    
    public Decimal CheckNull(Decimal value)
    {
        if(value == null)
            return 0;
        return value;
    }
    
    
//pasted code from detail controller

        public RecordType recTypeCase {
        get {
            if (recTypeCase == null){            
                recTypeCase = [select id from recordType where  sobjectType='case' and DeveloperName = 'Further_Information' limit 1];
            }
            return recTypeCase ;
        }
        set;
    }
   
    public PageReference AddCase()
    {
        Case c = new Case();
        c.recordTypeid = recTypeCase.id ;
        c.Further_Information__c = 'Enter Information';
        c.Opportunity__c = opp.id;
        c.Subject = 'Further information for ' + Opp.Name;
        c.Description = c.Subject;
        c.Priority = 'Medium';
        c.Status = 'Open';
        c.Origin = 'Salesforce';
        c.ContactId =  Accounts[0].PersonContactId ;
        if(Opp.Seller__c != null)
        c.OwnerId = opp.Seller__c;
        c.Pre_or_Post_Case__c= 'POST';
        c.Further_Info_Satisfied__c = 'No';
        
        insert c;
        
        Case newCase = [select id,satisfied__c, casenumber, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where id=:c.id ];
        
        
        PostCases.add(newCase );
        AddFiText ='';
    
        return null;
    }
    
    public PageReference SaveFI()
    {
        Boolean openCases = false;
        for(Case c : PostCases)
        {
            if(c.Further_Info_Satisfied__c == null)
                c.Further_Info_Satisfied__c = 'No';
            
            if(c.Further_Info_Satisfied__c.equalsIgnoreCase('yes'))
            {
                c.status = 'Completed';
            }
            else
            {
                openCases = true;
            }            
        }        
        update PostCases;         

        if(openCases)
            SaveFurtherInfo();
        return null;
    }
    
    public PageReference RemoveCase()
    {
        return null;
    }
    public String AddFiText {get;set;}
    public List<Case> PreCases{get;set;}
    public List<Case> PostCases{get;set;}
    
    public Map<String,String> Values{get;set;}
    
    public class ConditionTemplate
    {
        public String Id{get;set;}
        public String Name{get;set;}
    }
    
    public PageReference Complete()
    {
        return null;
    }
    
    public PageReference Cancel()
    {
        CurrentItem = null;
        return null;
    }
    
    public PageReference Save()
    {
        Special_condition_item__c sci = Helper.GetItem(CurrentItem.id);
        CurrentItem.Save(sci);   
        return null;
    }
    
    public PageReference Hide()
    {
        Special_condition_item__c sci = Helper.GetItem(CurrentItem.id);
        CurrentItem.Save(sci);
        CurrentItem = null;
        return null;
    }
    
    public String SelectedCondition{get;set;}
    
    public List<SelectOption> ConditionList
    {
        get{
            List<SelectOption> lst = new List<SelectOption>(); 
            for(Special_Condition__c v : Helper.conditionsData)
            {
                SelectOption opt = new SelectOption(v.id,  v.name + ' - ' + v.category__c + v.version__c ); 
                lst.add(opt);              
            }
            return lst;
        }    
    }
    
    public Integer delCondition{get;set;}
    public PageReference DeleteCondition()
    {
        HPPEventConditionHelper.ConditionItem item =  Helper.CIList.remove(delCondition);
        Helper.DeleteItem(item.id);
        
        return null;
    }
    
    public Integer edCondition{get;set;}
    public PageReference EditCondition()
    {
        //find condition
        CurrentItem = Helper.CIList[edCondition];            
        return null;
    }
    
    private void SaveFurtherInfo()
    {
        Opp.Stagename = 'Affordability Assesment';
        if(ExOpp.Post_Val_Dec_1__c == null)
        ExOpp.Post_Val_Dec_1_Date__c = Date.today();
        ExOpp.Post_Val_decision_1_underwriter__c = UserInfo.getName();
        ExOpp.Post_Val_Dec_1__c = 'Further Information Required';
        Opp.Status_HPP_CAA__c= 'Affordability Further Information';
        
        update ExOpp;
        update Opp;
    }
    
    private Decimal GetTotalLiability()
    {
        Decimal totalLiability = opp.Finance_required__c;
         
         Asset_Relationship__c[] IBBAccounts = [select Account_with_IBB__r.Available_balance__c 
                       from Asset_Relationship__c
                       where  Prospect_Customer__c in :lstAccountIds
                       and    Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                       and Account_with_IBB__r.Opportunity__r.isWon = True
                       and Account_with_IBB__r.Opportunity__c !=:Opp.id
                       ];                         

        Asset_Relationship__c[] IBBAccountsPipeline = [select Account_with_IBB__r.Opportunity__r.Finance_Required__c
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                                      and Account_with_IBB__r.Opportunity__r.isWon = false
                                      and Account_with_IBB__r.Opportunity__r.IsClosed = false
                                      and Account_with_IBB__r.Opportunity__c !=:Opp.id
                                      and Primary_Account_Holder__c = true
                                      ];
    
        for(Asset_Relationship__c a : IBBAccounts )
        {
            if(a.Account_with_IBB__r.Available_balance__c != null)
                totalLiability += a.Account_with_IBB__r.Available_balance__c;
        }
        
         for(Asset_Relationship__c a : IBBAccountsPipeline)
        {
            if(a.Account_with_IBB__r.Opportunity__r.Finance_Required__c != null)
                totalLiability += a.Account_with_IBB__r.Opportunity__r.Finance_Required__c;
        }
        
        return totalLiability;
    }
        
    public Boolean OutsideAuth
    {
        get{
        
            User u = [select Limit_of_authority__c from user where id=:UserInfo.getUserId() ];
            Integer userRank = AuthRank(u.Limit_of_authority__c);
            
            Integer currentRank = AuthRank(GetAuthLevel());  
            
            system.debug('Current ' + currentRank + ' userrank ' + userRank);
                  
            return currentRank > userRank;
        }
    }
    
    
    public String AuthLevel
    {
        get{
            if(AuthLevel == null)
                AuthLevel = GetAuthLevel();
            return AuthLevel;
        }
        set{}
    }
    
    public Integer AuthRank(string rank)
    {
        if(rank == null)
            return 0;
        if(rank == '')
            return 0;
        if(rank.equalsIgnoreCase('Underwriter'))
            return 1;
        if(rank.equalsIgnoreCase('Lead Underwriter'))
            return 2;
        if(rank.equalsIgnoreCase('Head of Credit'))
            return 3;
        if(rank.equalsIgnoreCase('Managing Director'))
            return 3;
        if(rank.equalsIgnoreCase('Managing Director/Head of Credit'))
            return 3;
        if(rank.equalsIgnoreCase('Credit Committee'))
            return 4;       
        if(rank.equalsIgnoreCase('Board Risk Credit Committee'))
            return 5;              
        return 0;                    
    }
    
    public String GetAuthLevel()
    {
        Decimal totalLiability = GetTotalLiability();
        
        if(totalLiability  <= Limits.Underwriter__c)
            return 'Underwriter';         
        if(totalLiability  <= Limits.Lead_Underwriter__c)
            return 'Lead Underwriter';
        if(totalLiability  <= Limits.Managing_Director__c)
            return 'Managing Director/Head Of Credit';
        if(totalLiability  <= Limits.Credit_Committee__c)
            return 'Credit Committee';
        //if(opp.Finance_required__c > Limits.Board_Risk_Credit_Committee__c)
            return 'Board Risk Credit Committee';
    }

    public HPPEventConditionHelper.ConditionItem CurrentItem{get;set;}
    
    public PageReference AddCondition()
    {        
        if(SelectedCondition == null) return null;
        if(SelectedCondition == '') return null;

    
        Helper.AddCondition(SelectedCondition,'Post');
        return null;
    }   
    
    public PageReference FurtherInformation()
    {
        update ExOpp;
        update Opp;  
        return null;
    }
    
    public PageReference AuthoriseOutside()
    {        
        if(authSelected == null || authSelected == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a limit of authority'));
            return null;
        }
        ExOpp.Limit_of_authority_list__c = authSelected;
        return Auth();
    }
    
    public String authSelected{get;set;}
    public String authSelected1{get;set;}
    
    public PageReference SaveBudget()
    {
        List<Budget_Planner_Item__c > Items = new List<Budget_Planner_Item__c> ();
        for(HPPUnderwritingBudgetData d : BudgetItems)
        {
            if(d.item.credit_value__c != null)
            {
                d.item.value_to_be_used__c = d.item.credit_value__c;
            }
            else
            {
                d.item.value_to_be_used__c  = d.FigureUsed;
            }        
        
            Items.add(d.item); 
        }
        update exopp;
        upsert Items;
        
        RerunAffordability();

        return null;
    }
    
    
    private PageReference Auth()
    {
            if(ExOpp.Underwriter_post_val_decision_rational__c== null || ExOpp.Underwriter_post_val_decision_rational__c=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Valuation Decision Rationale must be entered.'));
            return null;
        }
    
        //Check that all the FI cases are satisfied
        for(Case c : PostCases)
        {
            if(!c.Further_Info_Satisfied__c.equalsIgnoreCase('yes'))
            {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Further information cases need to be satisfied'));
               return null;
            }
        }               
      
        Opp.Stagename = 'Affordability Assesment';
        
        if(ExOpp.Post_Val_Dec_1__c == null)
        {
            ExOpp.Post_Val_Dec_1__c = 'Authorised';
            ExOpp.Post_Val_Dec_1_Date__c = Date.today();
            ExOpp.Post_Val_decision_1_underwriter__c = UserInfo.getName();
        }
        else
        {
            ExOpp.Post_valuation_decision_2__c = 'Authorised';
            ExOpp.Post_valuation_decision_date__c = Date.today();
            ExOpp.Post_Val_decision_2_underwriter__c = UserInfo.getName();
        }

        
        Opp.Status_HPP_CAA__c= 'Affordability Authorised';
        

        

       
        update ExOpp;
    
        update Opp;
        CompleteEvent();        
        return GoToNextEvent(); 
    }
    
    public PageReference Authorise()
    {
        return Auth();
    }
    
    public PageReference Decline()
    {
        Opp.Stagename = 'Affordability Assesment';
        
        if(ExOpp.Post_Val_Dec_1__c == null)
        {
            ExOpp.Post_Val_Dec_1__c = 'Declined';
            ExOpp.Post_Val_Dec_1_Date__c = Date.today();    
            ExOpp.Post_Val_decision_1_underwriter__c = UserInfo.getName();    
        }
        else
        {
            ExOpp.Post_valuation_decision_2__c = 'Declined';
            ExOpp.Post_valuation_decision_date__c = Date.today();   
            ExOpp.Post_Val_decision_2_underwriter__c = UserInfo.getName();     
        }

        
        //Opp.Status_HPP_CAA__c= 'Affordability Declined';
        // CPDR
        Opp.Status_HPP_CAA__c= 'Valuation Declined';
        
        
        update ExOpp;
        
        update Opp;
       return null; 
    }    
    
    
    public class JsonCondition
    {
        public String Id{get;set;}
        public String Template{get;set;}
        public String Code{get;set;}         
    }      
    

}