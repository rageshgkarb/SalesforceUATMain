public class HPPConfirmedROTController extends HPPBaseEventController {
    public String pageErrorMessage { get; private set; }
    public Boolean rotAccepted {
        get {
            return (String.isNotBlank(exOpp.ROT_acceptable__c) && exOpp.ROT_acceptable__c == 'Yes');
        }
    }
    
    public HPPConfirmedROTController() {
        if (exOpp != null && exOpp.received_ROT__c == null) {
            exOpp.received_ROT__c = Date.today();
        }
 
        if (exOpp != null && exOpp.ROT_Decision_Date__c == null) {
            exOpp.ROT_Decision_Date__c = Date.today();
        }
    }
    
    public List<Case> FiCases {get;set;}
    public List<Case> RefferalCases {get;set;}
    public List<HPPEventConditionHelper.ConditionItem> Conditions{get;set;}
    public boolean CanComplete{get;set;}
    
    public boolean ShowFiCases
    {
        get{
            if(FiCases == null) return false;
            return FiCases.size() > 0; 
        }
    }
    
    public boolean ShowRefferalCases 
    {
        get{
            if(RefferalCases == null) return false;
            return RefferalCases .size() > 0; 
        }
    }
    
    public boolean ShowConditions
    {
        get{
            if(Conditions== null) return false;
            return Conditions.size() > 0; 
        }
    }
    
    
    private boolean CanBeCompleted()
    {
        
        RecordType RefferalRC = [select id, name from recordtype where name = 'HPP CAA_CASE' ];
        RefferalCases = [select id,CaseNumber,Further_Information__c,BDM_Comments__c,Underwriter_Comments__c,Subject,Satisfied__c       from case where recordtypeid=:RefferalRC.id and Further_Info_Satisfied__c != 'Yes' and Opportunity__c=:opp.id   ];
        
        RecordType FInfoRC = [select id, name from recordtype where name = 'Further Information' ];
        FiCases = [select id,Further_Info_Satisfied__c,CaseNumber,Further_Information__c,BDM_Comments__c,Underwriter_Comments__c      from case where recordtypeid=:FInfoRC.id and Further_Info_Satisfied__c != 'Yes' and Opportunity__c=:opp.id   ];
        
        HPPEventConditionHelper helper = new HPPEventConditionHelper(acc,opp,exopp);
        helper.LoadOpen();
        Conditions = helper.CIList;
        
        //Conditions = [select notes__c, Accepted__c, ref__c, Accepted_By__c,Added_By__c,Condition_Data__c,Condition_HTML__c,Condition_Letter__c,Credit_Allowed__c,Opportunity__c,Reet_Allowed__c,Special_Condition__c,Special_Condition_Data__c,Special_Condition_Text__c,Pre_or_Post__c from Special_condition_item__c where Opportunity__c =:Opp.id and (accepted__c != true or Accepted_Date__c= null )];
        
        if(RefferalCases.Size() > 0 || FiCases.size() > 0 ||Conditions.size() > 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    public PageReference complete() {
     if(!HPPHelper.CheckFTVIsValid(Opp)) return null;
        if (rotAccepted) {
            
            CanComplete = CanBeCompleted();
            
            if(!CanComplete  )
            {
                pageErrorMessage = 'The below links have not been accepted by credit; these must be accepted before the event can be completed';
                return null;
            }
            //return null;//remove LB
        
        
        
            try {
                update exOpp;
                pageErrorMessage = null;
                //  REAT Email will be sent via Workflow Rule
                
                CompleteEvent();
                
            
                PageReference pageRef = null;
                               
                return GoToNextEvent(); 
            }
            catch (Exception ex) {
                System.debug('Exception on Update exOpp : ' + ex);
            }
        }
        else {
            pageErrorMessage = 'This event cannot be completed if ROT is not acceptable.';
        }
        
        return null;
    }
    
    public PageReference save() {
        try {
            update exOpp;
        }
        catch (DmlException ex) {
            System.debug('Exception on Update exOpp : ' + ex);
        }
        
        pageErrorMessage = null;
        
        return null;
    }
}