/*******************************************************************
* @Class Name      : ARBBatchProcessCaseToKYCTeam
* @Author          : RAGESH G
* @Created Date    : 08 February 2022
* @description 	   : This test class for the Apex class is used to create KYC cases automatically in the system.
* @JIRA            : SFD-271

  LOG   DATE        Author  UserStory       	COMMENT      
* 001   08/02/2022  RG                       First Commit
********************************************************************/

@isTest
public class ARBBatchProcessCaseToKYCTeamTest {
	
    static testmethod void arbKYCCasesBatchTestFWJan() {
                
        Test.startTest();
		Date todaysDate =date.parse( '04/01/2022' );
		System.debug ('isWorkingDay' + ARBCommonUtils.isWorkingDay( todaysDate ));
		ARBBatchProcessCaseToKYCTeam arbKycBatch = new ARBBatchProcessCaseToKYCTeam ( todaysDate );
		Database.executeBatch ( arbKycBatch , 200);

        Test.stopTest();
    }
	
	static testmethod void arbKYCCasesBatchTestWedJan() {
                
        Test.startTest();
		Date todaysDate =date.parse( '05/01/2022' );
		System.debug ('isWorkingDay' + ARBCommonUtils.isWorkingDay( todaysDate ));
		ARBBatchProcessCaseToKYCTeam arbKycBatch = new ARBBatchProcessCaseToKYCTeam ( todaysDate );
		Database.executeBatch ( arbKycBatch , 200);

        Test.stopTest();
    }
	
	static testmethod void arbKYCCasesBatchTestLWJan() {
                
        Test.startTest();
		Date todaysDate =date.parse( '31/01/2022' );
		System.debug ('isWorkingDay' + ARBCommonUtils.isWorkingDay( todaysDate ));
		ARBBatchProcessCaseToKYCTeam arbKycBatch = new ARBBatchProcessCaseToKYCTeam ( todaysDate );
		Database.executeBatch ( arbKycBatch , 200);

        Test.stopTest();
    }
	
	static testmethod void arbKYCCasesBatchTestThJan() {
                
        Test.startTest();
		Date todaysDate =date.parse( '06/01/2022' );
		System.debug ('isWorkingDay' + ARBCommonUtils.isWorkingDay( todaysDate ));
		ARBBatchProcessCaseToKYCTeam arbKycBatch = new ARBBatchProcessCaseToKYCTeam ( todaysDate );
		Database.executeBatch ( arbKycBatch , 200);

        Test.stopTest();
    }
	
	static testmethod void arbKYCCasesBatchTestFrJan() {
                
        Test.startTest();
		Date todaysDate =date.parse( '07/01/2022' );
		System.debug ('isWorkingDay' + ARBCommonUtils.isWorkingDay( todaysDate ));
		ARBBatchProcessCaseToKYCTeam arbKycBatch = new ARBBatchProcessCaseToKYCTeam ( todaysDate );
		Database.executeBatch ( arbKycBatch , 200);

        Test.stopTest();
    }
	
	
}