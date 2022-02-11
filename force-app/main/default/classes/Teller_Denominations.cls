global class Teller_Denominations {
	public Boolean Success {get;set;}
    public String ErrorCode {get;set;}
    public String ErrorDescription {get;set;}
    public String TransferCurrency{get;set;}
    public Decimal TransactionAmount {get;set;}
    public Decimal TotalSelectedValue {get;set;}
    public List<DenominationCurrency> TillCurrencies {get;set;}
    public Id tillId {get;set;}
    public Id fromTillId {get;set;}
    public Id toTillId {get;set;}

    public List<Teller_Denomination> TransactionDenonminations {get;set;}
    
    public class DenominationCurrency{
        public string CurrencySymbol{get;set;}
    }

    public class Teller_Denomination{
        public String DenominationCurrency{get;set;}
        public String FormattedDenominationValue{get;set;}
        public Decimal DenominationValue{get;set;}
        public Integer NumberSelected{get;set;}
        public String FormattedTotalValue{get;set;}
        public Decimal TotalValue{get;set;}
        public Integer NoInTill{get;set;}
        public String Direction{get;set;}
		//Property used by UI to determine if a change has been made to this denomination - i.e. either via number selcted or total value
		public String change {get;set;}
    }
    
    public Teller_Denominations()
    {
        TransactionDenonminations = new List<Teller_Denomination>();
    }
}