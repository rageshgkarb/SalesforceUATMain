@isTest
private class EncryptedCard_Test {
	private static testMethod void testEncryptedCard() {
		Test.startTest();
		
		Contact newContact = new Contact(
			FirstName = 'Test', LastName = 'Test'
		);
		insert newContact;
		
		Card__c newCard = new Card__c(
			Contact__c = newContact.Id,
			Name = '1111222233334444',
			Card_Type__c = 'VISA',
			Expiry_Date_Encrypted__c = '01/2015',
			Security_Code_Encrypted__c = '123'
		);
		insert newCard;
		
		EncryptedCard enCard = new EncryptedCard(newCard.Id, newCard.Name, newCard.Card_Type__c, newCard.Expiry_Date_Encrypted__c, newCard.Security_Code_Encrypted__c);
		Test.stopTest();
		
		System.assertEquals(enCard.cardNumber, '************4444');
		System.assertEquals(enCard.securityCode, '***');
		System.assertEquals(enCard.expiryDate, '*******');
	}
	
	private static testMethod void testBlankEncryptedCard() {
		Test.startTest();
		
		Contact newContact = new Contact(
			FirstName = 'Test', LastName = 'Test'
		);
		insert newContact;
		
		Card__c newCard = new Card__c(
			Contact__c = newContact.Id,
			Name = '1111222233334444',
			Card_Type__c = 'VISA',
			Expiry_Date_Encrypted__c = '01/2015',
			Security_Code_Encrypted__c = '123'
		);
		insert newCard;
		
		EncryptedCard enCard = new EncryptedCard(newCard.Id, '', '', '', '');
		
		EncryptedCard blankCard = new EncryptedCard();
		
		Test.stopTest();
		
		System.assertEquals(enCard.cardNumber, '');
		System.assertEquals(enCard.securityCode, '');
		System.assertEquals(enCard.expiryDate, '');
	}
}