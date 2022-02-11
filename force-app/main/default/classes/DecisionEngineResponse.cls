public with sharing class DecisionEngineResponse 
{
    public string Decision{get;set;}
    public string ThePerson{get;set;}
    public string TheOpportunity{get;set;}
    public string TheType{get;set;}
    public List<Reason> DecisionReasons
    {
        get
        {
            if (DecisionReasons == null)
            {
                DecisionReasons = new List<Reason>();
            }
            return DecisionReasons;
        }
        set;
    }
    
     public List<Warning> DecisionWarnings
    {
        get
        {
            if (DecisionWarnings == null)
            {
                DecisionWarnings = new List<Warning>();
            }
            return DecisionWarnings;
        }
        set;
    }
    
    
    
    
    public DecisionEngineResponse()
    {
        
    }
    
    public DecisionEngineResponse(string deType)
    {
        TheType = deType;
    }
    
    public class Reason
    {
        public integer Index{get;set;}
        public Applicant__c ThisApplicant
        {
            get
            {
                if (ThisApplicant == null)
                {
                    ThisApplicant = new Applicant__c();
                }
                return ThisApplicant;
            }
            set;
        }
        public string ThisDecision{get;set;}
        public string ReasonCode{get;set;}
        public string ReasonDescription{get;set;}
        public Reason(integer i, Applicant__c passedApplicant, string passedDecision, string passedReason, string passedReasonDescription)
        {
            Index = i;
            ThisApplicant = passedApplicant;
            ThisDecision = passedDecision;
            ReasonCode = passedReason;
            //ReasonDescription = passedReasonDescription.Length() > 39 ? passedReasonDescription.Substring(38) : passedReasonDescription;
            ReasonDescription = passedReasonDescription;
        }
        
        
    }
    
    public class Warning
    {
        public integer Index{get;set;}
        public Applicant__c ThisApplicant
        {
            get
            {
                if (ThisApplicant == null)
                {
                    ThisApplicant = new Applicant__c();
                }
                return ThisApplicant;
            }
            set;
        }
        public string ThisDecision{get;set;}
        public string WarningCode{get;set;}
        public string WarningDescription{get;set;}
        public Warning(integer i, Applicant__c passedApplicant, string passedDecision, string passedWarning, string passedWarningDescription)
        {
            Index = i;
            ThisApplicant = passedApplicant;
            ThisDecision = passedDecision;
            WarningCode = passedWarning;
            WarningDescription = passedWarningDescription.Length() > 39 ? passedWarningDescription.Substring(38) : passedWarningDescription;
        }
        
        
    }
}