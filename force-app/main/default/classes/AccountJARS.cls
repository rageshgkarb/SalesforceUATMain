/* ---------------------------------------------------------------------------------------------------- */
/* C0559																								*/
/* ---------------------------------------------------------------------------------------------------- */

public class AccountJARS 
{
	public string batchID {get ; set ;}
	public List<JARS> AcctJARS {get ; set ;}

	public class JARS
	{
		public string msgID {get ; set ;}
		public string acctNo {get;Set;}
		public boolean primaryOnly {get ; set ;}
		public List<JAR> AcctJAR {get ; set ;}
	}


	public class JAR 
	{
		public string EBSID {get ; set ; }
		public string CustName {get ; set ;}
		public string Relationship {get ; set ;}
	}

}