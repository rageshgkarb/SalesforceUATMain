/**Contains a list of generic methods to be used accross different classes*/
public class Util{

    public static Map<Integer,String> monthIntegerToNameMap {get; set;}

    //splits the input list into different sub-list as per chunkSize & returns the entire list of sub-lists
    public static List<List<String>> splitListIntoChunks(List<String> inputList, Integer chunkSize)
    {

        List<List<String>> listOfchunks = new List<List<String>>();
        Integer index = 0;
    
        Integer size = inputList.size();
     
        while (index < size)
        {        
             List<String> listChunk = new List<String>();
             
             for(Integer i = 0; i< chunkSize; i++){
                
                if(index >= size)
                break;
                
                listChunk.add(inputList[index]);
                index++;
       
              }
            
            listOfchunks.add(listChunk);
        }
        
        return listOfchunks;
    }
    
    //returns a map of month names(Monthfullname:Monthshortname) associated with its integer values
    public static Map<Integer,String> getMonthNameMap(){

        if(monthIntegerToNameMap!=null) {
 
            return monthIntegerToNameMap;
        
        } else {
              
            monthIntegerToNameMap = new Map<Integer,String>();
            //Get all the questions from Custom Metadata
            for(Month_Name__mdt month :  [SELECT MasterLabel, DeveloperName, Integer_Value__c FROM Month_Name__mdt])
            {
                monthIntegerToNameMap.put(month.Integer_Value__c.intValue(),month.MasterLabel+':'+month.DeveloperName);
            }
            
            return monthIntegerToNameMap;
        
        }
   }
     public static List<CAA_Data.KeyValue> GetOptions(List<Schema.PicklistEntry> data)
    {
        List<CAA_Data.KeyValue> lst = new List<CAA_Data.KeyValue>();
    
        for( Schema.PicklistEntry f : data){        
            lst.add(new CAA_Data.KeyValue(f.getLabel(), f.getValue()));
        }
        return lst;
    }
}