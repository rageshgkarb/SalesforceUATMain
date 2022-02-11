public class HPP_Header_Controller
{
    public Opportunity o {get;set;}
    
    public String getTerm()
    {
        List<IBBquotation__c> quotes = [select Remaing_Term__c from IBBquotation__c 
                                        where opportunity__c =: o.id and Remaing_Term__c != null and NumberOfMonths__c != null
                                        order by createddate desc limit 1
                                        ];
                                        
         if(quotes.size() > 0) return '( ' +quotes[0].Remaing_Term__c + ' remaining )';
         
         return '';
        
    }
}