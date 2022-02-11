public class HPPReceivedbyCredit extends HPPBaseEventController {
  public HPPReceivedbyCredit() {
    
  }
  
  public PageReference complete() {
    try {
      update exOpp;
      update Opp;
       //C0782 Reac changes start
     if(opp.Interested_in__c.Contains('REAC')){
       List<Valuation_Report__c> valReps = [SELECT Id,
                                                    Opportunity__c,
                                                    ReportStatus__c,
                                                    LenderReference__c,
                                                    Name,
                                                    CreatedDate
                                             FROM   Valuation_Report__c
                                             WHERE  Opportunity__c = :opp.Id
                                             AND    ReportStatus__c = 'InstructionCreated'
                                             ORDER BY  CreatedDate DESC];
        
       
        if (valReps.Size() < 1)
        {
           Valuation_Report__c valRep = new Valuation_Report__c();
           valRep.Opportunity__c = opp.Id;
           valRep.ReportStatus__c = 'InstructionCreated';
           valRep.LenderReference__c = opp.Name;
           insert valRep;
        }
     }
      //C0782 Reac changes end     
            
      CompleteEvent();
      return GoToNextEvent();
    }
    catch (Exception ex) {
      System.debug('Exception on Update exOpp : ' + ex);
    }
    
    return null;
  }
}