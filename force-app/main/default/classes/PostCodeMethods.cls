/* ------------------------------------------------------------------------------- */
/* C00196 27/03/2014    New class to perform region lookup from postcode           */

/* ------------------------------------------------------------------------------- */                             

public without sharing class PostCodeMethods
{
    public string Region {get;set;}
    public Map<string, string> KeysToRegions {get;set;}
    public Map<string, string> PostCodeToRegions {get;set;}
    
    public PostCodeMethods()
    {}
    
    public PostCodeMethods (List<string> inPostCodes)
    {
        CreateRegionMap();
        SetThePostCodeToRegions (inPostCodes);
    }
   
    public PostCodeMethods (string inPostCode)
    {
        CreateRegionMap();
        Region = SetTheRegion(inPostCode);
        
    
    }
    
    public void SetThePostCodeToRegions (List<string> inPostCodes)
    {
        PostCodeToRegions = new Map<string, string>();
        for ( string s : inPostCodes )
        {
            PostCodeToRegions.put (s, SetTheRegion (s));
        }
    }
    
    public string SetTheRegion (string inPostCode)
    {
        if (!String.IsBlank(inPostCode))
        {
            inPostCode = inPostCode.Trim();
        }
        else
        {
            inPostCode = '';
        }
        string theRegion = '';
        string thePostCode = '';
        string thePostKey = '';
        if (!String.IsBlank(inPostCode))
        {
            if (inPostCode.Contains (' '))
            {
                thePostCode = inPostCode;
                integer i = thePostCode.indexof (' ');
                thePostKey = thePostCode.Substring (0, i );
                thePostKey = thePostKey.toUpperCase();
               
                theRegion = GetTheRegion (thePostKey);
            }
            else
            {
                theRegion = '-NO SPACE IN POST CODE-';
            }
        }
        else
        {
            theRegion = '-NO POSTCODE-';
        }
        
        return theRegion;
    }
    
    public void CreateRegionMap ()
    {
        List<PostcodeRegion__c> pCodeRegions = [SELECT    Name,
                                                          Region__c
                                                FROM      PostCodeRegion__c];
        KeysToRegions = new Map<string, string>();                                     
        for ( PostcodeRegion__c pCodeRegion : pCodeRegions )
        {
            KeysToRegions.put (pCodeRegion.Name, pCodeRegion.Region__c);
        }
                                                       
    }
    
    public string GetTheRegion (string thePostKey)
    {
        string rtv = '';
        boolean matched = false;
        string reg = '';
        try
        {
            reg = KeysToRegions.get (thePostKey);
    
            if (!String.IsBlank (reg))
            {
                matched = true;
                rtv = reg;
            }
            
            if (!matched)
            {
                string shortReg = thePostKey.Substring (0, 2);
                string secChar = shortReg.Substring (1);
                if (secChar.IsNumeric())
                {
                    reg = KeysToRegions.get (shortReg.Substring (0,1));
                }
                else
                {
                    reg = KeysToRegions.get (shortReg);
                }
            }
            
            if (!String.IsBlank (reg))
            {
                rtv= reg;
            }
            else
            {
                rtv= '-NOT FOUND-';
            }
        }
        catch (Exception ex)
        {
        }
        
        return rtv;
    }
}