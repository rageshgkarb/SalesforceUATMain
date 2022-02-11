public class DataHelper_PreHPP
{
    
    public static String GenerateFields(List<Schema.SObjectField> fldObjMapValues )
    {
        return GenerateFields(fldObjMapValues , 'Account');
    
    }
    /*
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
    */
    
    
    public static String GenerateFields(List<Schema.SObjectField> fldObjMapValues, String objectType )
    {
        List<Ignore_Fields_Query__c> ignoreFields = [select field_name__c from Ignore_Fields_Query__c where Object__c =: objectType and Ignore__c = true];
    
        system.debug('ignore fields count:' + ignoreFields.size());
        system.debug(ignoreFields);
        
        String theQuery = 'SELECT ';
        for(Schema.SObjectField s : fldObjMapValues)
        {
        
        try
        {
        
            Schema.DescribeFieldResult des = s.getDescribe();
            String theName = des.getName();
            // String theType = s.getDescribe().getType(); // Perhaps store this in another map

            // Continue building your dynamic query string            
            //check to see if the field is to be ignored
            boolean ignore = false;
            for(Ignore_Fields_Query__c field : ignoreFields)
            {
                if(field.field_name__c.equalsIgnoreCase(theName))
                {
                    ignore = true;
                    system.debug('ignored field : ' + theName);
                    break;
                }    
            }
            
            if(!ignore)
                theQuery += theName + ',';
        }
        catch(Exception ex)
        {
            system.debug('EXCEPTION: ' + ex.getMessage());
        }
            
        }

        // Trim last comma
        theQuery = theQuery.subString(0, theQuery.length() - 1);
        return theQuery;
    }
    
    
}