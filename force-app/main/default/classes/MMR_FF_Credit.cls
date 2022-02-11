public class MMR_FF_Credit extends MMR_PageControllerBase
{
    public List<Account> Accs{get;set;}
    
    public PageReference Setup_Credit()
    {
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Credit') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        
        
        return null;
    }
    
    public PageReference Next()
    {
        SaveData();
        return new PageReference('/apex/mmr_ff_budgetplanner?id=' + eventid);
    }
    
    public PageReference Previous()
    {
        SaveData();
        return new PageReference('/apex/mmr_ff_financial?id=' + eventid);
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
    
    private void LoadCCJs()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Credit_CCJ') + ' from GenericObject__c where Type__c=\'CCJ\' and Account__c in' + AccountIds ;
        m_AllCCJs= DataBase.Query(soql);
        
    }
    
    Transient List<GenericObject__c> m_AllCCJs;    
    public List<GenericObject__c> AllCCJs
    {
        get{
            if(m_AllCCJs== null)
            {
                LoadCCJs();
            }
            return m_AllCCJs;
        }       
    }
    
    public List<GenericObject__c> GetCCJs(String applicantNo)
    {
        String id = Accs [integer.valueof(applicantNo)-1].id;
        system.debug('Acc Id ' + id);
        system.debug('ACc list ' + lstAccountIds );
        List<GenericObject__c> lst= new List<GenericObject__c>();
        for(GenericObject__c p : AllCCJs)
        {
            if(p.Account__c== id)
            {
                lst.add(p);
            }
        }    
    
        return lst;
    }


    public PageReference SaveCCJ()
    {
        Boolean isNew = true;
        GenericObject__c prop = new GenericObject__c();
        prop.type__c = 'CCJ';
        prop.Account__c= EditCCJ.Account__c;
        System.debug('ID:' + EditCCJ.id);
        
        if(EditCCJ.id != null )
        {
                      
                    
                    String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Credit_CCJ') + ' from GenericObject__c where id= \'' + EditCCJ.id + '\'';
                    
                    List<GenericObject__c> props = database.query(soql);
                    
                    if(props.size() > 0)
                    {
                        prop = props[0];
                    }
                  
                    
                    isNew = false;
                    
                    system.debug('Found property id :' + EditCCJ.id);
           
        }
        
        
                 
        //prop.Account__c= EditCCJ.Account__c;
        prop.CCJ_date_of_CCJ__c= EditCCJ.CCJ_date_of_CCJ__c;
        prop.CCJ_amount_of_CCJ__c= EditCCJ.CCJ_amount_of_CCJ__c;
        prop.CCJ_date_repaid__c= EditCCJ.CCJ_date_repaid__c;
        prop.CCJ_certificate_held__c= EditCCJ.CCJ_certificate_held__c;                                
        prop.CCJ_Reason__c= EditCCJ.CCJ_Reason__c;  
    

        
        system.debug(prop);
        
        
        try
        {
            upsert prop;
            EditCCJ = new GenericObject__c();
            LoadCCJs();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
    
    public GenericObject__c EditCCJ
    {
        get{
            if(EditCCJ== null)
            {
                EditCCJ= new GenericObject__c();
            }
            return EditCCJ;
        }
        set;
    }
    
    public PageReference RemoveItem(String id)
    {
        Integer i = 0;
        GenericObject__c del;
        
        for(GenericObject__c p : AllCCJs)
        {
            if(p.id == id)
            {
                del = AllCCJs.Remove(i);
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


// Defaults 


    private void LoadDefaults()
    {
        String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Credit_Default') + ' from GenericObject__c where Type__c=\'Default\' and Account__c in' + AccountIds ;
        m_AllDefaults= DataBase.Query(soql);
        
    }
    
    Transient List<GenericObject__c> m_AllDefaults;    
    public List<GenericObject__c> AllDefaults
    {
        get{
            if(m_AllDefaults== null)
            {
                LoadDefaults();
            }
            return m_AllDefaults;
        }       
    }
    
    public List<GenericObject__c> GetDefaults(String applicantNo)
    {
        String id = Accs [integer.valueof(applicantNo)-1].id;
        system.debug('Acc Id ' + id);
        system.debug('ACc list ' + lstAccountIds );
        List<GenericObject__c> lst= new List<GenericObject__c>();
        for(GenericObject__c p : AllDefaults)
        {
            if(p.Account__c== id)
            {
                lst.add(p);
            }
        }    
    
        return lst;
    }


    public PageReference SaveDefault()
    {
        Boolean isNew = true;
        GenericObject__c prop = new GenericObject__c();
        prop.type__c = 'Default';
        prop.Account__c= EditDefault.Account__c;
        System.debug('ID:' + EditDefault.id);
        
        if(EditDefault.id != null)
        {
                      
                    
                    String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_FF_Credit_Default') + ' from GenericObject__c where id= \'' + EditDefault.id + '\'';
                    
                    List<GenericObject__c> props = database.query(soql);
                    
                    if(props.size() > 0)
                    {
                        prop = props[0];
                    }
                  
                    
                    isNew = false;
                    
                    system.debug('Found property id :' + EditDefault.id);
           
        }
        
        
                 
        //prop.Account__c= EditDefault.Account__c;
        prop.Default_date__c= EditDefault.Default_date__c;
        prop.Default_amount__c= EditDefault.Default_amount__c;
        prop.Default_date_repaid__c= EditDefault.Default_date_repaid__c;
        prop.Default_reason__c= EditDefault.Default_reason__c;                                
        

        
        system.debug(prop);
        
        
        try
        {
            upsert prop;
            EditDefault= new GenericObject__c();
            LoadDefaults();
        }
        catch(Exception ex)
        {
            
        }
        return null;
    }
    
    public GenericObject__c EditDefault
    {
        get{
            if(EditDefault== null)
            {
                EditDefault= new GenericObject__c();
            }
            return EditDefault;
        }
        set;
    }
    
    public PageReference RemoveDefault(String id)
    {
        Integer i = 0;
        GenericObject__c del;
        
        for(GenericObject__c p : AllDefaults)
        {
            if(p.id == id)
            {
                del = AllDefaults.Remove(i);
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







// End Defaults 

    private void SaveData()
    {
         try
        {
        //update num btl and num properties        
        
        
        
        update Accs;
        
        }
        catch(Exception ex)
        {
        
        }
    }

    
    public PageReference Save()
    {
       SaveData();
        return null;
    }

}