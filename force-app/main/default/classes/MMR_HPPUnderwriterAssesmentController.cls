public class MMR_HPPUnderwriterAssesmentController extends HPPBaseEventController
{
    public AffordabilityResults__c Affordability{get;set;} 
    public Asset_Relationship__c[] IBBAccounts{get;set;}
    public Asset_Relationship__c[] IBBAccountsPipeline{get;set;}
    public Asset_Relationship__c[] IBBAccountsLiability {get;set;}
    public HPPEventConditionHelper helper{get;set;}
    public List<Credit_Score__c> Credits{get;set;}
    public List<Case> caseList{get;set;}

    private I_BudgetPlannerHelper budgetHelper;
    
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
    
    public Board_Limits_v1__c Limits{get;set;}
    
    public PageReference RerunAffordability()
    {
        MMR_Affordability afford = new MMR_Affordability(Opp, ExOpp, prod, IsBTL,BudgetPlannerVersion);
        afford.incomeMultiplier();
        afford.affordabilityCalculation();
        afford.budgetPlanner();
        afford.saveResults();
        LoadAffordibility();
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
    
    private void Init()
    {
        Cases = new Map<String,List<Case>>();
         
         caseList = DataHelper.GetCases(Opp.id);   
        Status = new Map<String,String>();
        RecordType recType =  [select id from recordType where sobjectType='case' and DeveloperName = 'HPP_CAA_CASE' limit 1];
        
        if(ExOpp.Number_of_cars__c == null)
        {
            ExOpp.Number_of_cars__c = 0;
            Decimal numCar = 0;
            for(account a: accounts)
            {
                if(a.number_of_cars__c != null)
                {
                    ExOpp.Number_of_cars__c += a.number_of_cars__c ;
                }
            }
        }
        
        for(Account a : Accounts)
        {
            List<Case> caseDetailList = new List<Case>();
            
            for(Case c : caseList)
            {
                if(c.ContactId == a.PersonContactId && c.recordtypeId==recType.id)
                {
                    caseDetailList.add(c);
                }
            }            
            Cases.put(a.id,caseDetailList );
            Status.put(a.id,'Approved');
        }
    }
    
    
    public MMR_HPPUnderwriterAssesmentController()
    {
        Init();
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
                jc.Code = v.Category__c + v.version__c;
                lstCond.add(jc);
            }
            return Json.serialize(lstCond);    
        }
    }
    
    public List<HPPUnderwritingBudgetData> BudgetItems{get;set;}
    
    
    public void SetupIBBAccounts()
    {
        List<Asset_Relationship__c> tempIBBAccounts = [select Prospect_Customer__c,Account_with_IBB__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Available_balance__c,
                       Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                      Account_with_IBB__r.IBB_Product_Name__c , Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,Account_with_IBB__r.Opportunity__r.Finance_Required__c
                       from Asset_Relationship__c
                       where  Prospect_Customer__c in :lstAccountIds
                       and    Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Asset' 
                       and Account_with_IBB__r.Opportunity__r.isWon = True
                       and Account_with_IBB__r.Opportunity__c !=:Opp.id
                       ];   
        IBBAccounts = RemoveDuplicateAccounts(tempIBBAccounts);
    }
    
    public void SetupIBBAccountsPipeline()
    {
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
    }
    
    public void SetupIBBAccountsLiability()
    {
        List<Asset_Relationship__c> tempIBBAccountsLiability = [select Prospect_Customer__c, Account_with_IBB__r.IBB_Product__r.Name, Account_with_IBB__r.name, Account_with_IBB__r.Available_balance__c,
                               Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c, Prospect_Customer__r.name,
                               Prospect_Customer__r.SFDC_ID__c,  Account_with_IBB__r.Opportunity__r.StageName,//Account_with_IBB__r.Opportunity__r.Finance_Required__c,
                               Account_with_IBB__r.IBB_product_name__c                               
                               from Asset_Relationship__c
                               where  Prospect_Customer__c in : lstAccountIds
                                      and Account_with_IBB__r.IBB_Product__r.IBB_Product_Set__r.assetorliability__c = 'Liability' ];    

        IBBAccountsLiability = RemoveDuplicateAccounts(tempIBBAccountsLiability);                                      
    }
    
    
    public PageReference Setup()
    {
        Limits = [select Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c     from Board_Limits_v1__c order by createddate desc limit 1];
                                
        SetupIBBAccounts();
        SetupIBBAccountsPipeline();
        SetupIBBAccountsLiability();
                                       
        List<Credit_score__c> creds = [select Decision_ID__c, createddate, Prospect_Customer__r.Name from Credit_Score__c where Opportunity__c=:opp.id  ];                            
        
        
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
                    NoDependants += a.No_of_depenents__c.intValue();
                }  
            }
            ExOpp.Budget_Figures__c = budgetHelper.MinimumText(Accounts.size(),NoDependants  );
            update ExOpp;
        }
        
        budgetHelper.Load(Opp.id, ExOpp.Number_of_cars__c.intValue(), ExOpp.Budget_Figures__c,IsBTL);
        BudgetItems = budgetHelper.Items();
        
        List<Budget_Planner_Item__c> items = new List<Budget_Planner_Item__c>();
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
            items.add(d.item);
        }
                
        update items;
        
        RerunAffordability();
        
        budgetHelper.Load(Opp.id, ExOpp.Number_of_cars__c.intValue(), ExOpp.Budget_Figures__c,IsBTL);
        BudgetItems = budgetHelper.Items();
        
        LoadAffordibility();
        
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
        
        Helper = new HPPEventConditionHelper(Acc,Opp,ExOpp);
        Helper.Load();
        Limits = [select Board_Risk_Credit_Committee__c,Credit_Committee__c,Managing_Director__c,Lead_Underwriter__c, Underwriter__c     from Board_Limits_v1__c order by createddate desc limit 1];
        FiCases = [select CaseNumber, id,satisfied__c, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='PRE' ];
        
        if(Ficases.size()==0)
            FiCases = new List<Case>();
                                                                       
        return null;
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
        c.Pre_or_Post_Case__c='PRE';
        c.Further_Info_Satisfied__c = 'No';
        insert c;
        
        Case newCase = [select id,satisfied__c, casenumber, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where id=:c.id ];
        FiCases.add(newCase);
        AddFiText ='';
        SaveFurtherInfo();
        return null;
    }
    
    public PageReference SaveFI()
    {
        Boolean openCases = false;
        for(Case c : FiCases)
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
        update FiCases;         

        if(openCases)
            SaveFurtherInfo();
        return null;
    }
    
    public PageReference RemoveCase()
    {
        return null;
    }
    public String AddFiText {get;set;}
    public List<Case> FiCases{get;set;}
    
    public Map<String,String> Values{get;set;}
    
   /* public class ConditionTemplate
    {
        public String Id{get;set;}
        public String Name{get;set;}
    }*/
    
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
    public Integer delFI{get;set;}
    
    public PageReference DeleteFI()
    {
        system.debug('Del FI index : ' + delFI);
    
        Case c = FICases[delFI];
        
        delete c;
        
        FiCases = [select CaseNumber, id,satisfied__c, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='PRE' ];
    
        
        return null;
    }
    
    
    
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
        
        
        if(ExOpp.Pre_Val_1_Date__c == null)
        ExOpp.Pre_Val_1_Date__c = Date.today();
        ExOpp.Pre_Val_decision_1_underwriter__c = UserInfo.getName();
        
        ExOpp.Pre_Val_Dec_1__c = 'Further Information Required';        
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
        if(rank.equalsIgnoreCase( 'Lead Underwriter'))
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
    
    public Decimal totalLib
    {
        get{
        return GetTotalLiability();
        }
    }
    
    public String GetAuthLevel()
    {
        Decimal totalLiability = GetTotalLiability();
        
        if(totalLiability  <= Limits.Underwriter__c)
            return 'Underwriter';         
        if(totalLiability  <= Limits.Lead_Underwriter__c)
            return 'Lead Underwriter';
        if(totalLiability  <= Limits.Managing_Director__c)
            return 'Managing Director/Head of Credit';
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
        Helper.AddCondition(SelectedCondition,'Pre');
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
        if(authSelected == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please select a limit of authority'));
            return null;
        }
        ExOpp.Limit_of_authority_list__c = authSelected;
        return Auth();
    }
    
    public String authSelected{get;set;}
    public String authSelected1{get;set;}
    
    private PageReference Auth()
    {
        if(ExOpp.Underwriter_pre_val_decision_rational__c == null || ExOpp.Underwriter_pre_val_decision_rational__c=='')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Valuation Decision Rationale must be entered.'));
            return null;
        }    
    
        //Check that all the FI cases are satisfied
        for(Case c : FiCases)
        {
            if(c.Further_Info_Satisfied__c == null)
                c.Further_Info_Satisfied__c = 'No';
        
            if(!c.Further_Info_Satisfied__c.equalsIgnoreCase('yes'))
            {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Further information cases need to be satisfied'));
               return null;
            }
        }              
       
       if(ExOpp.Pre_Val_Dec_1__c == null)
       {
            ExOpp.Pre_Val_Dec_1__c = 'Authorised';
            ExOpp.Pre_Val_1_Date__c = Date.today();
            ExOpp.Pre_Val_decision_1_underwriter__c = UserInfo.getName();
       }
        else
        {
            ExOpp.Pre_Val_Dec_2__c = 'Authorised';
            ExOpp.Pre_Val_2_Date__c = Date.today();
            ExOpp.Pre_Val_decision_2_underwriter__c = UserInfo.getName();       
        }                      
        update ExOpp;
        update Opp;
        CompleteEvent();        
        if(CreatedEvent != null)
        {                  
             PageReference pageRef = null;
             return new PageReference(NextEventUrl)  ;
        }        
        return null;
    }
    
    public PageReference Authorise()
    {
        if(ExOpp.Underwriter_pre_val_decision_rational__c == null ||  ExOpp.Underwriter_pre_val_decision_rational__c == '')        
        {
            ExOpp.Underwriter_pre_val_decision_rational__c.addError('Please enter a value');
            return null;
        }
    
        return Auth();
    }
    
    public PageReference Decline()
    {
        if(ExOpp.Underwriter_pre_val_decision_rational__c == null ||  ExOpp.Underwriter_pre_val_decision_rational__c == '')        
        {
            ExOpp.Underwriter_pre_val_decision_rational__c.addError('Please enter a value');
            return null;
        }
    
        if(ExOpp.Pre_Val_Dec_1__c == null)
        {
            ExOpp.Pre_Val_Dec_1__c = 'Declined';
            ExOpp.Pre_Val_1_Date__c = Date.today();
            ExOpp.Pre_Val_decision_1_underwriter__c = UserInfo.getName();
        }
        else
        {
            ExOpp.Pre_Val_Dec_2__c = 'Declined';
            ExOpp.Pre_Val_2_Date__c = Date.today();  
            ExOpp.Pre_Val_decision_2_underwriter__c = UserInfo.getName();      
        }
        
        //CPDR
        Opp.Status_HPP_CAA__c = 'Affordability Declined';
        
        update ExOpp;
        update Opp;
       // CompleteEvent();        
       // return GoToNextEvent(); 
       return null;
    }    
    
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
        
        
        
        if(is_BP_V1)
        {
            budgetHelper = new HPPUnderwrittingBudgetHelper();
        }
        
        if(is_BP_V2)
        {
            budgetHelper = new MMR_BudgetPlanner_V2_Helper();
        }
        budgetHelper.Load(Opp.id,ExOpp.Number_of_cars__c.intValue(),ExOpp.Budget_Figures__c,IsBTL);
        
        BudgetItems = budgetHelper.Items();
        //update BudgetItems ;
        
        
        List<Budget_Planner_Item__c > Items1 = new List<Budget_Planner_Item__c> ();
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
        
            Items1.add(d.item); 
        }
        update Items1;        
        
        RerunAffordability();
        
        return null;
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
    
    public Map<String,List<Case>> Cases{get;set;}
    public Map<String,String> Status {get;set;} 
    
    
    public class JsonCondition
    {
        public String Id{get;set;}
        public String Template{get;set;}
        public String Code{get;set;}         
    }
    
   /*   public class CaseDetail
    {
        public String id{get;set;}
        public String CaseNumber {get;set;}
        public String Subject{get;set;}
        public String Detail{get;set;}
        public String Owner{get;set;}
        public String Decision{get;set;}
        public String Comment{get;set;}
        public String Satisfied{get;set;}
        public String CreditComments {get;set;}
        public String CreditAccepted{get;set;}
    }  
    */

}