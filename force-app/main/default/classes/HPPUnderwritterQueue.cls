public class HPPUnderwritterQueue
{
    public PageReference Setup()
    {
        List<EventLog__c> elogs= [select id, opportunity__r.Finance_Required__c, opportunity__r.Purchase_price_market_value__c,   opportunity__r.Application_Reference_Number__c, opportunity__r.Ibb_Product__r.EBS_Deal_Account_Type__c,  opportunity__r.IBB_Product_Type__c,  opportunity__r.account.salutation,opportunity__r.account.firstname,opportunity__r.account.lastname,  opportunity__r.IBB_Product__r.IBB_Product_Set__c, name, ExpectedCompletionDate__c,event__r.TimeToComplete__c, event__r.SLADays__c, createddate, Event__r.name, Opportunity__r.name,Opportunity__c  from eventlog__c where EventStatus__c = 'Open'
                and  Event__r.EventQueue__c = 'Underwriting'  
                order by ExpectedCompletionDate__c ];
                
        List<IBB_Product_set__c> premProducts = [select id from ibb_product_set__c where name ='Home Purchase Plan Premier' ];                

        Logs = new List<QueueData>();
        PremierLogs = new List<QueueData>();
                
        for(EventLog__c l : elogs)
        {
            QueueData log = new QueueData();
            log.EventName = l.Event__r.name;  
            log.CreatedDate = l.createddate;
            log.OppName = l.Opportunity__r.name;
            log.ExpectedDate =l.ExpectedCompletionDate__c;
            log.LogId = l.id;
            log.sla = integer.valueof( l.Event__r.sladays__c);
            log.firstname = l.opportunity__r.account.firstname;
            log.lastname= l.opportunity__r.account.lastname;            
            log.Title= l.opportunity__r.account.salutation; 
            log.ProductType = l.opportunity__r.Ibb_Product__r.EBS_Deal_Account_Type__c;
            log.accountno = l.opportunity__r.Application_Reference_Number__c;
            log.FinanceRequired = l.opportunity__r.Finance_Required__c;
            log.PropertyValue = l.opportunity__r.Purchase_price_market_value__c;
            
            if(log.ExpectedDate != null)
            {
                DAte d1 =  date.today();
                Date d2 = l.ExpectedCompletionDate__c.date();       
                log.DaysLeft = d1.daysBetween(d2);
            }
            else
            {
                log.DaysLeft = 0;
            }
            
            log.css = 'green';            
            
            if(log.ExpectedDate <=   date.today().addDays(2))
            {
                log.css = 'orange';
            }
            if(log.ExpectedDate  < date.today())
            {
                log.css = 'red';
            }
            
            
            log.opp= l.Opportunity__r;
            log.Minutes = integer.valueof( l.event__r.TimeToComplete__c);
            
            for(IBB_product_set__c p : premProducts )
            {
                if(p.id == l.opportunity__r.IBB_Product__r.IBB_Product_Set__c)
                {
                    premierlogs.add(log);
                    //continue;
                }
            }
            
            
            logs.add(log);
        }                
                
        return null;
    }
    
    public string TimeDisplay(Integer i)
    {
    
        integer minutesInDay = integer.valueof(7.5 * 60);  
        
        integer workDays_r = math.mod(i, minutesInDay );
        integer work_Days = (i-workDays_r )/ minutesInDay;    
    

        integer workhours_r = math.mod(i - (work_Days * minutesInDay )  ,60);
        integer workhours = (workDays_r - workhours_r )/60;
        

         
         
        return work_Days + ' day/s, ' + workhours + 'hour/s, ' + workhours_r + 'min/s';
    }
    
    public string TotalMinutes
    {
        get{
            integer i=0;
            for(QueueData q : logs)
            {
                i+= q.Minutes;
            }
           
           return TimeDisplay(i);
           
        }
    }
    
    public List<QueueData> Logs{get;set;}
    public List<QueueData> PremierLogs{get;set;}
    
    @RemoteAction
    public static List<EventLog__c> myLogs() {
        
        return [select id, name, ExpectedCompletionDate__c, createddate, Opportunity__r.name,Opportunity__c  from eventlog__c where EventStatus__c = 'Open'
                order by ExpectedCompletionDate__c desc  ];
    }
    
    
    public class QueueData
    {
        public String EventName{get;set;}
        public String LogId{get;set;}
        public String OppName{get;set;}
        public DateTime CreatedDate{get;set;}
        public DateTime ExpectedDate{get;set;}
        public integer DaysLeft{get;set;}
        public Opportunity Opp{get;set;}
        public Integer Minutes{get;set;} 
        public String css{get;set;}
        public Integer sla{get;set;}
        public String LastName{get;set;}
        public String FirstName{get;set;}
        public String Title{get;set;}
        public String ProductType{get;set;}
        public String AccountNo{get;set;}
        public Decimal FinanceRequired{get;set;}
        public Decimal PropertyValue{get;set;}
    }
}