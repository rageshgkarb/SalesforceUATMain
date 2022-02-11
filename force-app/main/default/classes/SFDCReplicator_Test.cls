@isTest
private class SFDCReplicator_Test {
    
    /*
    static testmethod void testProcessCustomers(){
        String inXml = '<SalesForceAddNewCustomerBatch><BatchMessageID>aa6a17fd-0ae7-44a3-9a23-b5b5080171fc</BatchMessageID><AddNewCustomerAllInformation><MessageID>iUID-2012-01-12-11.54.20.762-054578</MessageID><MessageType>CustomerDetails</MessageType><CustomerType>Individuals</CustomerType><CustNo>400010</CustNo><SFDCID /><ReplicationType>*UPDATE</ReplicationType><CustomerStatus>Normal</CustomerStatus><CustomerDefaultBranch>Edgware Road - London</CustomerDefaultBranch><CustName>MR Omar A Fadlalla</CustName><CustomerSurName>Fadlalla</CustomerSurName><CustDateOfBirth>1968-11-10</CustDateOfBirth><CustomerGender>Male</CustomerGender><CustomerMotherFamilyName>ALJACK</CustomerMotherFamilyName><CustomerSchoolName>ALGADEEMA</CustomerSchoolName><MaritalStatus>Married</MaritalStatus><CustomerDefaultShortName>FADLALLA OA</CustomerDefaultShortName><DefaultTaxRef /><AccountOfficer>None</AccountOfficer><CountryOfResidence>United Kingdom</CountryOfResidence><ParentCountry>Sudan</ParentCountry><CustomerIDEvidence>Current signed passport</CustomerIDEvidence><EvidenceOfAddress>Bank Statement LT 3 Months</EvidenceOfAddress><CustomerDocSerialNo>094325836</CustomerDocSerialNo><DocumentIssueDate>2004-01-21</DocumentIssueDate><NetMonthlyIncome>00002000</NetMonthlyIncome><TotalIncomeBeforeTax>00024000</TotalIncomeBeforeTax><R105Received /><R85Received /><PreferredContactMethod /><DateMovedToCurrentAddress>2005-10-01</DateMovedToCurrentAddress><MarketingConsent /><DateMovedToPrevAddress>2000-02-01</DateMovedToPrevAddress><DateEmploymentCommenced>2009-04-23</DateEmploymentCommenced><CurrentBankDateAcctOpened>2004-03-01</CurrentBankDateAcctOpened><CustomerFirstName>Omar</CustomerFirstName><CustomerMiddleName>Alsayeid</CustomerMiddleName><CustomerPreviousName /><CountryOfBirth>SUDAN</CountryOfBirth><TownOfBirth>ALHASAHISA</TownOfBirth>   <PrevAddrHouseNo>48</PrevAddrHouseNo><PrevStreet>48, The Beckers</PrevStreet><PrevDistrict>Rectory Road</PrevDistrict><PrevCity>London</PrevCity><PrevCounty /><PrevCountry /><PrevPCode>N167QX</PrevPCode><PreviousResidencyYears /><PreviousResidencyMonths /><PrevPrevAddrHouseNo /><PrevPrevStreet /><PrevPrevDistrict /><PrevPrevCity /><PrevPrevCounty /><PrevPrevCountry /><PrevPrevPCode /><PrevPrevResidencyYears /><PrevPrevResidencyMonths /><EmployerName>Denis Carter</EmployerName><EmployerAddrLine1>Starcliff House</EmployerAddrLine1><EmployerHouseNo /><EmployerStreet>Starcliff Road</EmployerStreet><EmployerDistrict>London</EmployerDistrict><EmployerCity /><EmployerCounty /><EmployerCountry /><EmployerPCode /><EmployerNatureOfBusiness /><MobNo>07908-262781</MobNo><WorkTelNo /><PrivateEmail /><WorkEmail /><HomeDetails>Tenant Unfurnished</HomeDetails><PropertyEstimatedValue>00000000</PropertyEstimatedValue><CurrentMortgageOutstanding>00000000</CurrentMortgageOutstanding><NameOfTheLender /><EmploymentType>Self employed professional</EmploymentType><EmploymentStatus>Not given</EmploymentStatus><PremierStatus>None</PremierStatus><Occupation /><NoOfChildren /><CurrentBankDetailsKeepOpen>Y</CurrentBankDetailsKeepOpen><CurrentBankDateAcctNo>10211123</CurrentBankDateAcctNo><CurrentBankSortCode>160058</CurrentBankSortCode><DebitCard>Y</DebitCard><AmericanExpress /><DinersCard /><MasterCard /><VisaCard /><StoreCard>Y</StoreCard><CurrentBankDetailsName>RBS</CurrentBankDetailsName><CorrespondenceAllAccounts /><IVRNominatedAccountNumber /><IVRNominatedSortCode /><IVRNominatedPaymentRef /><CustSalutation>MR</CustSalutation><HouseNo>MR Omar A Fadlalla</HouseNo><Street>39, Catherine House</Street><District>Whitmore Estate</District><City>London</City><County /><Country /><PostCode>N15PB</PostCode><TelNo>0207-6131158</TelNo><InternetEnabled>Y</InternetEnabled><HaveYouEverBeenBankrupt /><CountryOfPassportIssue /><AnyCCJ /><VisaExpiryDate /><HowDidYouHearAboutIBB>Word of mouth</HowDidYouHearAboutIBB><EBSID>400010</EBSID><DateCustomerAdded /><DateOfLastCustomerTrans /><DateLastMaint /></AddNewCustomerAllInformation></SalesForceAddNewCustomerBatch>';
        String testResponse = SFDCReplicator.processCustomers(inXml);
    }
    */
    
