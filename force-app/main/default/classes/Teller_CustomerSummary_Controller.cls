public class Teller_CustomerSummary_Controller
{
    public Boolean CanEditOnlineBanking
    {
        get{            
            String uRoleId = UserInfo.getUserRoleId();
            
            UserRole r = [select name from userrole where id=:uRoleId];
            
            List<Engage_Online_Banking__c> onlinebankingRoles= Engage_Online_Banking__c.getall().values();
            
            for(Engage_Online_Banking__c allowedRole: onlinebankingRoles)
            {
                if(allowedRole.Name.equalsIgnoreCase(r.name))
                    return true;
            }
            return false;
        }
    }
}