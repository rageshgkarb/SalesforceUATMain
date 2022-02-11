global class IBB_Remoting
{
    public interface IGenericRemoting
    {
        GenericResponseBase Call(String methodName, String data );
    }

    global abstract class GenericResponseBase
    {
        public Boolean Success{get;set;}
        public String Error{get;set;}
    }


    global class GenericResponse extends GenericResponseBase
    {
        public String Data{get;set;}
        
        public GenericResponse(){}
        
        public GenericResponse(Boolean isSuccess, String errorMessage, String theData)
        {
            Success = isSuccess;
            Error = errorMessage;
            Data = theData;
        }
    }
    
    global class GenericRequest
    {
        public String ClassName{get;set;}
        public String Method{get;set;}
        public String Data{get;set;}
    }

    global class GenericListResponse extends GenericResponseBase
    {
        public List<object> Data{get;set;}

        public GenericListResponse(List<object> obj)
        {
            Data = obj;
        }
    }

    
}