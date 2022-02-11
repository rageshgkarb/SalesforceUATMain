public class AccountCommunicationExtension {
    public Account Acc{get;set;}
    private ApexPages.StandardController stdCtrl;
    
    public List<Attachment_Data__c> lstAttachmentData{get;set;}
    
    public string adocs{get;set;}
    
    public String docugenSettings{get; set;}

    public AccountCommunicationExtension(ApexPages.StandardController stdController) {
        
        this.Acc= (Account)stdController.getRecord();
        
        this.adocs='';
                
        // Acc = DataHelperTemp.GetAccount(Acc.Id)[0];
        stdCtrl = stdController;      
        
        list<DocugenPlusSettings__c> settings=DocugenPlusSettings__c.getall().values();
        docugenSettings=settings[0].JsonSettings1__c;
        
        
    }
    
    /*@RemoteAction
    public static string GenerateSingleDocument(string AccountId,string JobId){
        Docugen_Job__c job=[SELECT Name, Data_1__c, Data_2__c, Data_3__c, Data_4__c, Data_5__c FROM Docugen_Job__c WHERE Id=:JobId];
        

        String jsonData = IBB_Helper.RebuildString(job, 'Data_', 5).replace('&amp;','&');
        
        
        
        return jsonData;
    }*/
    
    
    
    public PageReference onLoad(){
        lstAttachmentData=[SELECT id,Name,Account__r.Name,Account__r.AccountNumber,Docugen_Job__r.Id,Account__r.Id,Account__r.EBS_ID__c,(SELECT Id,Name FROM Attachments),LastModifiedDate FROM Attachment_Data__c where Account__r.Id=:Acc.Id order by LastModifiedDate desc];
        if(!lstAttachmentData.isEmpty()){
            adocs=JSON.serialize(lstAttachmentData);
        }
        else{
            adocs='';
        }
        return null;
    }
}