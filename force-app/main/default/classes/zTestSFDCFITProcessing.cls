/* ---------------------------------------------------------------------------------------- */
/* C0550 endpoint for UpdateFTDOpportunity                                                  */
/* ---------------------------------------------------------------------------------------- */

@isTest
private class zTestSFDCFITProcessing 
{
	static testmethod void processFITComms() 
	{
		string foo = 'blah';

		String testResponse = SFDCFITProcessing.testComms(foo);
	}

	static testmethod void processSFDCFIT1 ()
	{
		Opportunity opp = new Opportunity();
		opp.Name = 'TEST NAME';
        opp.CloseDate = Date.today();
        opp.StageName = 'TEST STAGE';
		
		insert opp;

		Account acc = new Account () ;
		acc.name = 'foo';
		insert acc;

		account_with_ibb__c awi = new account_with_ibb__c();
		awi.opportunity__c = opp.Id;
		awi.name = '1100401304001';
		awi.Primary_SFDC_Account__c = acc.Id;
		insert awi;

		Event__c evt = new Event__c () ;
		evt.customPageLocation__c = 'foo';
		insert evt;

		EventLog__c evtLog = new EventLog__c();
		evtLog.EventStatus__c = 'open';
		evtLog.Opportunity__c = opp.Id;
		evtLog.event__c = evt.Id;
		insert evtLog;

		opportunity opp1 = [select Application_Reference_number__c from opportunity where id = :opp.Id];
		string inxml = '<UpdateFTDOpportunity><MessageID>iUID-2016-11-02-17.11.30.008-1-107818</MessageID><MessageType>UpdateFTDOpportunity</MessageType><OpportunityID>' + opp1.Application_Reference_number__c + '</OpportunityID><OpportunityName /><OpportunityStatus />  <InitialDepositAmount /><FTDStartDate /><Spare1 /><Spare2 /><Spare3 /><Spare4 /><Spare5 /></UpdateFTDOpportunity>';

		String testResponse = SFDCFITProcessing.UpdateFTDOpportunity(inxml);
	}

	static testmethod void processSFDCFIT2 ()
	{
		string inxml = '<UpdateFTDOpportunity>bAccountPopupClass';
		String testResponse = SFDCFITProcessing.UpdateFTDOpportunity(inxml);
	}

	static testmethod void processSFDCFIT3 ()
	{
		IBB_Product_Set__c prodset = new IBB_Product_Set__c();
		prodset.name = 'foo';
		insert prodset;

		IBB_Product__c prod = new IBB_Product__c ();
		prod.name = 'foo';
		prod.Type_of_Product__c = 'FIXED TERM SAVINGS ACCOUNT';
		prod.IBB_Product_Set__c = prodset.Id;
		insert prod;

		Opportunity opp = new Opportunity();
		opp.Name = 'TEST NAME';
        opp.CloseDate = Date.today();
        opp.StageName = 'CLOSED WON';
		opp.IBB_Product__c = prod.Id;
		
		insert opp;

		Account acc = new Account () ;
		acc.name = 'foo';
		insert acc;

		account_with_ibb__c awi = new account_with_ibb__c();
		awi.opportunity__c = opp.Id;
		awi.name = '1100401304001';
		awi.Primary_SFDC_Account__c = acc.Id;
		insert awi;

		Event__c evt = new Event__c () ;
		evt.customPageLocation__c = 'foo';
		insert evt;

		EventLog__c evtLog = new EventLog__c();
		evtLog.EventStatus__c = 'open';
		evtLog.Opportunity__c = opp.Id;
		evtLog.event__c = evt.Id;
		insert evtLog;

		

		opportunity opp1 = [select Application_Reference_number__c from opportunity where id = :opp.Id];
		string inxml = '<UpdateFTDOpportunity><MessageID>iUID-2016-11-02-17.11.30.008-1-107818</MessageID><MessageType>UpdateFTDOpportunity</MessageType><OpportunityID>' + opp1.Application_Reference_number__c + '</OpportunityID><OpportunityName /><OpportunityStatus />  <InitialDepositAmount /><FTDStartDate /><Spare1 /><Spare2 /><Spare3 /><Spare4 /><Spare5 /></UpdateFTDOpportunity>';

		String testResponse = SFDCFITProcessing.UpdateFTDOpportunity(inxml);
	}
}