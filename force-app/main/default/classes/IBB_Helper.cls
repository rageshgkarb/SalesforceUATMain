public class IBB_Helper
{
    public static sObject SplitString(sObject obj,string data,string fieldPrefix, integer numFields, integer fieldLength)
    {
        //split string into string array of certain length
        String remainingData = data;
        List<String> splitData = new List<String>();
        
        
        //blank out the data for all the object fields because the new string that is being saved may be smaller than the previous string
        //if a new value only uses 3 fields for storage, we don't want there to be old data left in fields 4+ 
        for(Integer iField = 1; iField <= numFields;iField++ )
        {
            obj.put(fieldPrefix + iField + '__c','');
        }
        
        
        while(remainingData.length() > 0)
        {
            if(remainingData.length() > fieldLength)
            {
                splitData.add(remainingData .substring(0,fieldLength));
                remainingData = remainingData .substring(fieldLength); 
                
            }
            else
            {
                splitData.add(remainingData );
                remainingData = '';
            }
        }
        
        Integer i =1;
        for(String s : splitData)
        {
            obj.put(fieldPrefix + i + '__c',s);
            i+=1;
        }
        return obj;        
    }


    public static String RebuildString(sObject obj,string fieldPrefix, integer numFields)
    {
        String data='';
        
        try
        {
            system.debug(obj);
            for(integer i = 1; i<= numFields;i++)
            {
                
                String fieldToFind = fieldPrefix + i +'__c';
                String field = string.valueof(obj.get(fieldToFind ));
                if(field != null)
                {
                    data += field ;
                }
                else
                {
                    break;
                }
            }
        }
        catch(Exception ex)
        {
            system.debug('Getting data fields exception:' + ex.getMessage());
            return null;
        }
        
        return data;
    }
}