trigger ValuationReportTrigger on Valuation_Report__c (after insert, after update) {

if(trigger.isUpdate){ //C0760 changes 
if(Trigger_Helper.IgnoreTrigger('Valuation_Report__c'))
        return;

Trigger_Helper.Audit('Valuation_Report__c',trigger.oldMap, trigger.newMap); 

for(Valuation_Report__c  r : Trigger.new)
{
    if(r.Date_of_Report__c == null)
        break;


    Event__c eve = [select id from event__c where name ='Awaiting Valuation'];
    List<Eventlog__c> logs = [select id, opportunity__c, event__c from eventlog__c 
                            where opportunity__c =: r.opportunity__c
                            and  IsExpired__c = false and EventStatus__c = 'Open'
                            and Event__c =: eve.id
                             ];  
                             
                                  

    List<HPP_extended_opportunity__c> ex = [select Valuation_attached__c, Valuation_received__c , opportunity__c,id 
                                            from HPP_extended_opportunity__c
                                            where opportunity__c =: r.opportunity__c ];
                                            
     List<Opportunity> opp = [select id,ProductEventDirector__c 
                         from opportunity
                         where id =: r.opportunity__c ];
    if(opp.size() == 0)
        break;                      
              
                                           
    if(logs.size() > 0)
    {
        IBBEvents director = new IBBEvents(opp[0].ProductEventDirector__c);
        Boolean returnValue = director.CompleteEvent(logs[0], opp[0]);  
        
        ex[0].Valuation_attached__c = true;
        ex[0].Valuation_received__c = date.today();
        
        update ex;
        update logs;        
    }                                       
    break;
    
    
   
}      
}
//C0760;Start
 if(trigger.isInsert || trigger.isUpdate){
            Map<ID, Opportunity> Opps= new Map<ID, Opportunity>();
            map<Id,Valuation_Report__c > Valuation = new map<id,Valuation_Report__c>();
            List<Id> listIds = new List<Id>();
            for (Valuation_Report__c val : Trigger.new)
            {
                listIds.add(val.Opportunity__c);
            } 
            Opps =  new Map<id, Opportunity>([Select id, Market_value_of_Property__c from Opportunity where id in : listIds]); 
            map<id,string> opVal = new map<id,string>();
            
            for(Opportunity p:Opps.values()){
                Valuation_report__c ve=[select id ,name,Opportunity__c from Valuation_report__c where Opportunity__c= :p.id  Order by createddate desc limit 1];
                
                opVal.put(p.id,ve.id);
            }
            
            
            for (Valuation_Report__c val1: Trigger.new)
                {
                Id valId = opVal.get(val1.opportunity__c);
                if(valId==val1.id){
                    Opportunity ParentOpp = Opps.get(val1.Opportunity__c);
                    ParentOpp.Market_value_of_Property__c = val1.Market_Value_Present_Condition__c ;
                    }
                }
                update Opps.values();

 


        }   
//C0760 ; End
}