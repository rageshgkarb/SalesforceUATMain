public class HPPEventSatisfySpecialCondition extends HPPBaseEventController
{
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
            
            Logger.Trace('Special condition team : ' + u.Special_Condition_Team__c);
            if(u.Special_Condition_Team__c  == null)
                return false;
            
            if(u.Special_Condition_Team__c.equalsIgnoreCase('underwriting'))
                return true;
            
            Logger.Trace('Reat allowed : ' + CurrentItem.Reat_Allowed );
            return CurrentItem.Reat_Allowed & u.Special_Condition_Team__c.equalsIgnoreCase( 'reat');
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
    
    public PageReference Setup()
    {
        Helper = new HPPEventConditionHelper(Acc,Opp,ExOpp);
        Helper.Load();

  
        
        return null;
    }
       
}