public class General_Enquiry_Controller{
    public static String d(String v){
        //return EncodingUtil.urlDecode(v,'application/x-www-form-urlencoded');
        return EncodingUtil.urlDecode(v,'UTF-8');
    }

    @RemoteAction
    public static String SaveEnquiry(string data){
        GeneralEnquiry e= (GeneralEnquiry)Json.deserialize(data,GeneralEnquiry.class );
        
        string d='';
        if (e.Title == null)
            e.Title = '';

        d= d+'From: '+e.Title+' '+e.FirstName+' '+e.Surname+'\n\n';
        d= d+ 'Telephone: '+e.TelephoneNumber+'\n\n';
        d= d+ 'Email: '+e.Email+'\n\n';
        //d= d+ 'Address:\n'+e.AddressLine1+'\n'+e.AddressLine2+'\n'+e.PostCode+'\n\n'; //C0668
        d= d+ 'Message: '+e.Message+'\n\n';
        d=d+ 'Product: '+e.ProductList+'\n\n';
        d=d+'Do not contact on: '+e.NoContactList+'\n\n';
        d=d+'RefNo: '+e.RefNo;
        
        d=d(d);
        
        
        List<RecordType> recordType=[select id from RecordType where DeveloperName='General_Enquiry'];
        
        Id recordTypeId=recordType[0].Id;
        
        Case caseObj = new Case(
            Status = 'Awaiting Allocation',
            Origin = 'Web',
            Category_revised__c ='General Enquiry',
            /*Owner = '00GD0000001MrcFMAS',*/
            Priority='Meduim',
            Subject='General Enquiry',
            RecordTypeId =recordTypeId,
            Description=d);
        
        insert caseObj;
        
        List<Case> newCaseObj=[select CaseNumber from Case where Id=:caseObj.Id];
        
        //system.debug('case is '+caseObj);
        return newCaseObj[0].CaseNumber;
    }
    
    public PageReference onLoad(){
            
        return null;
    }
    
    public class GeneralEnquiry{
        public String Title {get;set;}
        public String FirstName {get;set;}
        public String Surname {get;set;}
        public String TelephoneNumber{get;set;}
        public String Email {get;set;}
        public String AddressLine1{get;set;}
        public String AddressLine2{get;set;}
        public String PostCode {get;set;}
        public String Message {get;set;}
        public String Products {get;set;}
        public String ProductList {get;set;}
        public String NoContact {get;set;}
        public String NoContactList {get;set;}
        public String RefNo {get;set;}
    }
    
}