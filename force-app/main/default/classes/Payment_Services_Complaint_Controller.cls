public class Payment_Services_Complaint_Controller
{
    public Integer Second {get;set;}
    public Integer Minute {get;set;}
    public Integer Hour {get;set;}
    
    public Integer Day {get;set;}
    public Integer Month {get;set;}
    public Integer Year {get;set;}
    
    public Boolean Show {get;set;}

	//C0674 - Added the variable below
	public String PaymentServices{get;set;}
    
    Private Case c ;

    public Payment_Services_Complaint_Controller(ApexPages.StandardController controller)
    {
    
        this.c = (Case)controller.getRecord();
        
		//C0674 - added Payment_Service_or_E_money_Complaints__c to the query below
        c = [select isClosed, Payment_Service_Complaint_Date__c, Payment_Service_or_E_money_Complaints__c from case where id=:c.id];
        
        show = !c.isClosed;

        PaymentServices = c.Payment_Service_or_E_money_Complaints__c; //C0674
        
        Datetime dt = c.Payment_Service_Complaint_Date__c;
        
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