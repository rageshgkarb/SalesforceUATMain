public class FunctionHelper
{
    public static Postcode__c GetPostcodeSeller(String postCode)
    {
        if(postCode == null)
        return null;
        
        postCode= postCode.replace(' ','');  //remove any spaces
        String outCode;
        
        //The outcode is the postcode minus the last 3 digits.  This results in a code of 2-4 digits
        outCode = postCode.left(postCode.length() - 3);
        system.debug('Postcode lookup ' + outCode);
        
        //Loop is required because a post code could be either 'S2 2AA' or 'S22 2AA' and we are trying to match to 'S2' in the database
        //Start by trying to match the longer code
        while(outCode .length()> 0)
        {
            List<Postcode__c> objPostCode= [select id,area__c, user__c from postcode__c where postcode__c = :outCode limit 1];            
            if(objPostCode.size() > 0)
            {
                system.debug('found postcode : ' +objPostCode[0] );
                return objPostCode[0];
            } 
            outCode = outCode.left(outCode.Length() - 1) ;
        }  
        return null;
    }
    
    public static String GetRoundRobinUserId()
    {
        String id;
        List<EligibilityBdm__c> users =EligibilityBdm__c.getall().values() ;
        
        if(users.size() == 0 )
        return null;
        
        boolean isNextPerson = false;
        for(EligibilityBdm__c p :users)
        {
            system.debug('for user ' + p.username__c);
        
            if(isNextPerson )
            {
            system.debug('Set to ' + p.UserName__c);
              List<User> usr = [select id, name from user where username=:p.UserName__c];
              {
                  //if(usr.size() > 0)
                 // {
                      p.IsCurrent__c= true ;             
                      id= usr[0].id;
                      break;
                 //  }              
              }
            }
        
            if(p.IsCurrent__c)
            {
                isNextPerson = true;
                p.IsCurrent__c= false;
            }
        }
        
        if(id == null)
        {
             List<User> usr = [select id, name from user where username=:users[0].username__c];
              {
              if(usr.size() > 0)
              {
                  users[0].IsCurrent__c = true ;             
                  id= usr[0].id;
              } 
              }  
        }
        
        
        update users;  
        return id;
    }
    
    public static RecordType GetRecordType(String name, String objectType)
    {
        List<RecordType> listRecordType =  [select id from recordType where  sobjectType=:objectType and DeveloperName =: name limit 1];
        
        if(listRecordType.size() == 0)
            return null;
            
        return listRecordType[0];
    }
    
    
     public static RecordType GetPersonRecordType(String name, String objectType)
    {
        List<RecordType> listRecordType=    [select id from recordType where ispersontype=true and sobjectType=:objectType and DeveloperName =: name limit 1];
        if(listRecordType.size() == 0)
            return null;
            
        return listRecordType[0];
    }
    
    public static string StripNull (string inStr)
    {
        return inStr == 'null' || string.IsEmpty(instr) ? '' : inStr;
    }
     
}