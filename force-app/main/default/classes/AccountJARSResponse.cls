/* ---------------------------------------------------------------------------------------------------- */
/* C0559																								*/
/* ---------------------------------------------------------------------------------------------------- */

public class AccountJARSResponse
{
	public string BatchID {get ; set ;}
	public List<AccountJARResponse> JARResponses {get ; set ;}
	public class AccountJARResponse
	{
		public string msgID {get ; set ;}
		public string accountNumber {get ; Set; }
		public string customerNo {get ; set ;}
		public string responseCode {get ; set ;}
		public string responseMessage {get ; set;}
	}
}