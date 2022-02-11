public class SoqlHelper {

    private static List<BusinessHours> defaultBusinessHours;
    public static List<BusinessHours> getDefaultBusinessHours() {
        if (defaultBusinessHours == null) {
            defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        }
        return defaultBusinessHours;
    }


    private static Map<String, List<RecordType>> recordTypesByObjectName = new Map<String, List<RecordType>>();
    public static List<RecordType> getRecordTypesByObjectName(String objectName) {
        objectName = objectName.toUpperCase();
        system.debug(objectName);
        if (!recordTypesByObjectName.containsKey(objectName)) {
            recordTypesByObjectName.put(objectName, [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SObjectType = :objectName]);
        }

        return recordTypesByObjectName.get(objectName);
    }

    public static RecordType getRecordTypeByObjectAndDeveloperName(String objectName, String developerName) {
        for (RecordType rt : getRecordTypesByObjectName(objectName)) {
            if (rt.DeveloperName.equalsIgnoreCase(developerName)) {
                return rt;
            }
        }
        return null;
    }

    private static List<Case_SLA__c> caseSLAs;
    public static List<Case_SLA__c> getCaseSLA() {
        if (caseSLAs == null) {
            caseSLAs = [SELECT name, SLA_Duration__c, StartTimeHour__c, StartTimeMinute__c, EndTimeHour__c, EndTimeMinute__c,SubCategory__c,Category__c,Record_Type_Name__c,Status__c FROM Case_SLA__c];
        }
        return caseSLAs;
    }

    private static List<Holiday> holidays;
    public static List<Holiday> getHolidays() {
        if (holidays == null) {
            holidays = [select ActivityDate from holiday];
        }
        return holidays;
    }
}