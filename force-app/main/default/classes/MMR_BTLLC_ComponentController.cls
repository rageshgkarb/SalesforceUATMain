/***************/
/*  C0644      */
/***************/
public class MMR_BTLLC_ComponentController extends MMR_ComponentControllerBase
{
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
  
  public List<Property_information__c> Property
  {
      get{
          return ((MMR_FF_BTLLC_PersonalDetails)pageController).GetProperty(AppNo);
      }
  }
  
  public PageReference RemoveProperty()
  {
      ((MMR_FF_BTLLC_PersonalDetails)pageController).RemoveItem(rowDeleteProperty);
      
      return null;
  }
  
  public List<Person_Debts__c> Debts
  {
      get{
          List<Person_Debts__c> tempDebts =  ((MMR_FF_BTLLC_Financial)pageController).GetDebts(AppNo);
          return tempDebts;
      }
  }
  
  public PageReference RemoveDebt()
  {
      ((MMR_FF_BTLLC_Financial)pageController).RemoveItem(rowDeleteProperty);
      
      return null;
  }  
  
  public List<GenericObject__c> CCJs
  {
      get{
          List<GenericObject__c> tempCCJs =  ((MMR_FF_BTLLC_Credit)pageController).GetCCJs(AppNo);
          return tempCCJs;
      }
  }
  
  public PageReference RemoveCCJ()
  {
      ((MMR_FF_BTLLC_Credit)pageController).RemoveItem(rowDeleteProperty);
      
      return null;
  }   
  
  public List<GenericObject__c> Defaults
  {
      get{
          List<GenericObject__c> tempCCJs =  ((MMR_FF_BTLLC_Credit)pageController).GetDefaults(AppNo);
          return tempCCJs;
      }
  }
  
  public PageReference RemoveDefault()
  {
      ((MMR_FF_BTLLC_Credit)pageController).RemoveDefault(rowDeleteProperty);
      
      return null;
  }    
  
  public Decimal TotalDebt
  {
      get{
          return ((MMR_FF_BTLLC_Financial)pageController).GetDebtTotal(AppNo);
      }
  }
  
}