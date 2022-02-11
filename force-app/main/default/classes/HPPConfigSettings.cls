/* ------------------------------------------------------------------------------------------------------ */
/* C00203    Class to get HPP Config Settings                                                             */                
/* ------------------------------------------------------------------------------------------------------ */

public without sharing class HPPConfigSettings
{
    public List<HPPConfigSettings__c> configs = HPPConfigSettings__c.getall().values();
    public integer iConfigValue {get;set;}
    public string sConfigValue {get;set;}
    public DateTime dtmConfigValue {get;set;}
    public Date dtConfigValue {get;set;}
    public double dConfigValue {get;set;}
	public decimal decConfigValue {get;set;}
    public boolean bConfigValue {get;set;}
    public string theConfigKey {get;set;}
    public string theConfigDataType {get;set;}
    
    public HPPConfigSettings (string configKey, string configDataType)
    {
        theConfigKey = configKey;
        theConfigDataType = configDataType;
        GetKeyValue();
    }
    
    public void GetKeyValue()
    {
        string rtv;
        for (HPPConfigSettings__c config : configs)
        {
            if (config.name == theConfigKey)
            {
                SetConfigValue (config.ConfigValue__c, config.ConfigDataType__c);
            }
        }
    }
    
    private void SetConfigValue (string configValue, string configDataType)
    {
        if (configDataType.EqualsIgnoreCase( 'STRING'))
        {
            sConfigValue = configValue;
        }
        else if (configDataType.EqualsIgnoreCase ('DOUBLE'))
        {
            dConfigValue = Double.ValueOf (configValue);
        }
		else if (configDataType.EqualsIgnoreCase ('DECIMAL'))
        {
            decConfigValue = Decimal.ValueOf (configValue);
        }
        else if (configDataType.EqualsIgnoreCase ('DATE'))
        {
            dtConfigValue = Date.ValueOf (configValue);
        }
        else if (configDataType.EqualsIgnoreCase ('DATETIME'))
        {
            dtmConfigValue = DateTime.ValueOf (configValue);
        }
        else if (configDataType.EqualsIgnoreCase ('BOOLEAN'))
        {
            bConfigValue = Boolean.ValueOf (configValue);
        }
        else if (configDataType.EqualsIgnoreCase ('INTEGER'))
        {
            iConfigValue = Integer.ValueOf (configValue);
        }
        else
        {
            sConfigValue = configValue;
        }
        
    }
}