global class stCardStoreSettings 
{
	final static public SecureTradingSettings__c secureTradingSettings = SecureTradingSettings__c.getValues('Card Store Settings');
	final static public String endpoint = secureTradingSettings.Endpoint__c;
    final static public String version = secureTradingSettings.Version__c;
    final static public String termURL = secureTradingSettings.TermURL__c;
    final static public Boolean useCardTypeMapping = secureTradingSettings.UseCardTypeMapping__c;
    final static public String username = secureTradingSettings.Username__c; 
    final static public String password = secureTradingSettings.Password__c;
    final static public String alias = secureTradingSettings.Alias__c;
    final static public String opSiteRef = secureTradingSettings.SiteReference__c;
	
	/*
    final static public String endpoint = 'https://webservices.securetrading.net:443/webservices/';
    final static public String version = '3.67';
    final static public String termURL = 'http://www.TERMURL.com';
    final static public Boolean useCardTypeMapping = true;
    final static public String username = 'webservices@islamic-bank.com'; 
        //final static public String password = '3xzhHJNd';
    final static public String password = 'qkszwMb3';
    final static public String alias = 'webservices@islamic-bank.com';
    final static public String opSiteRef = 'test_islamicbank43872';
    */
    
    /*
    final static public String username = 'api@force4change.co.uk';
    final static public String password = '7cFjXc7c'; 
    final static public String alias = 'api@force4change.co.uk';
    final static public String opSiteRef = 'test_forcefourthree43862';
    
    final static public String username = 'webservices@islamic-bank.com';
    final static public String password = 'ppF3M7mm'; 
    final static public String alias = 'webservices@islamic-bank.com';
    final static public String opSiteRef = 'test_islamicbank43872';  
    */   
}