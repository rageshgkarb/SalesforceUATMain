public class CAA_Date_Controller
{
    public Integer Years {get;set;}
    
    public CAA_Date_Controller()
    {   
        
    }
    
    //public List<SelectOption> YearsList{get;set;}
    
    
    public List<String> YearList
    {
        get{
        List<String> YearsList = new List<String>();
        
        system.debug('GetYears');
        if(Years == null) return YearsList ;
    
         
        Integer start = (Years > 0  ? Date.Today() : Date.Today().addYears(Years)).Year();
        Integer endYear = (Years > 0  ? Date.Today().addYears(Years) : Date.Today()).Year();
        
        system.debug('Start:' + start + ' End:' + endYear);
        
        if(Years > 0)
        {
            for(Integer i = start; i<= endYear; i++)
            {
                YearsList.add(string.valueof(i));
            }
        }
        else
        {
            for(Integer i = endYear; i>= start; i--)
            {
                YearsList.add(string.valueof(i));
            }
        }
        
        system.debug('DATES:' + YearsList);
        
        
        return YearsList;
        }
    }
    
}