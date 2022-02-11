@isTest
private class OpportunityForecastTriggerHandler_Test {
    private static RecordType hppCAARecordType;
    private static List<HPPStatusFigures__c> statusFigures;
    private static List<HPPStatusTotalFigures__c> totalStatusFigures;
    private static List<Account> accounts;
    private static List<Opportunity> opportunities;
    
    /*
    private static void setupObjectsData() {
        hppCAARecordType = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Opportunity'
                AND IsActive = true
                AND DeveloperName = 'HPP_CAA'
            LIMIT 1
        ];
        
        accounts = new Account[] {
            new Account(Name = 'Account 1')
        };
        insert accounts;
    }
    
    private static void setupHPPStatusFiguresData() {
        HPPStatusFiguresTestData.getHPPStatusFigures();
        HPPStatusFiguresTestData.getHPPStatusTotalFigures();
    }
    
    private static void setupOpportunityForecastSettingsData() {
        HPPStatusFiguresTestData.getOpportunityForecastSettings();
    }
    
    private static testMethod void testInsertWithoutCustomSettingData1() {
        setupObjectsData();
        
        Test.startTest();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway',
                Probability = 50
            )
        };
        insert newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Amount);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate);
        System.assertEquals(opp1.Probability, newOpportunities[0].Probability);
        System.assertEquals(opp1.TotalOpportunityQuantity, newOpportunities[0].TotalOpportunityQuantity);
    }
    
    private static testMethod void testInsertWithoutCustomSettingData2() {
        setupOpportunityForecastSettingsData();
        setupObjectsData();
        
        Test.startTest();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway',
                Probability = 50
            )
        };
        insert newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Finance_Required__c);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate);
        System.assertEquals(opp1.Probability, newOpportunities[0].Probability);
        System.assertEquals(opp1.TotalOpportunityQuantity, 1);
    }
    
    private static testMethod void testInsertWithCustomSettingData1() {
        setupHPPStatusFiguresData();
        setupObjectsData();
        
        Test.startTest();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway'
            )
        };
        insert newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Amount);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate.addDays(63));
        System.assertEquals(opp1.Probability, 53);
        System.assertEquals(opp1.TotalOpportunityQuantity, newOpportunities[0].TotalOpportunityQuantity);
    }
    
    private static testMethod void testInsertWithCustomSettingData2() {
        setupOpportunityForecastSettingsData();
        setupHPPStatusFiguresData();
        setupObjectsData();
        
        Test.startTest();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway'
            )
        };
        insert newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Finance_Required__c);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate.addDays(63));
        System.assertEquals(opp1.Probability, 53);
        System.assertEquals(opp1.TotalOpportunityQuantity, 1);
    }
    
    
    
    
    
    
    
    private static testMethod void testUpdateWithoutCustomSettingData1() {
        setupObjectsData();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway',
                Probability = 50
            )
        };
        insert newOpportunities;
        
        Test.startTest();
        
        newOpportunities[0].Status_HPP_CAA__c = 'AIP Completed';
        newOpportunities[0].Finance_Required__c = 25000;
        newOpportunities[0].Probability = 1;
        update newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Amount);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate);
        System.assertEquals(opp1.Probability, newOpportunities[0].Probability);
        System.assertEquals(opp1.TotalOpportunityQuantity, newOpportunities[0].TotalOpportunityQuantity);
    }
    
    private static testMethod void testUpdateWithoutCustomSettingData2() {
        setupOpportunityForecastSettingsData();
        setupObjectsData();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway',
                Probability = 50
            )
        };
        insert newOpportunities;
        
        Test.startTest();
        
        newOpportunities[0].Status_HPP_CAA__c = 'AIP Completed';
        newOpportunities[0].Finance_Required__c = 25000;
        newOpportunities[0].Probability = 1;
        update newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Finance_Required__c);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate);
        System.assertEquals(opp1.Probability, newOpportunities[0].Probability);
        System.assertEquals(opp1.TotalOpportunityQuantity, 1);
    }
    
    private static testMethod void testUpdateWithCustomSettingData1() {
        setupHPPStatusFiguresData();
        setupObjectsData();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway'
            )
        };
        insert newOpportunities;
        
        Test.startTest();
        
        newOpportunities[0].Status_HPP_CAA__c = 'AIP Completed';
        newOpportunities[0].Finance_Required__c = 25000;
        newOpportunities[0].Probability = 1;
        update newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Amount);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate.addDays(65));
        System.assertEquals(opp1.Probability, 63);
        System.assertEquals(opp1.TotalOpportunityQuantity, newOpportunities[0].TotalOpportunityQuantity);
    }
    
    private static testMethod void testUpdateWithCustomSettingData2() {
        setupOpportunityForecastSettingsData();
        setupHPPStatusFiguresData();
        setupObjectsData();
        
        List<Opportunity> newOpportunities = new Opportunity[] {
            new Opportunity(
                Name = 'Opp 1', AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway'
            )
        };
        insert newOpportunities;
        
        Test.startTest();
        
        newOpportunities[0].Status_HPP_CAA__c = 'AIP Completed';
        newOpportunities[0].Finance_Required__c = 25000;
        newOpportunities[0].Probability = 1;
        update newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Finance_Required__c);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate.addDays(65));
        System.assertEquals(opp1.Probability, 63);
        System.assertEquals(opp1.TotalOpportunityQuantity, 1);
    }
    
    private static testMethod void testMassInsertWithCustomSettingData() {
        setupHPPStatusFiguresData();
        setupObjectsData();
        
        Test.startTest();
        
        List<Opportunity> newOpportunities = new Opportunity[]{};
        for (Integer i = 0; i < 300; ++i) {
            Opportunity opp = new Opportunity(
                Name = 'Opp ' + i, AccountId = accounts[0].Id, RecordTypeId = hppCAARecordType.Id, StageName = 'Open', 
                CloseDate = Date.today(), Finance_Required__c = 10000, Status_HPP_CAA__c = 'Application Underway'
            );
            newOpportunities.add(opp);
        }
        insert newOpportunities;

        Test.stopTest();
        
        //  Re-query data
        Opportunity opp1 = [
            SELECT Amount, CloseDate, Probability, TotalOpportunityQuantity
            FROM Opportunity
            WHERE Id = :newOpportunities[0].Id
            LIMIT 1
        ];
        
        System.assertEquals(opp1.Amount, newOpportunities[0].Amount);
        System.assertEquals(opp1.CloseDate, newOpportunities[0].CloseDate.addDays(63));
        System.assertEquals(opp1.Probability, 53);
        System.assertEquals(opp1.TotalOpportunityQuantity, newOpportunities[0].TotalOpportunityQuantity);
    }
    */
}