public class MMR_FF_BTLLC_Financial extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    public Opportunity Opp{get;set;}
	public List<GenericObject__c> DepositSource{get;set;}
    public List<GenericObject__c> RefinanceSource{get;set;}
    
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
        // C0644 getting exceptions within the try/catch below but could not trace the reason so removing it.
		//       No data errors where present or unsaved data at the time
		
		//try
        //{
            update Accs;
            update DepositSource;
            update RefinanceSource;
            return true;
        //}
        //catch(Exception ex)
        //{
            //return false;
        //}
    }
    
    public PageReference Next()
    {
        if(SaveData())
        {
            return new PageReference('/apex/mmr_ff_btllc_credit?id=' + eventid);
        }
        return null;
    }
    
    public PageReference Previous()
    {
        if(SaveData())
        {
            return new PageReference('/apex/mmr_ff_btllc_income?id=' + eventid);
        }
        return null;
    }    
    
    public List<Person_Debts__c> GetDebts(String applicantNo)
    {
        String id = Accs [integer.valueof(applicantNo)].id;
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
        String id = Accs [integer.valueof(applicantNo)].id;
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
            Integer i = 0;
            for(Account a : Accs )
            {
                if(i>0)
				{
					options.add(new SelectOption(a.id,'Director ' + i + ' ' +a.name));
				}
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
    
}