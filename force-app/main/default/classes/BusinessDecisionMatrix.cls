/* ------------------------------------------------------------------------------ */
/* C00233    New class to decipher the Decision Matrix for Business Accounts      */
/* ------------------------------------------------------------------------------ */

public without sharing class BusinessDecisionMatrix
{
    
    public Applicant__c theApplicant {get;set;}
    public boolean doAML {get;set;}
    public boolean doCredit {get;set;}
    public boolean doSanction {get;set;}
    public boolean ignoreApplicant {get;set;}
    public boolean doSetUp {get;set;} 
    public List<BAADecisionEngineMatrix__c> DEMatrixList {get;set;}   
    public Map<string, BAADecisionEngineMatrix__c> DEMatrixMap {get;set;} 
    public boolean ApplicantFound {get;set;}

    public BusinessDecisionMatrix (Applicant__c applicant, List<BAADecisionEngineMatrix__c> theMatrixList )
    {
        ApplicantFound = false;
        List<Applicant__c> theApplicantList = [SELECT    Id,
                                                        Prospect_Customer__c, 
                                                        Applicant_Number__c ,
                                                        Is_Director__c,
                                                        Is_Shareholder__c,
                                                        Is_Signatory__c
                                               FROM    Applicant__c
                                               WHERE    id = :applicant.id];
        
        if (theApplicantList.Size() > 0)
        {
            theApplicant = theApplicantList[0];
            DEMatrixList = theMatrixList;
        
            ProcessApplicant (); 
            ApplicantFound = true;   
        }
                                           
         
    }
    
    public void ProcessApplicant ()
    {
        doAML = false;
        doCredit = false;
        doSanction = false;
        ignoreApplicant = true;
        doSetUp = false;
        
        DEMatrixMap = new Map<string, BAADecisionEngineMatrix__c> ();                                                 
        for (BAADecisionEngineMatrix__c DEMatrix : DEMatrixList)
        {
            system.debug ( 'This is the entity type ' + DEMatrix.EntityType__c);
            DEMatrixMap.put (DEMatrix.EntityType__c, DEMatrix);
        }
        
        List<string> entities = new List<string>();
        
        if (!String.IsEmpty(theApplicant.Is_Director__c) && theApplicant.Is_Director__c.EqualsIgnoreCase('YES'))
        {
            
            entities.Add ('Director');
        }
        
        if (!String.IsEmpty(theApplicant.Is_Shareholder__c) && theApplicant.Is_Shareholder__c.EqualsIgnoreCase('YES'))
        {
           
           entities.Add ('Shareholder');
        }
        
        if (!String.IsEmpty(theApplicant.Is_Signatory__c) && theApplicant.Is_Signatory__c.EqualsIgnoreCase('YES'))
        {
            
            entities.Add ('Signatory');
        }
        
        
        system.debug ('The entities ' + entities);
        //boolean credFound = false;
        //boolean amlFound = false;
        for ( string entity :entities )
        {
            BAADecisionEngineMatrix__c matrix = new BAADecisionEngineMatrix__c ();
            if (!String.IsEmpty(entity))
            {
                system.debug ('The entity ' + entity);
                system.debug ('The map ' + DEMatrixMap);
                matrix = DEMatrixMap.get (entity);
                system.debug ( 'The matrix ' + matrix);
                if (matrix.DoAML__c)
                {
                    doAML = matrix.DoAML__c;
                }
                
                if (matrix.DoCredit__c)
                {
                    doCredit = matrix.DoCredit__c;
                }
                
                if (matrix.DoSanction__c)
                {
                    doSanction = matrix.DoSanction__c;
                }
                
                if (matrix.DoSetUp__c)
                {
                    doSetUp = matrix.DoSetUp__c;
                }
                
             }            
        }
        
        if (!doAML && !doCredit && !doSanction)
        {
           IgnoreApplicant = true;
        }
        else
        {
            IgnoreApplicant = false;
        }
        
        
    }

}