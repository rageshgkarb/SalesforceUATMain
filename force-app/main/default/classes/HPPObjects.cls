public class HPPObjects
{
    
    public class RequiredFields
    {
        public String ObjectName{get;set;}
        public String Field{get;set;}
        public String Message{get;set;}
		public String RecordType{get;set;} // C0644
    }
    
    public class UpdateFields
    {
        public string UseWhen{get;set;}
        public string ObjectName{get;set;}
        public string Field{get;set;}
        public string Value{get;set;}
        public Boolean OnlySetWhenNull{get;set;}
    }
    
    public class Actions
    {
        public string ClassName{get;set;}
        public string RunWhen{get;set;}
        public integer Sequence{get;set;}
        public string Name{get;set;}
    }
    
    public class FlowEvent implements Comparable
    {
        public string EventId{get;set;}
        public String Description{get;set;}
        public Integer Sequence{get;set;}
        public String EventName{get;set;}
        public String Stage{get;set;}
        public String Status{get;set;}    
        public String EventLogName {get;set;}
        public String Context{get;set;}
            
        
        public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        FlowEvent compareToOppy = (FlowEvent )compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (Sequence > compareToOppy.Sequence) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (Sequence < compareToOppy.Sequence) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
    }
    
    public class RewindEvent
    {
        public string EventId{get;set;}
        public String Description{get;set;}
        public String EventName{get;set;}
        public String RewindToName{get;set;}
        public List<RewindEventItem> Items{get;set;}
        
        public RewindEvent()
        {
            Items = new List<RewindEventItem>();
        }
    }
    
    public class RewindEventItem
    {
        public string EventId{get;set;}
        public String EventName{get;set;}
        public String RewindCode{get;set;}
        public Boolean IsRewind{get;set;}
    }
    
    public class AdhocEvent
    {
        public ID EventId{get;set;}
        public String Description{get;set;}
        public String EventName{get;set;}
    }
    

}