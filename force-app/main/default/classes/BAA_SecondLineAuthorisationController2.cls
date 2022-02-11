/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_SecondLineAuthorisationController2 extends HPPBaseEventController
{
    public string applicationState {get;set;}
    
    public Boolean Declined {get;set;}
    
    public Opportunity thisOpp 
    {
        get
        {
            if (thisOpp == null)
            {
                thisOpp = [SELECT    Proof_of_ID_obtained__c,
                                      Proof_of_Address_obtained__c,
                                      Company_evidence_obtained__c,
                                      Registered_address_evidence_obtained__c,
                                      Trading_address_evidence_obtained__c,
                                      Legible_Photocopies__c,
                                      Certified_all_photocopies__c,
                                      Sanction_Check__c,
                                      PEP_Check__c,
                                      All_pages_intialled__c,
                                      Alterations_countersigned__c,
                                      Signatures_confirmed__c,
                                      Business_name_match__c,
                                      Signed_matrix__c,
                                      Seller_Comments__c,
                                      Approver_Comments__c,
                                      X2nd_Line_Authorisation_Decision_1__c ,
                                      X2nd_Line_Authorisation_Decision_Date_1__c ,
                                      NPAA_Approver_Name__c ,
                                      X2nd_Line_Authorisation_Decision_2__c,
                                      X2nd_Line_Authorisation_Decision_Date_2__c
                             FROM     Opportunity 
                             WHERE    Id = :Opp.Id];
                                        
            }
            return thisOpp;
        }
        set;
    }

    public RecordType recTypeCase 
    {
        get 
        {
            if (recTypeCase == null){            
                recTypeCase = [select id from recordType where  sobjectType='case' and DeveloperName = 'Further_Information' limit 1];
            }
            return recTypeCase ;
        }
        set;
    }
    public String AddFiText {get;set;}
    
    public List<Case> FiCases{get;set;}

    public BAA_SecondLineAuthorisationController2 ()
    {
    }
    
    public PageReference Setup()
    {
        FiCases = [select CaseNumber, 
                            id,
                            satisfied__c, 
                            Further_Information__c, 
                            Further_Info_Satisfied__c , 
                            underwriter_comments__c,  
                            BDM_comments__c,  
                            createddate, 
                            CreatedBy.Name 
                    from case 
                    where Opportunity__c=:opp.id 
                    and Pre_or_Post_Case__c='PRE' ];
                    
        return CorrectPage('BAA_SecondLineAuth2');
    }
    
    public PageReference Save()
    {
        update thisOpp;
        update FiCases;
        return CorrectPage('BAA_SecondLineAuth2');
    }
    
    public PageReference Complete()
    {
         //Update thisOpp;
         if (thisOpp.StageName == 'Application Declined')
         {
             CompleteEvent();
             return GoToNextEvent();
         }
         else if (thisOpp.StageName == 'Application Authorised')
         {
             CompleteEvent();
             return GoToNextEvent();
         }
         else
         {
             return CorrectPage('BAA_SecondLineAuth2');
         }
         
         
    }
    
    public PageReference Authorise ()
    {
         if (String.IsBlank(thisOpp.X2nd_Line_authorisation_Decision_1__c))
        {
            thisOpp.X2nd_Line_authorisation_Decision_1__c = 'Authorised';
            thisOpp.X2nd_Line_Authorisation_Decision_Date_1__c = Date.Today();
        }
        else
        {
            thisOpp.X2nd_Line_authorisation_Decision_2__c = 'Authorised';
            thisOpp.X2nd_Line_Authorisation_Decision_Date_2__c = Date.Today();
        }
        thisOpp.NPAA_Approver_Name__c = UserInfo.getName();
        thisOpp.StageName = 'Application Authorised';
        thisOpp.Opportunity_Status__c = 'Application Authorised';
        update thisOpp;
        
        
        return Complete();
    }
    
    public PageReference FurtherInformation ()
    {
        thisOpp.X2nd_Line_authorisation_Decision_1__c = 'Further Information';
        thisOpp.X2nd_Line_Authorisation_Decision_Date_1__c = Date.Today();
        thisOpp.NPAA_Approver_Name__c = UserInfo.getName();
        thisOpp.StageName = 'Further Information';
        thisOpp.Opportunity_Status__c = 'Further Information';
        update thisOpp;
        update FiCases;
        return CorrectPage('BAA_SecondLineAuth2');
    }
    
    public PageReference Decline ()
    {
        if (String.IsBlank(thisOpp.X2nd_Line_authorisation_Decision_1__c))
        {
            thisOpp.X2nd_Line_authorisation_Decision_1__c = 'Declined';
            thisOpp.X2nd_Line_Authorisation_Decision_Date_1__c = Date.Today();
        }
        else
        {
            thisOpp.X2nd_Line_authorisation_Decision_2__c = 'Declined';
            thisOpp.X2nd_Line_Authorisation_Decision_Date_2__c = Date.Today();
        }
        thisOpp.NPAA_Approver_Name__c = UserInfo.getName();
        thisOpp.StageName = 'Application Declined';
        thisOpp.Opportunity_Status__c = 'Application Declined';
        update thisOpp;
        Declined = true;
        return null;
    }
    
    
    
    public PageReference AddCase()
    {
        Case c = new Case();
        c.recordTypeid = recTypeCase.id ;
        c.Further_Information__c = 'Enter Information';
        c.Opportunity__c = opp.id;
        c.Subject = 'Further information for ' + Opp.Name;
        c.Description = c.Subject;
        c.Priority = 'Medium';
        c.Status = 'Open';
        c.Origin = 'Salesforce';
        c.ContactId =  Accounts[0].PersonContactId ;
        if(Opp.Seller__c != null)
        {
            c.OwnerId = opp.Seller__c;
        }
        c.Pre_or_Post_Case__c='PRE';
        c.Further_Info_Satisfied__c = 'No';
        insert c;
        
        Case newCase = [select id,
                                satisfied__c, 
                                casenumber, 
                                Further_Information__c, 
                                Further_Info_Satisfied__c , 
                                underwriter_comments__c,  
                                BDM_comments__c,  
                                createddate, 
                                CreatedBy.Name 
                        from case where id=:c.id ];
                        
        FiCases.add(newCase);
        AddFiText ='';
        SaveFurtherInfo();
        return null;
    }
    
    public Integer delFI{get;set;}
    public PageReference DeleteFI()
    {
        system.debug('Del FI index : ' + delFI);
    
        Case c = FICases[delFI];
        
        delete c;
        
        FiCases = [select CaseNumber, 
                            id,satisfied__c, 
                            Further_Information__c, 
                            Further_Info_Satisfied__c , 
                            underwriter_comments__c,  
                            BDM_comments__c,  
                            createddate, 
                            CreatedBy.Name 
                   from case 
                   where Opportunity__c=:opp.id 
                   and Pre_or_Post_Case__c='PRE' ];
    
        
        return CorrectPage('BAA_SecondLineAuth2');
    }
    
    public void SendEmail (string recipient, string recipientEmail, string subject, boolean attachCase, string caseid, string context) 
    {
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        string theSubject = context + (attachCase == true ? ' new case ' + case.id : '');
        string theHtmlBody = theSubject + (attachCase == true ? ' <p>To view the case <a href=' + sfdcBaseURL +'/' + case.id + '>click here.</a>' : '');
         
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {recipientEmail}; 
        mail.setToAddresses(toAddresses);
        mail.setReplyTo('support@acme.com');
        mail.setSenderDisplayName('');
        
        mail.setSubject(theSubject);
        
        
        mail.setHtmlBody(theHtmlBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    private void SaveFurtherInfo()
    {
        ThisOpp.Stagename = 'Affordability Assesment';
        
        
        if(ExOpp.Pre_Val_1_Date__c == null)
        {
            ExOpp.Pre_Val_1_Date__c = Date.today();
        }
        ExOpp.Pre_Val_decision_1_underwriter__c = UserInfo.getName();
        
        ExOpp.Pre_Val_Dec_1__c = 'Further Information Required';        
        thisOpp.Status_HPP_CAA__c= 'Affordability Further Information';
        
        update FiCases;
        update ExOpp;
        update thisOpp;
    }
}