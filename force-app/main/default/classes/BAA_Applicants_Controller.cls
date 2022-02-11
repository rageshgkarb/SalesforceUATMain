/* --------------------------------------------------------------------------------------------  */
/* C0307                                            */            
/* --------------------------------------------------------------------------------------------  */


public class BAA_Applicants_Controller extends HPPBaseEventController
{
    public CPF_Relationship__c tempRel {get;set;}
    public CPF_Relationship__c Relationship{get;set;}
    public String RemoveEditRelationship{get;set;}
    public String ExistingRel{get;set;}
    
    public Account Acc{get;set;}
    
    public Account EditAcc{get;set;}
    public String Title{get;set;}
    
    public List<CPF_Relationship__c> Accs{
        get{            
            List<CPF_Relationship__c> tempAccs = [select id,child_account__r.name,child_account__c,child_account__r.firstname,child_account__r.lastname,child_account__r.salutation, child_account__r.Middle_Name__pc,
                        child_account__r.Gender__c, child_account__r.Home_Telephone_No__c, child_account__r.Phone, child_account__r.PersonEmail, child_account__r.IsPersonAccount,
                        Shareholder_Percentage__c, Position_Held__c , Is_Director__c ,Is_Shareholder__c ,Is_Signatory__c 
            /* C0307 */
      , Is_Trustee__c
            , Is_BeneficialOwner__c
            , Is_Settlor__c
            /* C0307 end */
                        from CPF_Relationship__c where parent_Account__c =: Acc.id  and child_account__c not in 
                            (
                                select Prospect_Customer__c from applicant__c where opportunity__c=:opportunityId
                            )
                            and child_account__c != null
                          ];
            return tempAccs;
        }
    } 
    
    public List<SelectOption> RelatedAccounts
    {
        get{
            system.debug('ACCOUUNTS:' + Accs);
        
            List<SelectOption> options = new List<SelectOption>();
            options.add(new selectOption('--Select--',''));
            
            for(CPF_Relationship__c r : Accs)
            {
                options.add(new SelectOption(r.id,r.child_account__r.name));
            }
            return options;
        }
    }
    
    
    public List<Applicant__c> AppAccs{
        get{            
            recordType rec = [select id from recordtype where developername='ProspectCustomer'];
                            
        
            List<Applicant__c> tempAccs = [select id,Prospect_Customer__r.name,Prospect_Customer__c,Prospect_Customer__r.firstname,Prospect_Customer__r.lastname,Prospect_Customer__r.salutation, Prospect_Customer__r.Middle_Name__pc,
                        Prospect_Customer__r.Gender__c, Prospect_Customer__r.Home_Telephone_No__c, Prospect_Customer__r.Phone, Prospect_Customer__r.PersonEmail, Prospect_Customer__r.IsPersonAccount,
                        CPF_Relationship__r.Shareholder_Percentage__c, CPF_Relationship__r.Position_Held__c , CPF_Relationship__r.Is_Director__c ,CPF_Relationship__r.Is_Shareholder__c ,CPF_Relationship__r.Is_Signatory__c,
                        Is_Director__c, Is_ShareHolder__c, Is_Signatory__c
            /* C0307 */
            , CPF_Relationship__r.Is_Trustee__c
            , CPF_Relationship__r.Is_BeneficialOwner__c
            , CPF_Relationship__r.Is_Settlor__c
            , Is_Trustee__c
            , Is_BeneficialOwner__c
            , Is_Settlor__c
            /* C0307 end */
                        from Applicant__c where Opportunity__C=: opportunityId and Prospect_Customer__r.recordtypeid =:rec.id 
                            
                        ];
            return tempAccs;
        }
    } 
    

    public BAA_Applicants_Controller()
    {
        EditAcc = new Account(RecordTypeId = recType.Id, FirstName='', LastName='');
        Relationship = new CPF_Relationship__c ();
        tempRel = new CPF_Relationship__c ();
    }

    public PageReference Setup()
    {
        system.debug('Apps:' + Applicants);
        system.debug('Accs:' + Acc);
        
        List<Account> tempAccount = [select id, name from Account where id =: BaseOpportunity.AccountId];
        
        
        if(tempAccount.size() == 1)
        {
            Acc = tempAccount[0];
        }
        
            system.debug('Applicants:' + Applicants );
         system.debug('ACC:' + acc);  
        
        return null;
    }    
    
    public List<SelectOption> salutationList {
        get {
            if (salutationList == null){
                salutationList = new List<SelectOption>();
                salutationList.add(new SelectOption('None','--None--'));
                salutationList.add(new SelectOption('Mr','Mr'));
                salutationList.add(new SelectOption('Mrs','Mrs'));
                salutationList.add(new SelectOption('Ms','Ms'));
                salutationList.add(new SelectOption('Dr','Dr'));
                salutationList.add(new SelectOption('Miss','Miss'));
                salutationList.add(new SelectOption('Master','Master'));
                salutationList.add(new SelectOption('Prof','Prof'));
                salutationList.add(new SelectOption('Lady','Lady'));
                salutationList.add(new SelectOption('Captain','Captain'));
                salutationList.add(new SelectOption('Mx','Mx'));
            }
            return salutationList;
        }
        set;
    }
    
