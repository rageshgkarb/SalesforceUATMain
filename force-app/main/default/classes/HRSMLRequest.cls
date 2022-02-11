/* ---------------------------------------------------------------------------------------------------	*/
/* C0689 Process HR SML requests web service															*/
/* ---------------------------------------------------------------------------------------------------	*/


public class HRSMLRequest 
{
	public string JobID {get ; set ; }
	public string MessageName {get ; set ; }
	public List<HRSMLRequestRecord> HRRecords {get; Set; }

}