/* --------------------------------------------------------------------------------------------- */ 
/* C00195:PSD reporting: trigger                                                                 */
/* --------------------------------------------------------------------------------------------- */ 

trigger updateopp_grossincome on AffordabilityResults__c (after insert, after update) 
{
    Map<id,decimal> varmap=new Map<id,decimal>();
    Map<id,decimal> mapApp1=new Map<id,decimal>();
    Map<id,decimal> mapApp2=new Map<id,decimal>();
    Map<id,decimal> mapApp3=new Map<id,decimal>();
    Map<id,decimal> mapApp4=new Map<id,decimal>();
    
    List<Opportunity> opp=new List<Opportunity>();
    if(Trigger.isupdate || trigger.isinsert)
    {
        system.debug('matt got to here 1');
        for(AffordabilityResults__c App:Trigger.New)
        {
            system.debug('matt got to here 2');
            if(Trigger.NewMap.get(App.id).Total_Gross_Income__c!=null )
            {
                system.debug('matt got to here 3');
                varmap.put(App.Opportunity__c,App.Total_Gross_Income__c); //put ur lookup which is onto opportunity
                //C0239
                mapApp1.put(App.Opportunity__c,App.GrossAnnualIncomeApplicant1__c);
                mapApp2.put(App.Opportunity__c,App.GrossAnnualIncomeApplicant2__c);
                mapApp3.put(App.Opportunity__c,App.GrossAnnualIncomeApplicant3__c);
                mapApp4.put(App.Opportunity__c,App.GrossAnnualIncomeApplicant4__c);
                
                system.debug('matt got to here 4 ' + varmap);
            }
        }
        if(!varmap.IsEMpty())
        {
            system.debug('matt got to here 5');
            List<Opportunity> opps=[select id,name,PSD_Gross_Income__c from opportunity where id in:Varmap.keyset()];
            system.debug('matt got to here 6 ' + opps );
            if(!opps.isEmpty())
            {
                for(Opportunity o:opps)
               
                {
                    system.debug('matt got to here 7 ' + o);
                    o.PSD_Gross_Income__c = varmap.get(o.id);
                    //C0239
                    o.GrossAnnualIncomeApplicant1__c = mapApp1.get(o.id);
                    o.GrossAnnualIncomeApplicant2__c = mapApp2.get(o.id);
                    o.GrossAnnualIncomeApplicant3__c = mapApp3.get(o.id);
                    o.GrossAnnualIncomeApplicant4__c = mapApp4.get(o.id);                     
                    
                    system.debug('matt got to here 8 ' +  o.PSD_Gross_Income__c);
                    opp.add(o);
                }
                system.debug('matt got to here 9 ' +  opp); 
                database.update(opp);
            }
        }
    }
}