public class HPPBaseEventHelper
{
    public enum EventType
    {
        HPP,
        BAA,
        MMR
    }
    
    private static Set<String> HPP_ProductSets = new Set<String>{'Buy To Let Purchase Plan','Home Purchase Plan Premier','Home Purchase Plan','Home Purchase Scotland'};
    
    
    //Work out the type of application from the director
    public static  EventType GetEventType(string directorBaseController)
    {
        List<EventType> values = EventType.values();
    
        for(EventType et : values)
        {
           if(et.Name().equalsIgnoreCase(directorBaseController))
            return et; 
        }
    
        return EventType.HPP;
    }

    public static Opportunity LoadOpportunity(EventType evType, string opportunityId)
    {
        system.debug('Type:' + evType);
        
        if(evType == EventType.HPP)
            return HPPOpportunity(opportunityId);
    
        if(evType == EventType.MMR)
            return MMROpportunity(opportunityId);
            
        if(evType == EventType.BAA)
            return BAAOpportunity(opportunityId);
        
        
        return null;
    }    
    
    private static  Opportunity HPPOpportunity(string opportunityId)
    {
        return DataHelper.GetOpportunity(opportunityId)[0];
    }
    
    private static  Opportunity MMROpportunity(string opportunityId)
    {
        return DataHelper.GetOpportunity(opportunityId)[0];
    }
    
    private static  Opportunity BAAOpportunity(string opportunityId)
    {
        return  [select id,name,IBB_Product__c,interested_in__c,IBB_Product__r.name,stagename,account.Organisation_type__c,IsPreRewind__c ,IsPostRewind__c,   ProductEventDirector__c, finance_required__c,Purchase_price_market_value__c,term_of_finance__c,account.name,Status_HPP_CAA__c,BDM_Lead_Provider__r.name,SellerName__c   
                            ,account.Contact_Name__c
                            from opportunity 
                            where id=:opportunityId ][0];// DataHelper.GetOpportunity(opportunityId)[0];   
    }
    
    
    
    
    
    
    public static Boolean UserAuthorised(Event__c event)
    {
        User u = [select UserRoleId from user where id=: UserInfo.getUserId()];
        
        if(Event.Allowed_Roles__c == null)
            return true;
        
         List<String> roleIds= 
              (List<String>)JSON.deserialize(Event.Allowed_Roles__c, List<String>.class);
        
        if(roleIds.size() == 0)
            return true;
        
        //Get event roles 
        List<UserRole> userRoles = [select id from userrole where id in: roleIds];
        
        for(UserRole ur : userRoles)
        {
            if(ur.id == u.UserRoleId)
                return true;
        }
        return false;
    }

}