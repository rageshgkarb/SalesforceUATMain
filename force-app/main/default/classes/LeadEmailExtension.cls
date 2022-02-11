public class LeadEmailExtension
{
    private Lead Acc{get;set;}
    private ApexPages.StandardController stdCtrl;

    public LeadEmailExtension(ApexPages.StandardController stdController) {
        this.Acc= (Lead)stdController.getRecord();        
        
        Acc = [select id, Marketing_Preference__c from lead where id=:Acc.id ];
        stdCtrl = stdController;       
        SetUpBoxes();
    }
    
    public PageReference save()
    {
        ProcessCheckBox();
        SetUpBoxes();
        update Acc;
        stdCtrl.save();
        return null;
    }
    
    
    public Boolean HasEmail{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}
    
    public Boolean ContainsOption(String option)
    {
        return Acc.marketing_preference__C.containsIgnoreCase(option);
    }
    
    public void SetUpBoxes()
    {  
        if( Acc.marketing_preference__C == null)
            return;
        HasEmail = !ContainsOption('email');
        HasMail= !ContainsOption('mail');
        HasPhone= !ContainsOption('phone');
        HasSMS= !ContainsOption('sms');

    }
    
    
     public void ProcessCheckBox()
    {
   
    Acc.marketing_preference__C = '';
   
    if(!HasMail)
        Acc.marketing_preference__C += 'mail ';
        
    if(!HasEmail)
        Acc.marketing_preference__C += 'email ';

    if(!HasPhone)
        Acc.marketing_preference__C += 'phone ';  

    if(!HasSMS)
        Acc.marketing_preference__C += 'sms ';  
        }
   
    


public Boolean IsChecked(String value)
    {
        if(value == null)
            return false;
            
        if(value.toLowerCase() == 'on')
            return true;
            
        return false;
    }
    }