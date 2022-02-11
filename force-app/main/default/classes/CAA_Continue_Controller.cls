public class CAA_Continue_Controller
{
    private String ID = ApexPages.currentPage().getParameters().get('id');
    private String ExtID = ApexPages.currentPage().getParameters().get('extid');
    
    public Boolean IsOldCAA {get;set;}
    public Boolean isAccountLost{get;set;} //Sharia Compliance changes

    public PageReference Setup()
    {
        String oppId;
            
        if(string.IsNotBlank(ExtID ))
        {
            String decrypt = CAA_Helper.DecryptData(ExtID );   
            if(decrypt == null) throw new CAA_Helper.MyException('decryption failed');
            oppId = decrypt;
        }
        
        
        
            
        if(!CAA_Helper.IsGuestUser() && string.IsNotBlank(ID))
            oppId = ID;
            
        if(oppId == null) throw new CAA_Helper.MyException('no opp');
        
        List<Opportunity> opp = [select id, caa_rebuild__c, recordtype.developerName, stageName from opportunity where id=:oppId]; //Sharia Compliance changes, added record type developer name and stagename
        
        if(opp.size() != 1) throw new CAA_Helper.MyException('can\'t find opportunity');
        
        //Sharia Compliance changes START
        if((opp[0].recordtype.developerName == 'Liabilities_Opportunites' ) && (opp[0].stageName == 'Retention Call - Not Interested' || opp[0].stageName == 'Account lost')){
            isAccountLost = true;
            return null;
        } //Sharia Compliance changes END             
        IsOldCAA = !opp[0].caa_rebuild__c ;
        //if(IsOldCAA) return null;           
                   
                   
        //find next event
        List<EventLog__c> openEvents = [select id, Event__r.CustomPageLocation__c
                                         from eventlog__c where EventStatus__c='open' and Opportunity__c=:opp[0].id
                                         order by createddate limit  1];
                                         
        if(openEvents.size() == 1)
        {
            String url = openEvents[0].Event__r.CustomPageLocation__c;
            if(CAA_Helper.IsGuestUser())
            {
                url += '?extid=' + CAA_Helper.EncryptData(string.valueof(openEvents[0].id));
            }
            else
            {
                url+= '?id=' + openEvents[0].id;
            }
        
            return new PageReference(url);
        }  
        else
        {
            //throw new CAA_Helper.MyException('no events');
        }                              
            
        return null;
    }
}