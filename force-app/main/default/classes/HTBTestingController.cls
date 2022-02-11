public class HTBTestingController {
    public Integer month { get; set; }
    public Integer year { get; set; }
    public String message { get; private set; }
    
    private Boolean validateInputs() {        
        Boolean isValid = false;
        message = '';
        
        if (month != null && year != null) {
            if (month > 0 && month < 13 && year > 2000 && year <= Date.today().year()) {
                isValid = true;
            }
        }
        
        if (!isValid) {
            message = 'Please enter valid month and year values.';
        }
        
        return isValid;
    }
    
    public PageReference deleteMonthRecords() {
        if (validateInputs()) {
            Date startDate = Date.newInstance(year, month, 1);
            
            List<HTB_Reporting_Month__c> htbMonths = [
                SELECT Id
                FROM HTB_Reporting_Month__c
                WHERE Start_Date__c = :startDate
            ];
            
            if (!htbMonths.isEmpty()) {
                Set<Id> monthIDs = new Set<Id>();
                for (HTB_Reporting_Month__c month : htbMonths) {
                    monthIDs.add(month.Id);
                }
                
                List<HTB_Reporting_Static__c> htbStatics = [
                    SELECT Id
                    FROM HTB_Reporting_Static__c
                    WHERE HTB_Reporting_Month__c IN :monthIDs
                ];
                delete htbStatics;
                
                List<HTB_Reporting_Static_Update__c> htbStaticUpdates = [
                    SELECT Id
                    FROM HTB_Reporting_Static_Update__c
                    WHERE HTB_Reporting_Month__c IN :monthIDs
                ];
                delete htbStaticUpdates;
                
                List<HTB_Reporting_Dynamic__c> htbDynamics = [
                    SELECT Id
                    FROM HTB_Reporting_Dynamic__c
                    WHERE HTB_Reporting_Month__c IN :monthIDs
                ];
                delete htbDynamics;
                
                delete htbMonths;
                message = 'Deleted Old Month Data. ';
            }
        }
        
        return null;
    }
    
    public PageReference deleteAndCreateMonthRecords() {
        if (validateInputs()) {
            deleteMonthRecords();
            createMonthRecords();
        }
        
        return null;
    }
    
    public PageReference createMonthRecords() {
        if (validateInputs()) {
            Database.executeBatch(new HTBMonthProcessor(month, year));
            message =+ 'Creating New Month Data. This can take a few minutes.';
        }
        
        return null;
    }
}