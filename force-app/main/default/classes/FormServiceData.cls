global class FormServiceData
{
    global class FormResponse
 {
     public Boolean Success{get;set;}
     public String Error {get;set;}
     public Boolean HasFieldErrors {get;set;}
     public List<String> FieldErrors {get;set;}
     public String RecordId{get;set;}
 }
 
 global class FormData
 {
     public String UserName{get;set;}
     public String Password{get;set;}
     public String FormName {get;set;}
     public List<FormDataItem> Items {get;set;}
 }
 
 public class FormDataItem
 {
     public String FieldName {get;set;}
     public String FieldValue {get;set;}
 }
}