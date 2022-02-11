public class DateComponentController
{
    public boolean FutureDates{get;set;} 
    
    public List<SelectOption> Dates{
    
    
    get{
    
        Dates = new List<SelectOption>();
        integer currentYear = Date.today().year();
    
        if(FutureDates == null)
            FutureDates = false;        
        
        if(!FutureDates)
        {
            for(Integer i = currentYear ; i > (currentYear - 120) ;i-- )
            {
                Dates.add(new SelectOption(string.valueof(i),string.valueof(i)));
            }
        }
        else
        {
            for(Integer i = currentYear ; i < (currentYear + 50) ;i++ )
            {
                Dates.add(new SelectOption(string.valueof(i),string.valueof(i)));
            }        
        }
        return Dates;
    
    }
    
    
    set;}
       
    
    
    
    
    
    
    public DateComponentController()
    {
                
        
    }
}