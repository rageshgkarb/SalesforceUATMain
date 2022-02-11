public class HPPEventSecurityController extends HPPBaseEventController
{
    public PageReference Setup()
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You do not have access to view this page!'));
    
        if(Event.Allowed_Roles__c == null)
            return null;
        
         List<String> roleIds= 
              (List<String>)JSON.deserialize(Event.Allowed_Roles__c, List<String>.class);
              
         List<UserRole> uroles =  [select id, name from UserRole];
         Roles = new List<RolesDisplay>();
         
         for(String r : roleIds)
         {
             for(UserRole ur : uroles)
             {
                 if(ur.id == r)
                 {
                     RolesDisplay rd = new RolesDisplay();
                     rd.id = ur.id;
                     rd.name = ur.name;
                     Roles.add(rd);
                     break;
                 }
             }
         }   
         return null; 
    }
    
    public List<RolesDisplay> Roles{get;set;}
    
    
    public class RolesDisplay
    {
        public String Id{get;set;}
        public String Name{get;set;}
    }   
}