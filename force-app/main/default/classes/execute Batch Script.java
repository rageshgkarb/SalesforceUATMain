Date todaysDate =System.today () ;//date.parse( '31/01/2022' );//System.today () ;//date.parse( '04/01/2022' );

System.debug ('isWorkingDay' + ARBCommonUtils.isWorkingDay( todaysDate ));
ARBBatchProcessCaseToKYCTeam arbKycBatch = new ARBBatchProcessCaseToKYCTeam ( todaysDate );
Database.executeBatch ( arbKycBatch , 200);