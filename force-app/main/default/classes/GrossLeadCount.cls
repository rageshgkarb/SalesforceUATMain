public class GrossLeadCount{
      
      public static void customPageCount( list<Lead> lstLeads){
      set<id> camId=new set<id>();  
          for (Lead led : lstLeads ) {
            camId.add(led.Primary_Source_Campaign__c);
    }
   list<Campaign> cam1 = [select Id,No_of_leads__c from Campaign where ID IN :camId];
   list<Lead> l2 = [select ID,Primary_Source_Campaign__c from Lead where Primary_Source_Campaign__c IN :cam1 ];
   list<Campaign> lst=new list<Campaign>();
    for(Campaign c2:cam1)
    {
         c2.No_of_leads__c = l2.Size();
         lst.add(c2);
         
    }
    if(lst.size()>0){
     Database.Update(lst); }  
  }
}