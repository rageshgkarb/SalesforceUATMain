public class FCA_Report_Date_Controller
{
    public Integer Second {get;set;}
    public Integer Minute {get;set;}
    public Integer Hour {get;set;}
    
    public Integer Day {get;set;}
    public Integer Month {get;set;}
    public Integer Year {get;set;}
    
    public Boolean Show {get;set;}
    
    Private Case c ;

    public FCA_Report_Date_Controller(ApexPages.StandardController controller)
    {
    
        this.c = (Case)controller.getRecord();
        
        c = [select isClosed, FCA_Reportable_Date__c, Is_FCA_Reportable__c from case where id=:c.id];
        
        
        show = !c.isClosed || c.Is_FCA_Reportable__c;
        
        
        Datetime dt = c.FCA_Reportable_Date__c;
        
        if(dt != null)
        {
            Year = dt.Year();
            Month = dt.Month() -1;
            Day = dt.Day();
            Hour = dt.Hour();
            Minute = dt.Minute();
            Second = dt.Second();
        }
        
        
    }
}