    static testmethod void testProcessAccounts(){
        Account acc = new Account();
        acc.FirstName = 'Test Account';
        acc.LastName = 'Test Account';
        acc.BillingPostalCode = 'Test Account';
        acc.Title_Other__c = 'xyz';
        acc.EBS_ID__c = '111111';
        insert acc;
        
        String inXml = '<ns0:SalesForceOpenCustomerAccountBatch xmlns:ns0="http://IBB.SalesForce.OCA.SalesForceBatchOCA"><BatchMessageID>ac7ac0ba-1ef8-4632-92f9-21363112a931</BatchMessageID><OpenCustomerAccount><MessageID>iUID-2012-01-16-12.24.09.203-056878</MessageID><MessageType>OpenAccount</MessageType><ReplicationType>*INSERT</ReplicationType><Customer>111111</Customer><BranchNo>Whitechapel - London</BranchNo><AccountSuffix>001</AccountSuffix><AccountCurrency>Pound Sterling</AccountCurrency><AccountType>Current Account</AccountType><DirectDebitSortCode /><DirectDebitBankAccount /><AccountFacilities>CG</AccountFacilities><EBSID>1210401305001</EBSID><ExternalAccountNumber>40130501</ExternalAccountNumber></OpenCustomerAccount></ns0:SalesForceOpenCustomerAccountBatch>';
        String testResponse = SFDCReplicator.processAccounts(inXml);
    }
    
    static testmethod void testProcessJar(){
        
        IBB_Product__c prod = [select Id from IBB_Product__c where Name = 'Current Account' LIMIT 1];
        
        Account acc = new Account();
        acc.FirstName = 'Test Account';
        acc.LastName = 'Test Account';
        acc.BillingPostalCode = 'Test Account';
        acc.Title_Other__c = 'xyz';
        acc.EBS_ID__c = '112112';
        insert acc;
        
        Account_with_IBB__c accWithIBB = new Account_with_IBB__c();
        accWithIBB.IBB_Product__c = prod.Id;
        accWithIBB.Name = '42186450';
        insert accWithIBB;
    
        String inXml = '<ns0:SalesForceJointAccountRelationshipBatch xmlns:ns0="http://IBB.SalesForce.OCA.SalesForceBatchJAR"><BatchMessageID>bea2a61f-aec5-4b5b-a4ce-72975cc18912</BatchMessageID><AddJointRelationship><MessageID>iUID-2012-01-12-16.41.48.193-054587</MessageID><MessageType>JointRelationship</MessageType><ReplicationType>*UPDATE</ReplicationType><AcctNo>42186450</AcctNo><JoiningCustomer>112112</JoiningCustomer><JointRelationship>Wife</JointRelationship><JoiningCustomerName>MRS H SHEIK </JoiningCustomerName></AddJointRelationship></ns0:SalesForceJointAccountRelationshipBatch>';
        String testResponse = SFDCReplicator.processJAR(inXml);
    }
    
    static testmethod void testProcessBalanceUpdates(){
        IBB_Product__c prod = [select Id from IBB_Product__c where Name = '60 Day Notice Account' LIMIT 1];
        
        Account_with_IBB__c accWithIBB = new Account_with_IBB__c();
        accWithIBB.IBB_Product__c = prod.Id;
        accWithIBB.Name = '40130581';
        insert accWithIBB;
        String inXml = '<ns0:SalesForceAccountBalanceRefreshBatch xmlns:ns0="http://IBB.SalesForce.OCA.SalesForceAccountBalanceRefreshBatch"><BatchMessageID>c2028e4a-7ad8-4bf9-948b-9ab3a9641c6c</BatchMessageID><SalesForceAccountBalanceRefresh><MessageID>iUID-2012-01-16-14.33.23.885-056878</MessageID><MessageType>AccountBalanceRefresh</MessageType><ReplicationType>*INSERT</ReplicationType><AcctNo>1210401305081</AcctNo><ExternalAcctNo>40130581</ExternalAcctNo><BranchName>Whitechapel - London</BranchName><CustName>MR M ASIF</CustName><AcctType>EN</AcctType><AcctDesc>60 Day Notice Account</AcctDesc><Ccy>GBP</Ccy><CcyName>Pound Sterling</CcyName><LedgerBalance>1.090000</LedgerBalance><StatusBalance>1.090000</StatusBalance><AvailableBalance>1.090000</AvailableBalance><ReservedBalance>.000000</ReservedBalance><ClearedBal>1.090000</ClearedBal><ShadowDebit>.000000</ShadowDebit><ShadowCredit>.000000</ShadowCredit><AcctClosed>N</AcctClosed><AcctBlocked>N</AcctBlocked><AcctInactive>N</AcctInactive><AcctJoint>N</AcctJoint><JointAccountHolders /><AcctDateIofLastEntry>2011-10-07</AcctDateIofLastEntry><DateAccountOpened>2011-03-24</DateAccountOpened><ErrorMsg /><WarningMsg /><MsgCode /><SFDCID /><CustNo>401305</CustNo></SalesForceAccountBalanceRefresh></ns0:SalesForceAccountBalanceRefreshBatch>';
        String testResponse = SFDCReplicator.processBalanceUpdates(inXml);
    }
    
}