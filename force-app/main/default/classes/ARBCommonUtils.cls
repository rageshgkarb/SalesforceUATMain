/*******************************************************************
* @Class Name      : ARBCommonUtils
* @Author          : RAGESH G
* @Created Date    : 10 January 2021
* @description 	   : This class is used to write all common utility methods across the application
* @JIRA            : SFD-271

  LOG   DATE        Author  UserStory       	COMMENT      
* 001   10/01/2021  RG                       First Commit
********************************************************************/

public with sharing class ARBCommonUtils {

     /*
    * @Purpose - This method is used to fetch the KYC Settings map with frequency and settings map
    * @Params  - 
    * @return Map < String , List < KYC_Automated_Cases_SLA_Setting__mdt  > >  return the metadatatype records with the frequency strings
    */
    public static Map < String , List < KYC_Automated_Cases_SLA_Setting__mdt  > > fetchKYCCaseSettingsMap () {

        Map < String , List < KYC_Automated_Cases_SLA_Setting__mdt  > > caseSettingsListMap = new Map < String, List < KYC_Automated_Cases_SLA_Setting__mdt  >>  ();
    
        for ( KYC_Automated_Cases_SLA_Setting__mdt kycSettingsRecord : KYC_Automated_Cases_SLA_Setting__mdt.getall().values() ) {
            String settingsKey = kycSettingsRecord.Case_Trigger_Time__c+kycSettingsRecord.Case_Triggger_Day__c +kycSettingsRecord.Case_Trigger_Frequency__c;
            if ( caseSettingsListMap .containsKey ( settingsKey ) ) {
            caseSettingsListMap .get ( settingsKey  ).add ( kycSettingsRecord ) ;
            } else {
            caseSettingsListMap .put (settingsKey, new List < KYC_Automated_Cases_SLA_Setting__mdt > { kycSettingsRecord });
            }
            
        }

        for ( String keySetVal : caseSettingsListMap .keySet ()) {
            System.debug (' keySetVal  ' +keySetVal );
            for ( KYC_Automated_Cases_SLA_Setting__mdt caseSetttingsRec: caseSettingsListMap.get (keySetVal  )) {
              System.debug ('caseSetttingsRec ' + caseSetttingsRec);
            }
        }
        return caseSettingsListMap;
    }
    

     /*
    * @Purpose - This method is used to fetch map between case record type developername and id
    * @Params  - 
    * @return Map < String , List < KYC_Automated_Cases_SLA_Setting__mdt  > >  return the metadatatype records with the frequency strings
    */

    public static Map<String, String> fetchCaseRecordTypeMap() {
        List<RecordType> recType = new List<RecordType>();
        Map<String, String> mapOfCaseRecType = new Map<String, String>();

        recType = [select id, DeveloperName from recordType where  sobjectType='case'];

        for(RecordType rt: recType){
            mapOfCaseRecType.put(rt.DeveloperName, rt.id);
        }

        return mapOfCaseRecType;
    }

     /*
    * @Purpose - This method is used to fetch queue id using the name of the queue
    * @Params  - nameOfQueue - name of the queue for which the id needs to be returned
    * @return  - Id - Id of the queue.
    */

    public static Map < String, Id >  fetchQueueMap( ){
        Map < String, Id > sobjectQueueMap = new Map < String, Id > ();
        for ( QueueSobject queueRecord :  [ SELECT QueueId, queue.Name FROM QueueSobject ] ) {
            sobjectQueueMap.put ( queueRecord.queue.Name, queueRecord.queueId );
        }
        return sobjectQueueMap;      
    }
    
     /*
    * @Purpose - This method is used to check whether a date is working day or not.
    * @Params  - Date - needs to be checked if its working day
    * @return  - Boolean
    */

    public static Boolean isWorkingDay ( Date todaysDate ) {

        DateTime currentDateTime = (DateTime) todaysDate ;
        String currentDay = currentDateTime.format('EEEE');
        String currentMonth = currentDateTime.format('MMMM');
        System.debug (' dayOfWeek ' + currentDay );
        System.debug ( ' currentMonth ' + currentMonth );


        BusinessHours businessHourRecord = [SELECT Id FROM BusinessHours WHERE IsDefault = true];


        Boolean isWithinBusinessHour = BusinessHours.isWithin(businessHourRecord.Id, todaysDate);

        System.debug (' isWithinBusinessHour ' + isWithinBusinessHour);
        return isWithinBusinessHour;
    }

     /*
    * @Purpose - This method is used to fetch the first working day of the week of a specific date
    * @Params  - BusinessHours - Default business hour record
    * @return  - DateTime
    */

    public static DateTime fetchFirstWorkingWeekday ( BusinessHours businessHourRecord, Date currentDate ) {

        // Create Datetime .
        Datetime targetTime = Datetime.newInstance(currentDate.Year(), currentDate.Month (), 1, 0, 0, 1);
        // Starting from the targetTime, find the next date when business hours reopens. Return the target time.

        // if it is within the business hours. The returned time will be in the local time zone
        Datetime firstWorkingDate = BusinessHours.nextStartDate(businessHourRecord.id, targetTime);

        System.debug ('first working day ' + firstWorkingDate );
        return firstWorkingDate;
    }

     /*
    * @Purpose - This method is used to fetch the last working day of the week of a specific date
    * @Params  - BusinessHours - Default business hour record
    * @return  - Boolean
    */

    public static DateTime fetchLastWorkingWeekday ( BusinessHours businessHourRecord, Date currentDate ) {
        Datetime targetTime = Datetime.newInstance(currentDate.Year(), currentDate.Month (), 1, 0, 0, 1);

        // if it is within the business hours. The returned time will be in the local time zone
        Datetime firstWorkingDate = BusinessHours.nextStartDate(businessHourRecord.id, targetTime);
        DateTime lastWorkingDate = firstWorkingDate.date().addMonths(1).toStartofMonth().addDays(-1);

        while(true){

            if(BusinessHours.isWithin(businessHourRecord.Id, lastWorkingDate)){
                break;
            }
            lastWorkingDate = lastWorkingDate.addDays(-1);

        }
        System.debug ('last working day ' + lastWorkingDate );
        return lastWorkingDate;
    }
   
}