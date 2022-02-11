public class MMR_FF_Income extends MMR_PageControllerBase
{
    //Public Opportunity Opp{get;set;}
    Public List<Account> Accs{get;set;}
    
    public PageReference Setup()
    {
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Income') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
            
            //Case - 01938975 ;Satrt
            if(bopp.Interested_in__c == 'Home Purchase Plan Premier'){
                if(bopp.Accountid == a.id){
                a.Is_the_customer_an_expat__c = bopp.Ex_Pat__c;
                }else{
                    a.Is_the_customer_an_expat__c = 'No';
                }  
            }
            //Case - 01938975 :End       
        }
        return null;
    }
    
    public PageReference Save()
    {
        SaveData();
        //Case - 01938975 :Start
        if(bopp.Interested_in__c == 'Home Purchase Plan Premier'){
            for(Account acc:Accs){
                if(acc.Is_the_customer_an_expat__c == null || acc.Is_the_customer_an_expat__c == ''){
                  apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Please select: Is the customer an expat'));
                  return null;
                }
                /*if(acc.Is_the_customer_an_expat__c == 'No'){
                  apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'As customer is not an expat, so is not applicable for this product'));
                  return null;
                }
                system.debug('acc.Customer_Asset_Value__c'+acc.Customer_Asset_Value__c);
                if(acc.Is_the_customer_an_expat__c!='No'){
                    if(acc.Is_the_customer_going_to_return_in_the_n__c == 'No' && (acc.Customer_Asset_Value__c == '' || acc.Customer_Asset_Value__c == null)){
                      system.debug('Entering into loop line: 31');
                      apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'What is the customer asset value? : You must enter a value')); 
                      return null;  
                    }
                    if(acc.Is_the_customer_going_to_return_in_the_n__c== '' || acc.Is_the_customer_going_to_return_in_the_n__c== null){
                      apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'returning to UK in the next 5 years? : You must enter a value')); 
                      return null;  
                    }
                    if(acc.Customer_profile_Type__c == '' || acc.Customer_profile_Type__c== null){
                      apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Customer profile Type : You must enter a value')); 
                      return null;  
                    }
                }*/
            }
        }
        //Case - 01938975 :End
        return null;
    }
    
    private void SaveData(){
        //update opp;
        update accs;
    }
    
    
    public PageReference Next()
    {
        
        SaveData();
        //Case - 01938975 :Start
        if(bopp.Interested_in__c == 'Home Purchase Plan Premier'){
             for(Account acc:Accs){
                if(acc.Is_the_customer_an_expat__c == null || acc.Is_the_customer_an_expat__c == ''){
                  apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Please select: Is the customer an expat'));
                  return null;
                }
                /*if(acc.Is_the_customer_an_expat__c == 'No'){
                  apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'As customer is not an expat, so is not applicable for this product'));
                  return null;
                }
                if(acc.Is_the_customer_an_expat__c!='No'){
                    if(acc.Is_the_customer_going_to_return_in_the_n__c == 'No' && (acc.Customer_Asset_Value__c == '' || acc.Customer_Asset_Value__c == null)){
                      system.debug('Entering into loop line: 31');
                      apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'What is the customer asset value? : You must enter a value')); 
                      return null;  
                    }
                    if(acc.Is_the_customer_going_to_return_in_the_n__c== '' || acc.Is_the_customer_going_to_return_in_the_n__c== null){
                      apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'returning to UK in the next 5 years? : You must enter a value')); 
                      return null;  
                    }
                    if(acc.Customer_profile_Type__c == '' || acc.Customer_profile_Type__c== null){
                      apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error,'Customer profile Type : You must enter a value')); 
                      return null;  
                    }
                }*/
                
            }
        }
        //Case - 01938975 :End
        return new PageReference('/apex/MMR_FF_Financial?id=' + eventid);
    }
    
    public PageReference Prev()
    {
        SaveData();
        return new PageReference('/apex/MMR_FF_Ownership?id=' + eventid);
    }
}