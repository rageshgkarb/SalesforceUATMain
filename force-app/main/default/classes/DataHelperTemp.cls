public class DataHelperTemp
{
  public static String GenerateFields(List<Schema.SObjectField> fldObjMapValues )
    {
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
            String theLabel = s.getDescribe().getLabel(); // Perhaps store this in another map
            String theName = s.getDescribe().getName();
            // String theType = s.getDescribe().getType(); // Perhaps store this in another map

            // Continue building your dynamic query string
            theQuery += theName + ',';
        }

        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        return theQuery;
    }

      public static List<Account> GetAccount(String id)
    {    
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ' FROM Account WHERE id = \'' + id + '\'';

        system.debug(theQuery);

        // Make dynamic call
        Account[] accList = Database.query(theQuery);
        return accList;
    }
    
    public static List<Opportunity> GetOpportunity(String id)
    {
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Opportunity.fields.getMap();
        List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

        String theQuery = GenerateFields(fldObjMapValues );

        // Finalize query string
        theQuery += ',account.id FROM Opportunity WHERE id = \'' + id + '\'';

        system.debug(theQuery);

        // Make dynamic call
        Opportunity[] oppList = Database.query(theQuery);
        return oppList;
    }    
}