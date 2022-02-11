/**
 *	A wrapper class used to pass Card details from the Controller to the View through JavaScript.
 *	This class will replace characters which should be hidden from the view of the user.
 */
public class EncryptedCard {
	public Id cardID { get; set; }
	public String cardNumber { 
		get;
		set {
			if (String.isNotBlank(value)) {
				Integer numberOfCharsToKeep = 4;
				String mask = '*';
				Integer maskLength = value.length() - numberOfCharsToKeep;
				cardNumber = mask.repeat(maskLength) + value.right(numberOfCharsToKeep);
			}
			else {
				cardNumber = value;
			}
		} 
	}
	public String cardType { get; set; }
	public String expiryDate { 
		get; 
		set {
			if (String.isNotBlank(value)) {
				String mask = '*';
				Integer length = value.length();
				expiryDate = mask.repeat(length);
			}
			else {
				expiryDate = value;
			}
		} 
	}
	public String securityCode { 
		get; 
		set {
			if (String.isNotBlank(value)) {
				String mask = '*';
				Integer length = value.length();
				securityCode = mask.repeat(length);
			}
			else {
				securityCode = value;
			}
		} 
	}
	
	/**
	 *	Default Constructor - does nothing.
	 */
	public EncryptedCard() {
		//	Does nothing...
	}
	
	/**
	 *	Constructor which takes all encrypted card values.
	 */
	public EncryptedCard(Id cardID, String cardNumber, String cardType, String expiryDate, String securityCode) {
		this.cardID = cardID;
		this.cardNumber = cardNumber;
		this.cardType = cardType;
		this.expiryDate = expiryDate;
		this.securityCode = securityCode;
	}
}