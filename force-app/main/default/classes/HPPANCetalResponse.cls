public without sharing class HPPANCetalResponse 
{
    public List<Response> Responses {get;set;}
    
 
    public HPPANCetalResponse ()
    {
        
    }
    
    public class Response
    {
        public string TheReference{get;set;}
        public string TheType{get;set;}
        public string TheResponse{get;set;}
        public string TheResponseMessage{get;set;}
        public Response ()
        {}
    }
 
}