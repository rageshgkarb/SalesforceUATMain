/* -------------------------------------------------------------------------------------- */
/* C0Steve  New classes for International Payments - Steve F to update reference          */
/* -------------------------------------------------------------------------------------- */

public class InternationalPaymentRequest 
{ 
    public integer IFMID {get; Set;}
    public string MessageID {get ; Set;}
    public string MessageType {get ; Set;}
    public string CustNo {get; Set;}
    public string CustNo2 {get; Set;}
    public string AcFullName {get; Set;}
    public string AcNo {get; Set;}
    public string CustAddress {get; Set;}
    public string CustTelNo {get; Set;}
    public string BeneficiaryName {get; Set;}
    public date BeneficiaryDOB {get; Set;}
    public string BeneficiaryAddress {get; Set;}
    public string BeneficiaryAcNoIBAN {get; Set;}
    public string BeneficiarySwiftBIC {get; Set;}
    public string BankName {get; Set;}
    public string BankAddress {get; Set;}
    public double Amount {get; Set;}
    public string PaymentCurrency {get; Set;}
    public string CustPaymentRef  {get; Set;}
    public string Purpose {get; Set;}
    public integer Status {get; Set;}
    public string FeesPaidBy {get; Set;}
    public string Comment {get; Set;}
    public datetime LastActionDate {get; Set;}
    public datetime CreatedDate {get; Set;}
    public date PaymentDate {get; set;}
    

}