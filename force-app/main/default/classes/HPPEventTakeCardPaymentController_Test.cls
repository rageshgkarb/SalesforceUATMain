@isTest
private class HPPEventTakeCardPaymentController_Test {
/*
    private static EventLog__c eventLog;
    private static Opportunity opportunity;
    
    private static testMethod void setup() {
        HPPEventTestsUtility.setupBaseData();
        
        SecureTradingSettings__c secureTradingSettings = new SecureTradingSettings__c(
            Alias__c = 'alias', Endpoint__c = 'endpoint', Password__c = 'password', SiteReference__c = 'siteref',
            TermURL__c = 'http://www.termurl.com/', UseCardTypeMapping__c = false, Username__c = 'username',
            Version__c = '1.0', Name = 'Card Store Settings'
        );
        insert secureTradingSettings;
        
        Event__c event = new Event__c();
        insert event;
        
        eventLog = new EventLog__c(
            Opportunity__c = HPPEventTestsUtility.opportunity.Id, Event__c = event.Id,
            EventStatus__c = 'Open'
        );
        insert eventLog;
        
        ProductEventDirector__c productEventDirector = new ProductEventDirector__c(
            Event__c = event.Id
        );
        insert productEventDirector;
        
        opportunity = HPPEventTestsUtility.opportunity;
        opportunity.ProductEventDirector__c = productEventDirector.Id;
        update opportunity;
        
        PageReference takeCardPaymentPage = Page.HPPEventTakeCardPayment;
        takeCardPaymentPage.getParameters().put('id', eventLog.Id);
        takeCardPaymentPage.getParameters().put('oppId', HPPEventTestsUtility.opportunity.Id);
        Test.setCurrentPage(takeCardPaymentPage);
        
        HPPEventTakeCardPaymentController controller = new HPPEventTakeCardPaymentController();
    }
    
    private static testMethod void testInitialSetup() {
        setup();
        
        PageReference takeCardPaymentPage = Page.HPPEventTakeCardPayment;
        takeCardPaymentPage.getParameters().put('id', eventLog.Id);
        takeCardPaymentPage.getParameters().put('oppId', HPPEventTestsUtility.opportunity.Id);
        Test.setCurrentPage(takeCardPaymentPage);
        
        HPPEventTakeCardPaymentController controller = new HPPEventTakeCardPaymentController();
        
        System.assertEquals(controller.getRequireManualSecurityCodeEntry(), false);
        System.assertEquals(controller.showPaymentMethodOtherSection, false);
        System.assertEquals(controller.showPaymentMethodNoneSection, false);
        System.assertEquals(controller.showPaymentMethodInternalSection, false);
        System.assertEquals(controller.showCardSections, false);
        System.assertEquals(controller.adminFeeIsEditable, false);
        System.assertEquals(controller.allCards.size(), 0);
    }
    
    private static testMethod void testValidation() {
        
        HPPEventTestsUtility.setupBaseData();
        
        Event__c event = new Event__c();
        insert event;
        
        EventLog__c eventLog = new EventLog__c(
            Opportunity__c = HPPEventTestsUtility.opportunity.Id, Event__c = event.Id,
            EventStatus__c = 'Open'
        );
        insert eventLog;
        
        ProductEventDirector__c productEventDirector = new ProductEventDirector__c(
            Event__c = event.Id
        );
        insert productEventDirector;
        
        Opportunity opportunity = HPPEventTestsUtility.opportunity;
        opportunity.ProductEventDirector__c = productEventDirector.Id;
        update opportunity;
        
        
        setup();
        
        PageReference takeCardPaymentPage = Page.HPPEventTakeCardPayment;
        takeCardPaymentPage.getParameters().put('id', eventLog.Id);
        takeCardPaymentPage.getParameters().put('oppId', HPPEventTestsUtility.opportunity.Id);
        Test.setCurrentPage(takeCardPaymentPage);
        
        HPPEventTakeCardPaymentController controller = new HPPEventTakeCardPaymentController();
        
        Test.startTest();
        
        controller.autoRun();
        controller.takePayment();
        //  controller.confirmPayment();
        controller.completeTheEvent();
        
        controller.exOpp.AdminFeeValue__c = 100;
        controller.exOpp.Payment_method__c = 'Card';
        controller.exOpp.AdminFeeReceived__c = 'Suspended';
        controller.takePayment();
        controller.completeTheEvent();
        
        controller.exOpp.AdminFeeReceived__c = 'No';
        controller.completeTheEvent();
        
        Card__c newCard = new Card__c(
            Contact__c = controller.personAccountContact.Id, 
            Billing_Street__c = 'Street',
            Billing_City__c = 'City',
            Billing_County_State__c = 'State',
            Billing_Country__c = 'Country',
            Billing_Post_Code__c = 'Post Code',
            Card_Currency__c = 'GBP',
            Card_Type__c = 'VISA',
            Card_Number_Encrypted__c = '1111222233334444',
            Security_Code_Encrypted__c = '123',
            Expiry_Month__c = 01,
            Expiry_Year_Text__c = String.valueOf(Date.today().addYears(1).year()),
            Valid_From_Month__c = 01,
            Valid_From_Year_Text__c = String.valueOf(Date.today().addYears(-1).year())
        );
        insert newCard;
        Id cardId = newCard.Id;
        
        //  controller.saveNewCard();
        controller.takePayment();
        
        controller.exopp.Payment_Method__c = 'Other payment method';
        controller.exOpp.Other_payment_method__c = 'Internal Transfer';
        controller.exOpp.Other_Payment_Account_No__c = null;
        controller.exOpp.Other_Payment_Sortcode__c = null;
        controller.completeTheEvent();
        
        controller.exOpp.Other_payment_method__c = 'External Transfer';
        controller.completeTheEvent();
        
        controller.exOpp.Other_payment_method__c = 'Cheque';
        controller.completeTheEvent();
        
        controller.exOpp.Other_payment_method__c = 'Internal Transfer';
        controller.exOpp.Other_Payment_Account_No__c = '00098889';
        controller.exOpp.Other_Payment_Sortcode__c = '890890';
        controller.completeTheEvent();
        
        Card__c selectedCard = controller.selectCard(cardID);
        EncryptedCard encryptedCard = HPPEventTakeCardPaymentController.selectEncryptedCard(cardID);
        controller.exOpp.Payment_method__c = 'Card';
        controller.exOpp.AdminFeeReceived__c = null;
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockSTCardStoreCallout());
        
        controller.selectedCard.Billing_Street__c = 'Street';
        controller.selectedCard.Billing_City__c = 'City';
        controller.selectedCard.Billing_County_State__c = 'State';
        controller.selectedCard.Billing_Country__c = 'Country';
        controller.selectedCard.Billing_Post_Code__c = 'Post Code';
        controller.selectedCard.Card_Currency__c = 'GBP';
        controller.selectedCard.Card_Type__c = 'VISA';
        controller.selectedCard.Card_Number_Encrypted__c = '1111222233334444';
        controller.selectedCard.Security_Code_Encrypted__c = '123';
        controller.selectedCard.Expiry_Month__c = 01;
        controller.selectedCard.Expiry_Year_Text__c = String.valueOf(Date.today().addYears(1).year());
        controller.selectedCard.Valid_From_Month__c = 01;
        controller.selectedCard.Valid_From_Year_Text__c = String.valueOf(Date.today().addYears(-1).year());
        
        controller.saveNewCard();
        
        controller.exOpp.Payment_Method__c = 'None';
        controller.exOpp.Payment_confirmed_by_other_method__c = true;
        controller.exOpp.Payment_none_comments__c = 'Test comments';
        controller.completeTheEvent();
        
        //  controller.togglePaymentConfirmed();
        //  controller.togglePaymentConfirmed();
        
        Test.stopTest();
        
        //  System.assertEquals(controller.allCards.size(), 0);
        //  System.assertNotEquals(controller.selectedCard.Id, null);
        System.assertEquals(controller.getRequireManualSecurityCodeEntry(), false);
        
    }
    
    private static testMethod void testNewCardValidation() {
        setup();
        
        PageReference takeCardPaymentPage = Page.HPPEventTakeCardPayment;
        takeCardPaymentPage.getParameters().put('id', eventLog.Id);
        takeCardPaymentPage.getParameters().put('oppId', HPPEventTestsUtility.opportunity.Id);
        Test.setCurrentPage(takeCardPaymentPage);
        
        HPPEventTakeCardPaymentController controller = new HPPEventTakeCardPaymentController();
        
        Test.startTest();
        
        controller.saveNewCard();
        
        Test.stopTest();
    }
    
    private static testMethod void testTakePayment() {
        setup();
        
        PageReference takeCardPaymentPage = Page.HPPEventTakeCardPayment;
        takeCardPaymentPage.getParameters().put('id', eventLog.Id);
        takeCardPaymentPage.getParameters().put('oppId', HPPEventTestsUtility.opportunity.Id);
        Test.setCurrentPage(takeCardPaymentPage);
        
        HPPEventTakeCardPaymentController controller = new HPPEventTakeCardPaymentController();
        
        Test.startTest();
        
        controller.autoRun();
        
        controller.exOpp.AdminFeeValue__c = 100;
        controller.exOpp.Payment_method__c = 'Card';
        
        Card__c newCard = new Card__c(
            Contact__c = controller.personAccountContact.Id, 
            Billing_Street__c = 'Street',
            Billing_City__c = 'City',
            Billing_County_State__c = 'State',
            Billing_Country__c = 'Country',
            Billing_Post_Code__c = 'Post Code',
            Card_Currency__c = 'GBP',
            Card_Type__c = 'VISA',
            Card_Number_Encrypted__c = '1111222233334444',
            Security_Code_Encrypted__c = '123',
            Expiry_Month__c = 01,
            Expiry_Year_Text__c = String.valueOf(Date.today().addYears(1).year()),
            Valid_From_Month__c = 01,
            Valid_From_Year_Text__c = String.valueOf(Date.today().addYears(-1).year()),
            Token_Encrypted__c = 'testing'
        );
        insert newCard;
        Id cardId = newCard.Id;
        
        controller.selectedCard = controller.selectCard(cardID);
        EncryptedCard encryptedCard = HPPEventTakeCardPaymentController.selectEncryptedCard(cardID);
        controller.exOpp.AdminFeeReceived__c = null;
        
        controller.takePayment();
        
        Test.stopTest();
    }
*/
}