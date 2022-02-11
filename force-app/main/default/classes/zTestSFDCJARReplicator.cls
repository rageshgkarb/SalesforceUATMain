/* ---------------------------------------------------------------------------------------------------- */
/* C0559																								*/
/* ---------------------------------------------------------------------------------------------------- */

@isTest
private class zTestSFDCJARReplicator 
{

	
	static testmethod void processJARS1() 
	{
		IBB_Product_Set__c prodset = new IBB_Product_Set__c();
		prodset.Name = 'Test';
		insert prodset;
		IBB_Product__c prod = new IBB_Product__c();
		prod.Name = 'Current AAccount';
		prod.Ibb_Product_Set__c = prodset.id ;
        insert prod;
        Account acc = new Account();
        acc.FirstName = 'Test Account';
        acc.LastName = 'Test Account';
        acc.BillingPostalCode = 'Test Account';
        acc.Title_Other__c = 'xyz';
        acc.EBS_ID__c = '420485';
        insert acc;
        
        Account_with_IBB__c accWithIBB = new Account_with_IBB__c();
        accWithIBB.IBB_Product__c = prod.Id;
        accWithIBB.Name = '1100420485001';
        insert accWithIBB;
    
        String inXml = '<SFDCBatchJAR><BatchID>5d59a176-94bc-4d2e-be8e-660287760aa0</BatchID><JARS>  <MessageID>iUID-2016-11-24-11.10.48.427-3-111300</MessageID>   <AcctNo>1100420485001</AcctNo><JointRelationship>    <CustNo>420485</CustNo><CustName>MR CARL P D REYNOLDS </CustName>      <CustRelationshipToPrimary>Primary</CustRelationshipToPrimary>    </JointRelationship></JARS></SFDCBatchJAR>';
		
		String testResponse = SFDCJARReplication.updateJAR(inXml);



	}


	static testmethod void processJARS2() 
	{
		IBB_Product_Set__c prodset = new IBB_Product_Set__c();
		prodset.Name = 'Test';
		insert prodset;
		IBB_Product__c prod = new IBB_Product__c();
		prod.Name = 'Current AAccount';
		prod.Ibb_Product_Set__c = prodset.id ;
        insert prod;
        Account acc = new Account();
        acc.FirstName = 'Test Account';
        acc.LastName = 'Test Account';
        acc.BillingPostalCode = 'Test Account';
        acc.Title_Other__c = 'xyz';
        acc.EBS_ID__c = '420485';
        insert acc;
        
        Account_with_IBB__c accWithIBB = new Account_with_IBB__c();
        accWithIBB.IBB_Product__c = prod.Id;
        accWithIBB.Name = '1100420485001';
        insert accWithIBB;
    
        String inXml = '<SFDCBatchJAR>  <BatchID>6d103744-a9a9-486a-8cb0-50fcf308c668</BatchID>  <JARS>    <MessageID>iUID-2016-11-24-11.12.51.686-4-111378</MessageID>    <AcctNo>1100401304001</AcctNo>    <JointRelationship>      <CustNo>428194</CustNo>      <CustName>NOHA OSMAN </CustName>      <CustRelationshipToPrimary>Wife</CustRelationshipToPrimary>  </JointRelationship>    <JointRelationship>      <CustNo>420485</CustNo>      <CustName>MR CARL P D REYNOLDS </CustName><CustRelationshipToPrimary>Brother</CustRelationshipToPrimary>    </JointRelationship>  </JARS>  <JARS>    <MessageID>iUID-2016-11-24-11.10.48.427-3-111378</MessageID>    <AcctNo>1100420485001</AcctNo>    <JointRelationship>      <CustNo>420485</CustNo>      <CustName>MR CARL P D REYNOLDS </CustName>      <CustRelationshipToPrimary>Primary</CustRelationshipToPrimary></JointRelationship>  </JARS>  <JARS>    <MessageID>iUID-2016-11-24-11.10.42.058-2-111378</MessageID>    <AcctNo>1100420485091</AcctNo>    <JointRelationship>   <CustNo>420485</CustNo>      <CustName>MR CARL P D REYNOLDS </CustName>      <CustRelationshipToPrimary>Primary</CustRelationshipToPrimary></JointRelationship>  </JARS></SFDCBatchJAR>';
		
		String testResponse = SFDCJARReplication.updateJAR(inXml);



	}

	static testmethod void processJARS3() 
	{
		string foo = 'blah';

		String testResponse = SFDCJARReplication.testComms(foo);
	}

	static testmethod void processJARS4() 
	{
		IBB_Product_Set__c prodset = new IBB_Product_Set__c();
		prodset.Name = 'Test';
		insert prodset;
		IBB_Product__c prod = new IBB_Product__c();
		prod.Name = 'Current AAccount';
		prod.Ibb_Product_Set__c = prodset.id ;
        insert prod;
        Account acc = new Account();
        acc.FirstName = 'Test Account';
        acc.LastName = 'Test Account';
        acc.BillingPostalCode = 'Test Account';
        acc.Title_Other__c = 'xyz';
        acc.EBS_ID__c = '420485';
        insert acc;
        
        Account_with_IBB__c accWithIBB = new Account_with_IBB__c();
        accWithIBB.IBB_Product__c = prod.Id;
        accWithIBB.Name = '1100420485001';
        insert accWithIBB;
    
        String inXml = '<SFDCBatchJAR> foobar';
		
		String testResponse = SFDCJARReplication.updateJAR(inXml);


	}
}