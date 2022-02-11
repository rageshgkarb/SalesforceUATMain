public with sharing class MMR_ComponentController extends MMR_ComponentControllerBase {

  private Integer myValue = 3;
    
  public Integer getIntValue() {
    return myValue; 
  }
  
  public String AppNo{get;set;}
  public String ApplicantNo {get;set;}
  public String rowDeleteProperty{get;set;}  
    
  public void incrementValue() {
    myValue++;
  }
  
  public List<Property_information__c > Property
  {
      get{
          return ((MMR_FF_PersonalDetails )pageController).GetProperty(AppNo);
      }
  }
  
  public PageReference RemoveProperty()
  {
      system.debug('Delete index :' +  rowDeleteProperty);      
      ((MMR_FF_PersonalDetails )pageController).RemoveItem(rowDeleteProperty);
      
      return null;
  }
  
  public List<Person_Debts__c> Debts
  {
      get{
          List<Person_Debts__c> tempDebts =  ((MMR_FF_Financial )pageController).GetDebts(AppNo);
          system.debug('App ' + AppNo + ' No debts:' + tempDebts.size());
          return tempDebts;
      }
  }
  
  public PageReference RemoveDebt()
  {
      system.debug('Delete index :' +  rowDeleteProperty);      
      ((MMR_FF_Financial )pageController).RemoveItem(rowDeleteProperty);
      
      return null;
  }  
  
  public List<GenericObject__c> CCJs
  {
      get{
          List<GenericObject__c> tempCCJs =  ((MMR_FF_Credit )pageController).GetCCJs(AppNo);
          system.debug('App ' + AppNo + ' No debts:' + tempCCJs.size());
          return tempCCJs;
      }
  }
  
  public PageReference RemoveCCJ()
  {
      system.debug('Delete index :' +  rowDeleteProperty);      
      ((MMR_FF_Credit )pageController).RemoveItem(rowDeleteProperty);
      
      return null;
  }   
  
  public List<GenericObject__c> Defaults
  {
      get{
          List<GenericObject__c> tempCCJs =  ((MMR_FF_Credit )pageController).GetDefaults(AppNo);
          system.debug('App ' + AppNo + ' No debts:' + tempCCJs.size());
          return tempCCJs;
      }
  }
  
  public PageReference RemoveDefault()
  {
      system.debug('Delete index :' +  rowDeleteProperty);      
      ((MMR_FF_Credit )pageController).RemoveDefault(rowDeleteProperty);
      
      return null;
  }    
  
  public Decimal TotalDebt
  {
      get{
          return ((MMR_FF_Financial )pageController).GetDebtTotal(AppNo);
      }
  }
  
}