    public PageReference DeleteRelationship()
    {
        ShowPopup = false;
        //List<CPF_Relationship__c> edit= [select id,Is_Director__c, Is_Shareholder__c,Is_Signatory__c, Shareholder_Percentage__c, Position_Held__c
        //                                 from CPF_Relationship__c where id=:RemoveEditRelationship];
        
        List<Applicant__c> edit = [select id from applicant__c where id=:RemoveEditRelationship];
        
        
        if(edit.size() != 1)return null;
        
        delete edit;        

        
        return null;
    }
    
    public PageReference Edit()
    {
        ShowPopup = false;
        
        List<Applicant__c> tempApplicant = [select id, CPF_Relationship__c from Applicant__c where id=:RemoveEditRelationship ];
        
        if(tempApplicant.size() == 0)
            return null;
        
        List<CPF_Relationship__c> edit= [select id,Is_Director__c, Is_Shareholder__c,Is_Signatory__c, Shareholder_Percentage__c, Position_Held__c,child_account__c
                    /* C0307 */
                    , Is_Trustee__c
            , Is_BeneficialOwner__c
            , Is_Settlor__c
            /* C0307 end */
                                         from CPF_Relationship__c where id=:tempApplicant[0].CPF_Relationship__c];
        
        if(edit.size() != 1)return null;
        
        RelationShip=Edit[0];
        
        Applicant__c Applicant = [select Is_Director__c,Is_Shareholder__c ,Position_Held__c,Shareholder_Percentage__c
              /* C0307 */
                              , Is_Trustee__c
                      , Is_BeneficialOwner__c
                      , Is_Settlor__c
                      /* C0307 end */
                  from Applicant__c  where id=:RemoveEditRelationship ];
        
        Applicant.Is_Director__c= Relationship.Is_Director__c;
        Applicant.Is_Shareholder__c =Relationship.Is_Shareholder__c ;
        Applicant.Is_Signatory__c =Relationship.Is_Signatory__c ;
        Applicant.Position_Held__c =Relationship.Position_Held__c ;
        Applicant.Shareholder_Percentage__c =Relationship.Shareholder_Percentage__c ;
    
    /* C0307 */
    
    Applicant.Is_Trustee__c = Relationship.Is_Trustee__c;
    Applicant.is_BeneficialOwner__c = Relationship.Is_Beneficialowner__c;
    Applicant.Is_Settlor__c = Relationship.Is_Settlor__c;
    
    /* C0307 end */
        update Applicant;
        
        
        EditAcc= [select id,name,firstname,lastname,salutation, Middle_Name__pc, 
                    Share_holding_in_the_business__c, Position_Held__pc, Gender__c, Home_Telephone_No__c, Phone, PersonEmail, IsPersonAccount
                    from account where id=:edit[0].Child_account__c];

        Title = EditAcc.Salutation;

        ShowPopup = true;
        return null;
    }
    
    public PageReference AddNew()
    {
        EditAcc = new Account();
        Title = null;
        ShowPopup = true;
        return null;
    }
    
    public PageReference AddExistingRel()
    {
        ShowPopup = false;
        
        Relationship = [select id,child_account__r.name,child_account__c,child_account__r.firstname,child_account__r.lastname,child_account__r.salutation, child_account__r.Middle_Name__pc,
                        child_account__r.Gender__c, child_account__r.Home_Telephone_No__c, child_account__r.Phone, child_account__r.PersonEmail, child_account__r.IsPersonAccount,
                        Shareholder_Percentage__c, Position_Held__c , Is_Director__c ,Is_Shareholder__c ,Is_Signatory__c
    /* C0307 */
                    , Is_Trustee__c
            , Is_BeneficialOwner__c
            , Is_Settlor__c
            /* C0307 end */
                    from CPF_Relationship__c
                    where id=:ExistingRel limit 1];
        
        
        system.debug('Look for account ' + Relationship.child_account__c);
         List<Account> tempAccounts = [select id,name,firstname,lastname,salutation, Middle_Name__pc, 
                    Share_holding_in_the_business__c, Position_Held__pc, Gender__c, Home_Telephone_No__c, Phone, PersonEmail, IsPersonAccount
                    from account where id=:Relationship.child_account__c ];
                    
                   
                    
        EditAcc = tempAccounts[0];   
        UpdateApplicant(EditAcc.id,Relationship);    
        Title = EditAcc.Salutation;          
        ShowPopup = true;
        tempRel.child_account__c = null;
    
        return null;
    }
    
    public PageReference AddExisting()
    {
        ShowPopup = false;
         system.debug('Look for account ' + EditAcc.Id);
         List<Account> tempAccounts = [select id,name,firstname,lastname,salutation, Middle_Name__pc, 
                    Share_holding_in_the_business__c, Position_Held__pc, Gender__c, Home_Telephone_No__c, Phone, PersonEmail, IsPersonAccount
                    from account where id=:tempRel.Child_Account__c ];
                    
         if(tempAccounts.size() == 0)
         {
             tempRel.Child_Account__c.addError('empty');
             return null;
         }
        
        EditAcc = tempAccounts[0];      
        Title = EditAcc.Salutation;          
        ShowPopup = true;
        tempRel.Child_Account__c = null;
        return null;
    }
    
