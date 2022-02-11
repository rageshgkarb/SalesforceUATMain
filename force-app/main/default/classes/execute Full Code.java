
Date currentDate =date.parse( '04/01/2022' );
List < Id > kycSettingsIdList = new List < Id > ();
Map < String , List < KYC_Automated_Cases_SLA_Setting__mdt  > > caseSettingsListMap = new Map < String , List < KYC_Automated_Cases_SLA_Setting__mdt  > >  ();
		 Date todaysDate = currentDate;
		
		List < KYC_Automated_Cases_SLA_Setting__mdt > kycSettingsRecordList = new List < KYC_Automated_Cases_SLA_Setting__mdt > ();
		
		if ( ARBCommonUtils.isWorkingDay( todaysDate )) {

			DateTime currentDateTime = (DateTime) todaysDate ;
			String currentDay = currentDateTime.format('EEEE');
			String currentMonth = currentDateTime.format('MMMM');
			System.debug (' dayOfWeek ' + currentDay );
			System.debug ( ' currentMonth ' + currentMonth );

			caseSettingsListMap = ARBCommonUtils.fetchKYCCaseSettingsMap ();
            System.debug ('caseSettingsListMap full size ' + caseSettingsListMap.values ().size () );

			Boolean isQuarterly = false;
			Boolean isSixMonth  = false;

			if ( currentMonth == 'January' || currentMonth == 'April' || currentMonth == 'July' || currentMonth == 'October' ) {
				isQuarterly = true;
			}

			if (  currentMonth == 'January' || currentMonth == 'June' || currentMonth == 'May') {
				isSixMonth = true;
			}
			BusinessHours businessHourRecord = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
			Datetime targetTime = Datetime.newInstance(currentDate.Year(), currentDate.Month (), 1, 0, 0, 1);
        
			Datetime firstWorkingDate = BusinessHours.nextStartDate(businessHourRecord.id, targetTime);
			//DateTime firstWorkingDate = ARBCommonUtils.fetchFirstWorkingWeekday(businessHourRecord);
			System.debug ('firstWorkingDate' + firstWorkingDate);
			
			DateTime lastWorkingDate  = ARBCommonUtils.fetchLastWorkingWeekday(businessHourRecord);
			System.debug ('lastWorkingDate' + lastWorkingDate);
			
			for ( String keyString : caseSettingsListMap.keySet () ) {
				for ( KYC_Automated_Cases_SLA_Setting__mdt currentKYCSettings : caseSettingsListMap.get ( keyString) ) {
					if ( currentKYCSettings.Case_Triggger_Day__c =='Daily') {
						kycSettingsRecordList.add ( currentKYCSettings);	
					}
					if ( currentKYCSettings.Case_Triggger_Day__c == currentDay && currentKYCSettings.Case_Trigger_Frequency__c == 'Weekly') {
						kycSettingsRecordList.add ( currentKYCSettings);
					}
					if ( todaysDate == firstWorkingDate.date() && currentKYCSettings.Case_Triggger_Day__c == '1 Weekday' && currentKYCSettings.Case_Trigger_Frequency__c == 'Monthly') {
						kycSettingsRecordList.add ( currentKYCSettings);
					}
					
					if ( todaysDate == lastWorkingDate.date() && currentKYCSettings.Case_Triggger_Day__c == 'Last Weekday' && currentKYCSettings.Case_Trigger_Frequency__c == 'Monthly') {
						kycSettingsRecordList.add ( currentKYCSettings);
					}
					
					if ( todaysDate == firstWorkingDate.date() && currentKYCSettings.Case_Triggger_Day__c == '1 Weekday' && currentKYCSettings.Case_Trigger_Frequency__c == currentMonth ) {
						kycSettingsRecordList.add ( currentKYCSettings);
					}
					
					if ( todaysDate == firstWorkingDate.date() && currentKYCSettings.Case_Triggger_Day__c == '1 Weekday' && currentKYCSettings.Case_Trigger_Frequency__c == 'Quarterly' && isQuarterly) {
						kycSettingsRecordList.add ( currentKYCSettings);
					}
					
					if ( todaysDate == firstWorkingDate.date() && currentKYCSettings.Case_Triggger_Day__c == '1 Weekday' && currentKYCSettings.Case_Trigger_Frequency__c == '6 Months' && isSixMonth) {
						kycSettingsRecordList.add ( currentKYCSettings);
					}
				}
				
			}
			
			for (  KYC_Automated_Cases_SLA_Setting__mdt currentKYCSettings: kycSettingsRecordList) {
				System.debug ('currentKYCSettings' + currentKYCSettings.Case_Subject__c +'===='+currentKYCSettings.Case_Triggger_Day__c + ' - ' + currentKYCSettings.Case_Trigger_Frequency__c);
				kycSettingsIdList.add( currentKYCSettings.Id );
			}
			System.debug('kycSettingsIdList' + kycSettingsIdList );
		}




