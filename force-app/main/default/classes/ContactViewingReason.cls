public with sharing class ContactViewingReason
{
    public Contact con {get; set;}
    
    public ContactViewingReason(ApexPages.StandardController controller) {
        this.con = (Contact)controller.getRecord();
        con = [Select id,accountid,IsPersonAccount from Contact where id =:con.Id];                        
    }
    
    public PageReference autoRedirectPage(){
    
       //Check if complete URL is hosted in IFrame sourced by the Service Console
       if(con.IsPersonAccount){
            return new Pagereference('/' + this.con.AccountId ); 
       }else{
           return new Pagereference('/' + this.con.Id + '?nooverride=1');
       }
    
    }  
  
}