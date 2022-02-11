public class HPPApplicationSignedHelper
{
    public List<Account> Accounts{get;set;}
    public Opportunity Opp{get;set;}
    public IBB_Product__c Product{get;set;}
    public Map<String,String> RelationShips{get;set;} 
    
    public HPPApplicationSignedHelper (List<Account> a, Opportunity o, IBB_Product__c p,Map<String,String> relationShip)
    {
        Accounts = a;
        Opp = o;
        Product = p;
        RelationShips = relationShip;
    }
    
    private Account_with_IBB__c GetAccount()
    {
        List<Account_with_IBB__c> existingAccount = [select id,Primary_SFDC_Account__c,IBB_Product__c,Opportunity__c   from Account_with_IBB__c where Opportunity__c =:opp.id limit 1];
        if(existingAccount.size() == 1)
            return existingAccount[0];
            
        return new Account_with_IBB__c();
    }
    
    private void UpsertAccount(Account_with_IBB__c accIBB)
    {
        accIBB.Primary_SFDC_Account__c = Accounts[0].id;
        accIBB.IBB_Product__c = Product.id;
        accIBB.Opportunity__c = Opp.id;        
        upsert accIBB;
    }
    
    public Boolean Run()
    {
        Account_with_IBB__c accIBB = GetAccount();
        UpsertAccount( accIBB);    
        
        opp.Account_with_IBB__c = accIBB.id; 
        update opp;       
        
        List<Asset_Relationship__c > lstAss = new List<Asset_Relationship__c >();        
        List<Asset_Relationship__c > existing = [select id, Account_with_IBB__c , Prospect_Customer__c from Asset_Relationship__c  where Account_with_IBB__c =: accIBB.id ];
                
        for(Account a : Accounts)
        {
            Boolean found= false;
            for(Asset_Relationship__c ar : existing  )
            {
                if(ar.Prospect_Customer__c  == a.id)
                {
                    found = true;
                    lstAss.add(ar);
                }
            }
        
            if(!found)
            {
                Asset_Relationship__c ass = new Asset_Relationship__c();
                ass.Account_with_IBB__c = accIBB.id;
                ass.Prospect_Customer__c = a.id;
                lstAss.add(ass);
            }
        }
        lstAss[0].Primary_Account_Holder__c = true;
        
        List<EBS_Relationship__c> relations = [select code__c, text__c from EBS_Relationship__c order by code__c];

        Integer count = Accounts.size();
        system.debug('Relationship count:' + count);
        for(Integer i = 1; i< count;i++)
        {
            String code = RelationShips.get(Accounts[i].id);
            system.debug('Relationship code :' + code);
            for(EBS_Relationship__c ebs : relations )
            {
                if(ebs.code__c == code)
                {
                    //Integer ty = 1/0;
                    lstAss[i].Relationship_To_Primary_Applicant1__c = ebs.text__c;
                }
            }
        
        
            
        }
        upsert lstAss;
        
        return true;
    }
}