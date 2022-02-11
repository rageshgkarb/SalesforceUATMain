@IsTest
public class zTest_IBBEvents
{

     public ProductEventDirector__c director{get;set;}
     public Event__c event{get;set;} 
     public Opportunity Opp{get;set;}  
     public EventLog__c Log{get;set;} 
     public Attachment att{get;set;}
     public HPP_extended_opportunity__c ex{get;set;} 
     z_ProductHelper pHelp ;
     
 public void CreateDirectorFlow()
    {
        
    
        z_DirectorHelper dHelp = new z_DirectorHelper();
        dHelp.AIPEvent();
        dHelp.ApplicationEvent();
        director = dHelp.Build();
                
        pHelp = new z_ProductHelper();        
        pHelp.Director(director.id);
        IBB_Product_Set__c prod  = pHelp.Build();
        
        z_OpportunityHelper oHelp = new z_OpportunityHelper('Test','Test');
        oHelp.Director(director.id);
        Opp = oHelp.build();
        
        Opp.IBB_Product__c = pHelp.Product.id;
update opp;
        
   
        
        event= dHelp.Event;
        
        ex  = new HPP_extended_opportunity__c ();
        ex.Opportunity__c = opp.id;
        insert ex;
                       
        log = new EventLog__c();
        log.Event__c = dHelp.Event.id;
        log.Opportunity__c = opp.id;
        log.EventStatus__c = 'Open';
        insert log;
    }


    static TestMethod void ConstructorTest()
    {
        zTest_IBBEvents test = new zTest_IBBEvents();
        test.CreateDirectorFlow();
        
        IBBEvents ev = new IBBEvents(test.director.id);
    }
    
    static TestMethod void CreateFirstEvent()
    {
        zTest_IBBEvents test = new zTest_IBBEvents();
        test.CreateDirectorFlow();
        
        IBBEvents ev = new IBBEvents(test.director.id);
        ev.CreateFirstEvent(test.Opp.id);
    }    
    
    static TestMethod void CompleteEvent()
    {
        zTest_IBBEvents test = new zTest_IBBEvents();
        test.CreateDirectorFlow();
        
        IBBEvents ev = new IBBEvents(test.director.id);
        ev.CreateFirstEvent(test.Opp.id);
        
        Eventlog__c log1 =[select id from eventlog__c where opportunity__c= :test.Opp.id limit 1]; 
        List<Eventlog__c> log = DataHelper.GetEventLog(log1.id);
        
       ev.CompleteEvent(log[0],test.Opp); 
       system.debug(ev.ErrorMessage()); 
       
        EventLog__c newLog = ev.GetCreatedEvent();
        String location= ev.GetCreatedEventLocation();       
    }   
    
    static TestMethod void CompleteEvent_Action()
    {
        zTest_IBBEvents test = new zTest_IBBEvents();
        test.CreateDirectorFlow();
        
       /* EventAction__c action= new EventAction__c();
        action.Event__c = test.event.id;
        action.RunWhen__c = 'Completed';
        action.Sequence__c = 1;
        action.classname__c = 'Actions.FakeAction';
        insert action;        
        */

        
        IBBEvents ev = new IBBEvents(test.director.id);
        ev.CreateFirstEvent(test.Opp.id);
        
        Eventlog__c log1 =[select id from eventlog__c where opportunity__c= :test.Opp.id limit 1]; 
        List<Eventlog__c> log = DataHelper.GetEventLog(log1.id);
        
       ev.CompleteEvent(log[0],test.Opp);  
       system.debug('Error: ' + ev.ErrorMEssage());
    }    
    
    static TestMethod void CreateEvent_CreateCase()
    {
        zTest_IBBEvents test = new zTest_IBBEvents();
        test.CreateDirectorFlow();
        
        test.event.CreatesCases__c = true;
        update test.event;
        
        IBBEvents ev = new IBBEvents(test.director.id);
        ev.CreateFirstEvent(test.Opp.id);
        
        Eventlog__c log1 =[select id from eventlog__c where opportunity__c= :test.Opp.id limit 1]; 
        List<Eventlog__c> log = DataHelper.GetEventLog(log1.id);
        
       ev.CompleteEvent(log[0],test.Opp);  
    }  
    
    static TestMethod void CloseEvent_CloseCase()
    {
        zTest_IBBEvents test = new zTest_IBBEvents();
        test.CreateDirectorFlow();
        
        test.event.CreatesCases__c = true;
        update test.event;
    
        
    
        
        IBBEvents ev = new IBBEvents(test.director.id);
        ev.CreateFirstEvent(test.Opp.id);
        
        Eventlog__c log1 =[select id from eventlog__c where opportunity__c= :test.Opp.id limit 1]; 
        List<Eventlog__c> log = DataHelper.GetEventLog(log1.id);
        
        //create a case manually
        Case c = new Case();
        c.status = 'open';
        c.eventlog__c = log[0].id;
        insert c;
        
        
       //ev.CompleteEvent(log[0],test.Opp);  
    }      






    
    


}