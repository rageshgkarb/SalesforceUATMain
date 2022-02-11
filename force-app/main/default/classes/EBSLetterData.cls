public class EBSLetterData
{
    /*
    //Takes a list of records and returns a list of maps using the field name as the key
    private static List<Map<String,String>> CreateMap(List<LetterData> data)
    {
        List<Map<String,String>> lst = new List<Map<String,String>>();
        
        for(LetterData ld : data)
        {
            Map<String,String> m = new Map<String,String>();
            for(EBSLetterData.LetterField l : ld.Fields)
            {
                m.put(l.Field,l.value);
            }
            lst.add(m);
        }
        
      
        return lst;
    }
    */

    public static List<TemplateDescription> GetTemplates()
    {
        GetTemplatesRequest d = new GetTemplatesRequest();       
        d.servicename = 'AS400GetTemplates';
                
        RestRequest request = new RestRequest();
        request.LogMessage = false;
        String responseString = request.PostREST(d,'1');
        
        GetTemplateResponse respo = (GetTemplateResponse)Json.deserialize(responseString,GetTemplateResponse.class );
        
        return respo.Data;
    }
    
    public static List<TemplateData> GetData(List<Docugen_EBS_Template__c> templates)
    {
        List<String> lst = new List<String>();
        
        for(Docugen_EBS_Template__c template : templates)
        {
            lst.add(template.EBS_Template__c);
        }
        return GetData(lst);        
    }
    
    public static List<TemplateData> GetData(List<String> templates)
    {
        GetDataRequest  d = new GetDataRequest();       
        d.servicename = 'AS400GetData';
        d.Templates = templates;
                
        RestRequest request = new RestRequest();
        request.LogMessage = false;
        
        String responseString = request.PostREST(d,'1');
        
        system.debug(responseString);
        
        GetDataResponse respo = (GetDataResponse)Json.deserialize(responseString,GetDataResponse.class );
        
        //system.debug(respo.Data.size());
        
        return respo.Data;
    }
    
    
    public class GetDataRequest extends Teller_Integration_Data.EBSBaseRequest
    {
        public List<String> Templates {get;set;}
    }
    
    public class GetTemplatesRequest extends Teller_Integration_Data.EBSBaseRequest
    {
        
    }
    public class GetTemplateResponse extends RestRequest.ApexServiceBaseResponse
    {
        public List<TemplateDescription> Data {get;set;}
    }
    
    public class TemplateDescription
    {
        public String Name {get;set;}
        public Integer Rows {get;set;}
    }
    
    public class GetDataResponse extends RestRequest.ApexServiceBaseResponse
    {
         public List<TemplateData> Data {get;set;}
    }
    
    public class TemplateData
    {
        public String Name{get;set;}
        public List<String> Columns{get;set;}
        public List<Row> Rows {get;set;}
        public Id TemplateId {get;set;}
        public String SysModDate {get;set;}
        public Id JobId {get;set;}
        public String DocType {get;set;}
        
        public TemplateData()
        {
            Columns = new List<String>();
            Rows = new List<Row>();
        }
    }
    
    public class Row 
    {
        public Id AccountId {get;set;}  
        public String EBSId {get;set;} 
    
        public List<String> Cells {get;set;}
        
        public Row()
        {
            Cells = new List<String>();
        }
    }
    /*
    public class LetterData
    {
        public String Template {get;set;}
        public List<LetterField> Fields {get;set;}
        
        public LetterData()
        {
            Fields = new List<LetterField>();
        }
    }
    
    public class LetterField
    {
        public String Field {get;set;}
        public String Value {get;set;}
        
        public LetterField(string field, string value)
        {
            this.Field = field;
            this.Value = value;
        }
    }
    */
}