List < KYC_Automated_Cases_SLA_Setting__mdt > kycSettingsUpdateList = [SELECT Id,Case_Subject__c , Case_Description__c, Case_SLA__c, Case_Assign_To__c, Case_Trigger_Time__c, Case_Trigger_Frequency__c, Case_Triggger_Day__c
		 FROM KYC_Automated_Cases_SLA_Setting__mdt WHERE Id IN :kycSettingsIdList];
List < Case > caseRecordList = new List < Case > ();
			Map < String, String > caseRecordtypeMap = ARBCommonUtils.fetchCaseRecordTypeMap();
			Map < String, Id > queueSobjectMap = ARBCommonUtils.fetchQueueMap();
            System.debug ('kycSettingsUpdateList ====' + kycSettingsUpdateList.size());
			for ( KYC_Automated_Cases_SLA_Setting__mdt kycSettingsRecord : kycSettingsUpdateList ) {
				Case caseRecord = new Case ();
				caseRecord.recordTypeid = caseRecordtypeMap.get(ARBConstantValues.CASE_RECORD_TYPE ) ;
				caseRecord.Subject = kycSettingsRecord.Case_Subject__c;
				caseRecord.Description = kycSettingsRecord.Case_Description__c;
				caseRecord.Priority = ARBConstantValues.CASE_PRIORITY;
				caseRecord.Status =  ARBConstantValues.CASE_STATUS;
				caseRecord.Origin =  ARBConstantValues.CASE_ORIGIN;
				if ( kycSettingsRecord.Case_SLA__c == '12h' ) {
					String hoursString = ''+kycSettingsRecord.Case_SLA__c.replaceAll ('h','');
					
					caseRecord.Date_to_Be_Actioned__c = currentDate.addDays( Integer.valueOf(hoursString));
					Integer slaHour = 12;
					DateTime updatedTime = DateTime.newInstance(currentDate.year (), currentDate.month (), currentDate.day(), slaHour, 00, 00);

					caseRecord.Internal_SLA__c = updatedTime;
				} else {
					caseRecord.Date_to_Be_Actioned__c = currentDate.addDays( Integer.valueOf(kycSettingsRecord.Case_SLA__c));

				}
				
				Id relatedQueueId ;
				if ( queueSobjectMap.containsKey ( kycSettingsRecord.Case_Assign_To__c) ) {
					relatedQueueId = queueSobjectMap.get ( kycSettingsRecord.Case_Assign_To__c );
				}
				if( relatedQueueId != null){
					caseRecord.OwnerId = relatedQueueId;
				}
				caseRecordList.add ( caseRecord );
			}

			try {
				System.debug( 'caseRecordList'  + caseRecordList);
				for ( Case caseRecord : caseRecordList ) {
					System.debug( '#Case Details ' + caseRecord.Subject);
				}
				//Database.insert( caseRecordList );
			} catch ( Exception Exe ) {
				System.debug( ' Error occured ' + Exe.getMessage() );
			}