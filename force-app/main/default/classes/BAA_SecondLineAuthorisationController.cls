/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_SecondLineAuthorisationController extends HPPBaseEventController
{
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



    public BAA_SecondLineAuthorisationController ()
    {
    }
    
    public PageReference Setup()
    {
        //FiCases = [select CaseNumber, id,satisfied__c, Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where Opportunity__c=:opp.id and Pre_or_Post_Case__c='PRE' ];
        return CorrectPage('BAA_SecondLineAuth');
    }
    
    
    
    public PageReference Complete()
    {
         Update thisOpp;
         CompleteEvent();
         return GoToNextEvent();
    }
    
    
}