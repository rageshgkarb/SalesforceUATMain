public class Case_SLA_Date_Controller
{
    public Integer Second {get;set;}
    public Integer Minute {get;set;}
    public Integer Hour {get;set;}
    
    public Integer Day {get;set;}
    public Integer Month {get;set;}
    public Integer Year {get;set;}
    
    public Boolean Show {get;set;}
    public Boolean ClosedWithinSLA {get;set;}
    public Boolean ClosedAfterSLA {get;set;}
    public Decimal HoursAfterSLA {get;set;}
    public Integer DaysAfterSLA {get;set;}

    
    public String SLADue {get;set;}
    public String TimeLeft {get;set;}
    public String TimerDate {get;set;}
    
    public Boolean Breached {get;set;}
    
    public Case c {get;set;}

    public Case_SLA_Date_Controller(ApexPages.StandardController controller)
    {
    
        this.c = (Case)controller.getRecord();
        
        c = [select isClosed, closeddate, SLA_Due__c, Hours_Past_SLA__c, recordtype.developername from case where id=:c.id];
        
        
        show = !c.isClosed;
        
        
        if(c.isClosed)
        {
            if(c.closeddate <= c.sla_due__c)
            {
                ClosedWithinSLA =true;
            }
            else
            {
                ClosedAfterSLA =true;
                //HoursAfterSLA = c.Hours_Past_SLA__c;
             
             if(c.Hours_Past_SLA__c != null)
             {   
                DaysAfterSLA = c.Hours_Past_SLA__c.intValue() /8;                
                HoursAfterSLA = (c.Hours_Past_SLA__c - (DAysAfterSLA * 8)).setScale(1);  
             }    
            }
        }
        
        Datetime dt = c.SLA_Due__c;
        
        
        if(dt != null)
        {
            SLADue = dt.format('E dd/MM/YYYY kk:mm');
            if(DateTime.now() > dt) 
            {
                Breached = true; return;
            }
            
        
            
            
            List<Case_SLA__c> lstSla = [SELECT name, SLA_Duration__c, StartTimeHour__c, StartTimeMinute__c, EndTimeHour__c, EndTimeMinute__c FROM Case_SLA__c
                                            where name=:c.recordtype.developername];
            
            DateTime fakeDate = DateTime.now();
            if(lstSLA.size() > 0 && dt > datetime.now())
            {
                BusinessHours bizHours = [select id from businesshours where isDefault = true];   
                Long secondsTotal = BusinessHours.diff(bizHours.Id, datetime.now(), c.SLA_due__c)/1000;    
                Long hours= secondsTotal/60/60;                
                Long minutes = (secondsTotal /60) - (hours * 60);      
                Long seconds =  secondsTotal  - (hours * 60 * 60) - (minutes * 60);
                
                TimeLeft = hours + ' hours, ' + minutes + ' minutes, ' + seconds + ' seconds';  
                
                
                //hack to show business hours countdown
                dt = datetime.now();
                
                dt = dt.addHours(hours.intvalue());
                dt = dt.addMinutes(minutes.intvalue());   
                dt = dt.addSeconds(seconds.intValue());
                           
            }
            
            
            
            TimerDate = dt.format('E dd/MM/YYYY kk:mm');
            
            Year = dt.Year();
            Month = dt.Month() -1;// -1;
            Day = dt.Day();
            Hour = dt.Hour();
            Minute = dt.Minute();
            Second = dt.Second();
            
        }
        
        
    }
}