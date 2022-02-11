public class CAA_Test_Security
{
    public String InputVar {get;set;}
    public String OutputVar {get;set;}
    public String Error {get;set;}

    public PageReference Encrypt()
    {
        try
        {
            Error = '';
            OutputVar = CAA_Helper.EncryptData(InputVar);
        }
        catch(Exception ex)
        {
            Error = ex.getMessage();
        }
        return null;
    }
    
    public PageReference Decrypt()
    {
        try
        {
            Error = '';
            OutputVar = CAA_Helper.EncryptData(InputVar);
        }
        catch(Exception ex)
        {
            Error = ex.getMessage();
        }
        return null;
    }

}