    public boolean ShowPopup{get;set;}
    
    
    public void UpdateApplicant(string accountId, CPF_Relationship__c link)
    {
        //find applicant
        system.debug('Find applicant:' + accountId);
        
         List<Applicant__c> existingApplicants = [select id, CPF_Relationship__c,opportunity__c,Primary_Account_Holder__c ,Prospect_Customer__c ,Shareholder_Percentage__c ,Position_Held__c,
                                                 Is_Director__c ,Is_Shareholder__c ,Is_Signatory__c 
    /* C0307 */
                    , Is_Trustee__c
            , Is_BeneficialOwner__c
            , Is_Settlor__c
            /* C0307 end */
                                                  from Applicant__c where Prospect_Customer__c=:accountId and Opportunity__c=:opportunityid];
         
         
         Applicant__c newApplicant;
         if(existingApplicants.size() == 0)
         {
             //add new applicant
             newApplicant = new Applicant__c();   
         }
         else
         {
             newApplicant = existingApplicants[0];
         }
             
             newApplicant.CPF_Relationship__c = link.id;
             
             system.debug('newApp:'+newApplicant);
             
             if(newApplicant.Opportunity__c == null)
                 newApplicant.Opportunity__c = opportunityId;
                 
                 
             newApplicant.Primary_Account_Holder__c = false;
             newApplicant.Prospect_Customer__c = accountId;
             newApplicant.Is_Director__c = link.Is_Director__c;
             newApplicant.Is_Shareholder__c = link.Is_Shareholder__c;
             newApplicant.Is_Signatory__c = link.Is_Signatory__c ;
             newApplicant.Shareholder_Percentage__c = link.Shareholder_Percentage__c ;
             newApplicant.Position_Held__c= link.Position_Held__c;
  /* C0307 */
      
      newApplicant.Is_Trustee__c = link.Is_Trustee__c;
      newApplicant.is_BeneficialOwner__c = link.Is_Beneficialowner__c;
      newApplicant.Is_Settlor__c = link.Is_Settlor__c;
      
      /* C0307 end */
             
             system.debug('new applicant:' + newApplicant);
         
             upsert newApplicant;
    }
    
    public PageReference SaveAccount()
    {
        showPopup = false;
         Account tempAccount = new Account(RecordTypeId = recType.Id, FirstName='Temp', LastName='Account');
         system.debug(EditAcc);
         if(EditAcc.id != null)         
         {
             system.debug('Look for account ' + EditAcc.Id);
             List<Account> tempAccounts = [select id,name,firstname,lastname,salutation, Middle_Name__pc, 
                        Share_holding_in_the_business__c, Position_Held__pc, Gender__c, Home_Telephone_No__c, Phone, PersonEmail, IsPersonAccount
                        from account where id=:EditAcc.id ];
                        
             if(tempAccounts.size() == 1)
                 tempAccount = tempAccounts[0];
         }
         
         //boolean toAdd = tempAccount.id == null;
         
         tempAccount.Salutation= Title;
         tempAccount.FirstName = EditAcc.FirstName;
         tempAccount.Middle_Name__pc = EditAcc.Middle_Name__pc;
         tempAccount.LastName= EditAcc.LastName;

         system.debug('Applicants:' + Applicants );
         system.debug('ACC:' + acc);                   
         upsert tempAccount;
         
         //add in the account relationship if this is a new account
         CPF_Relationship__c tempRelationship;
         
         List<CPF_Relationship__c> tempRels = [select id from CPF_Relationship__c where parent_account__c =:acc.id and child_account__c =: tempAccount.id];          
         
         if(tempRels.size()== 0 )
         {
             tempRelationship = new CPF_Relationship__c ();
         }
         else
         {
             tempRelationship = tempRels[0];
         }
             
         tempRelationship.Parent_account__c = acc.id;
         tempRelationship.Child_account__c = tempAccount.id;
         tempRelationship.Is_Director__c = RelationShip.Is_Director__c ;
         tempRelationship.Is_Shareholder__c = RelationShip.Is_Shareholder__c ;
         tempRelationship.Is_Signatory__c = RelationShip.Is_Signatory__c ;
         tempRelationship.Shareholder_Percentage__c = RelationShip.Shareholder_Percentage__c ;
         tempRelationship.Position_Held__c= RelationShip.Position_Held__c;
     
     /* C0307 */
      
      tempRelationship.Is_Trustee__c = RelationShip.Is_Trustee__c;
      tempRelationship.is_BeneficialOwner__c = RelationShip.Is_Beneficialowner__c;
      tempRelationship.Is_Settlor__c = RelationShip.Is_Settlor__c;
      
      /* C0307 end */
     
         upsert tempRelationship;
         
         system.debug('temp ' + tempRelationship);
         
         UpdateApplicant(tempAccount.id,tempRelationship);
            
        return null;
    }
}