public class MMR_FF_Financial extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public Opportunity Opp{get;set;}
    
    public PageReference Setup_Financial()
    {        
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Financial') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }

        
        
        
        Opp = [select id, Interested_in__c  from opportunity where id=:opportunityid];
        DepositSource = [select id,Deposit_Source__c,Deposit_Value__c,Deposit_Details__c from GenericObject__c where Opportunity__c=:opportunityid and type__c = 'DepositSource'];
        RefinanceSource =[select id, Refinance_Details__c,Refinance_Type__c,Refinance_Value__c from GenericObject__c where Opportunity__c=:opportunityid and Type__c='RefinanceSource'];
        
        return null;
    }
    
    private void LoadDebts()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Financial_Debts') + ' from Person_Debts__c where Owner_of_debt__c in' + AccountIds ;
        m_AllDebts= DataBase.Query(soql);
    }
    
    Transient List<Person_Debts__c> m_AllDebts;    
    public List<Person_Debts__c> AllDebts
    {
        get{
            if(m_AllDebts== null)
            {
                LoadDebts();
            }
            return m_AllDebts;
        }       
    }
    
    public boolean SaveData()
    {
        try
        {
            update Accs;
            update DepositSource;
            update RefinanceSource;
            return true;
        }
        catch(Exception ex)
        {
            return false;
        }
    }
    
    public PageReference Next()
    {
        if(SaveData())
        {
            return new PageReference('/apex/mmr_ff_credit?id=' + eventid);
        }
        return null;
    }
    
    public PageReference Previous()
    {
        if(SaveData())
        {
            return new PageReference('/apex/mmr_ff_income?id=' + eventid);
        }
        return null;
    }    
    
    
    public List<Person_Debts__c> GetDebts(String applicantNo)
    {
        String id = Accs [integer.valueof(applicantNo)-1].id;
        system.debug('Acc Id ' + id);
        system.debug('ACc list ' + lstAccountIds );
        List<Person_Debts__c> lst= new List<Person_Debts__c>();
        for(Person_Debts__c p : AllDebts)
        {
            if(p.Owner_of_debt__c== id)
            {
                lst.add(p);
            }
        }    
    
        return lst;
    }
    
    public Decimal GetDebtTotal(String applicantNo)
    {
        String id = Accs [integer.valueof(applicantNo)-1].id;
        system.debug('Acc Id ' + id);
        system.debug('ACc list ' + lstAccountIds );
        List<Person_Debts__c> lst= new List<Person_Debts__c>();
        
        Decimal total = 0;
        for(Person_Debts__c p : AllDebts)
        {
            if(p.Owner_of_debt__c== id)
            {
                system.debug('debt row:' +p);
                if(p.Monthly_repayment__c != null)
                total += p.Monthly_repayment__c;
            }
        }    
    
        return total ;
    }
    
    public List<SelectOption> selApplicant
    {
        get{
            List<SelectOption> options= new List<SelectOption>();
            options.add(new SelectOption('','--Select--'));
            Integer i = 1;
            for(Account a : Accs )
            {
                options.add(new SelectOption(a.id,'Applicant ' + i + ' ' +a.name));
                i++;
            }
            return options;
        }
    }

    public PageReference SaveDebt()
    {
        Boolean isNew = true;
        Person_Debts__c prop = new Person_Debts__c();
        prop.Owner_of_debt__c= EditDebt.Owner_of_debt__c;
        System.debug('ID:' + EditDebt.id);
        
        if(EditDebt.id != null)
        {
                      
                    
                    String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Financial_Debts') + ' from Person_Debts__c where id= \'' + EditDebt.id + '\'';
                    
                    List<Person_Debts__c> props = database.query(soql);
                    
                    if(props.size() > 0)
                    {
                        prop = props[0];
                    }
                  
                    
                    isNew = false;
                    
                    system.debug('Found property id :' + EditDebt.id);
           
        }
        
        
                 
        prop.Type_of_debt__c= EditDebt.Type_of_debt__c;
        prop.Debt_Lender_Name__c= EditDebt.Debt_Lender_Name__c;
        prop.Start_date__c= EditDebt.Start_date__c;
        prop.Monthly_repayment__c= EditDebt.Monthly_repayment__c;
        prop.Outstanding_balance__c= EditDebt.Outstanding_balance__c;                                
        prop.PaidOffDebt__c= EditDebt.PaidOffDebt__c;  
        prop.Will_this_debt_be_paid_off_by_this_app__c = EditDebt.Will_this_debt_be_paid_off_by_this_app__c ;  
        prop.Secured_on_property__c= EditDebt.Secured_on_property__c;  
        prop.Cleared_before_HPP_starts__c= EditDebt.Cleared_before_HPP_starts__c;  

        
        system.debug(prop);
        
        
        try
        {
            upsert prop;
            EditDebt = new Person_Debts__c();
            LoadDebts();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
    
    public Person_Debts__c EditDebt
    {
        get{
            if(EditDebt== null)
            {
                EditDebt= new Person_Debts__c();
            }
            return EditDebt;
        }
        set;
    }
    
    public PageReference RemoveItem(String id)
    {
        Integer i = 0;
        Person_Debts__c del;
        
        for(Person_Debts__c p : AllDebts)
        {
            if(p.id == id)
            {
                del = AllDebts.Remove(i);
                break;   
            }        
            i++;
        }
        
        if(del != null)
        {
            delete del;
        }            
    
        
    system.debug('Remove main controller :' + id);
        return null;
    }


    
    public PageReference Save()
    {
        SaveData();
        return null;
    }
    
    
    public List<GenericObject__c> DepositSource{get;set;}
    public List<GenericObject__c> RefinanceSource{get;set;}
    public PageReference RemoveDepositSource() 
    {  
        GenericObject__c del = DepositSource.remove(integer.valueof(rowDeleteDepositSource));
        delete del;         
        return null;
    }
    public PageReference RemoveRefinanceSource() 
    {  
        GenericObject__c del = RefinanceSource.remove(integer.valueof(rowDeleteRefinanceSource));
        delete del;        
        return null;
    }
    
    public String rowDeleteDepositSource{get;set;}
    public String rowDeleteRefinanceSource{get;set;}  

    public PageReference AddDepositSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opportunityid;
        p.Type__c = 'DepositSource';
        DepositSource.add(p);
        upsert DepositSource ;
        return null;
    }
    public PageReference AddRefinanceSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opportunityid;
        p.Type__c = 'RefinanceSource';
        RefinanceSource.add(p);
        upsert RefinanceSource;
        return null;
    }
    
    public Boolean IsBuyToLet
    {
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('buy to let');
        }
    }
     //c0782 REAC changes start
    public List<SelectOption> getItemsFinance() {
    List<SelectOption> options = new List<SelectOption>();
    
     if(opp.Interested_in__c.Contains('REAC')){
     options.add(new SelectOption('--None--','--None--'));
     options.add(new SelectOption('Home improvements','Home improvements'));
     options.add(new SelectOption('Furnishings','Furnishings'));
     options.add(new SelectOption('Car purchase','Car purchase'));
     options.add(new SelectOption('3rd party Debt consolidation','3rd party Debt consolidation'));
     options.add(new SelectOption('Property purchase/deposit','Property purchase/deposit'));
     options.add(new SelectOption('Other','Other'));
     }
     else{
     options.add(new SelectOption('--None--','--None--'));
     options.add(new SelectOption('Home improvements',' Home improvements'));
     options.add(new SelectOption('Repay home improvements','Repay home improvements'));
     options.add(new SelectOption('Repay car loan','Repay car loan'));
     options.add(new SelectOption('Pay school fees','Pay school fees'));
     options.add(new SelectOption('Purchase pension','Purchase pension'));
     options.add(new SelectOption('Repay other debts','Repay other debts'));
     options.add(new SelectOption('Cost & fees for home finance arrangement','Cost & fees for home finance arrangement'));
     options.add(new SelectOption('Deposit on additional property','Deposit on additional property'));
     options.add(new SelectOption('Other','Other'));
     options.add(new SelectOption('Personal debt consolidation to a family member or friend','Personal debt consolidation to a family member or friend'));
     options.add(new SelectOption('Gift/donation to a family member friend or charitable organisation','Gift/donation to a family member friend or charitable organisation'));
     options.add(new SelectOption('Funeral expenses','Funeral expenses'));
     options.add(new SelectOption('Business purposes','Business purposes'));
     options.add(new SelectOption('Investment (including stocks, shares or third parties)','Investment (including stocks, shares or third parties)'));
     options.add(new SelectOption('Third party debt consolidation for a family member or friend','Third party debt consolidation for a family member or friend'));
     }
    return options;
   } 
 //CO782 REAC changes end
}