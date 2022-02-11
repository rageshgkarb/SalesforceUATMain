public class aLogSetting
{
    public static void Create()
    {
        Target t = new Target();
        t.Name = 'target1';
        t.Type = 'File';  
        
        Rule r = new Rule();
        r.Name = '';
    }    

    public class Target
    {
        public string Name{get;set;}     
        public string Type{get;set;}
        public String EmailTo{get;set;}
        public String EmailSubject{get;set;}
        public String CaseRecordType{get;set;}
        public String CaseAssignedTo{get;set;}
        
        
        //public enum TargetType{File, Email, Case}
    }
    
    public class Rule
    {
        public string Name{get;set;}
        public string MinLevel{get;set;}
        public string ExceptionLevel{get;set;}
        public string MinExceptionLevel{get;set;}
        public string WriteTo{get;set;}
        public boolean IsFinal{get;set;}
    }
}