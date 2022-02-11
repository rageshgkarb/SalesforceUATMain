/* --------------------------------------------------------------------------------	*/
/* C0727																			*/
/* --------------------------------------------------------------------------------	*/


@isTest
private class zTestDSXDocumentLinkTrigger 
{

	
	static testmethod void testInsert() 
	{
		Map <String,Schema.RecordTypeInfo> recordTypes = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
		Id hppCAARecordId = recordTypes.get('HPP CAA').getRecordTypeId(); 

		Opportunity opp = new Opportunity ();
		opp.Name = 'TEST NAME';
        opp.CloseDate = Date.today();
        opp.StageName = 'TEST STAGE';
		opp.RecordTypeid = hppCAARecordId;
		opp.DSX_Documents_Expected__c = 'HPP-BANK STATEMENTS';
		opp.DSX_Documents_Outstanding__c = 'HPP-BANK STATEMENTS';
		insert opp;

		DSX_Document_Link__c dsxLink = new DSX_Document_Link__c ();
		dsxLink.Document_Link__c = 'http://foo.com';
		dsxLink.Document_Name__c = 'HPP-BANK STATEMENTS';
		dsxLink.Document_Status__c = 'Received';
		dsxLink.Opportunity__c = opp.Id;

		insert dsxLink;

	}
}