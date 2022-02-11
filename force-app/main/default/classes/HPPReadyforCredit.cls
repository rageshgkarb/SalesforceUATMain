public class HPPReadyforCredit extends HPPBaseEventController {
  public HPPReadyforCredit() {
    
  }
  
  public PageReference complete() {
    try {
      if(!HPPHelper.CheckFTVIsValid(Opp)) return null;
      update exOpp;
      update Opp;
     
            
      CompleteEvent();
      return GoToNextEvent();
    }
    catch (Exception ex) {
      System.debug('Exception on Update exOpp : ' + ex);
    }
    
    return null;
  }
}