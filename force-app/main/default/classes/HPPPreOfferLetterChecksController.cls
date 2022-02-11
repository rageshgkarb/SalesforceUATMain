public class HPPPreOfferLetterChecksController extends HPPBaseEventController
{
    public PageReference Setup()
    {
        OppFields = [select name, apiname__c, editable__c from PreCheckFields__c where objectname__C = 'Opp' order by order__c ];
        ExOppFields = [select name, apiname__c, editable__c from PreCheckFields__c where objectname__C = 'ExOpp' order by order__c ];
        AccFields = [select name, apiname__c, editable__c from PreCheckFields__c where objectname__C = 'Acc' order by order__c ];
        Helper = new HPPEventConditionHelper(Acc,Opp,ExOpp);
        Helper.Load();

		IsBTLLTD=opp.ProductSubType__c=='LC' ? true : false; // C0644 Need to avoid Business Accounts on the page so set a flag for us to check
    
        return null;
    }
    
    public PageReference complete() 
    {
        update opp;
        update exopp;
        update accounts;
        
        return null;
    
        
        /*CompleteEvent();
        PageReference pageRef = null;
    
        if(CreatedEvent != null) {
             pageRef = new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
        }
        return pageRef;
        */
    }
   
    
    public List<PreCheckFields__c> OppFields{get;set;}
    public List<PreCheckFields__c> ExOppFields{get;set;}
    public List<PreCheckFields__c> AccFields{get;set;}
	public Boolean IsBTLLTD {get; set;}


      public HPPEventConditionHelper helper{get;set;}
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
    
     public PageReference Cancel()
    {
        CurrentItem = null;
        return null;
    }
    
    public Boolean CanEdit
    {
        get{
            User u = [select Special_Condition_Team__c from user where id=:UserInfo.getUserId() ];
            
            if(u.Special_Condition_Team__c  == null)
                return false;
            
            if(u.Special_Condition_Team__c.equalsIgnoreCase('underwriting'))
                return true;
            
            return CurrentItem.UW_Allowed & u.Special_Condition_Team__c.equalsIgnoreCase( 'reat');
        }
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
    
    public Integer delCondition{get;set;}
    public PageReference DeleteCondition()
    {
        HPPEventConditionHelper.ConditionItem item =  Helper.CIList.remove(delCondition);
        Helper.DeleteItem(item.id);
        
        return null;
    }
    
     public HPPEventConditionHelper.ConditionItem CurrentItem{get;set;}
     public Integer edCondition{get;set;}
    public PageReference EditCondition()
    {
        //find condition
        CurrentItem = Helper.CIList[edCondition];            
        return null;
    }
    public PageReference AddCondition()
    {
        Helper.AddCondition(SelectedCondition,'');
        return null;
    }       
    

}