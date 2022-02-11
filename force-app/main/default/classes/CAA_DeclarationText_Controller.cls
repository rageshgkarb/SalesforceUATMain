public class CAA_DeclarationText_Controller extends CAA_Core_Controller
{
    public String IbbProductName {get;set;}

    public boolean showDirectSavingsAccountTC {
        get {
            return ('DIRECT SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean show60DayNoticeAccountTC {
        get {
            return ('60 DAY NOTICE ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean show120DayNoticeAccountTC {
        get {
            return ('120 DAY NOTICE ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showOnDemandSavingsAccountTC {
        get {
            return ('ON DEMAND SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showYPSATC {
        get {
            return ('YOUNG PERSONS SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showISA {
        get {
            return ('Notice Cash ISA'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
	// C0595 Start
	public boolean show60DayISA {
        get {
            return ('60 Day Notice Cash ISA'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
	// C0595 End
    /* C0074 start */    
    public boolean showInstantISA         
    
    {        
       get         
       {            
         return ('Instant Access Cash ISA'.equalsIgnoreCase(ibbProductName) ? true : false);        
         }        
         set;            
         
       }    
       /* C0074  end */
       
       /* C0274 start */    
    public boolean showFTDISA         
    
    {        
       get         
       {            
         return ('12 Month Fixed Term ISA'.equalsIgnoreCase(ibbProductName) ? true : false);        
         }        
         set;            
         
       }    
       /* C0274  end */
       
     public boolean showYPNATC {
        get {
            return ('YOUNG PERSON\'S NOTICE SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
    public boolean showFixedTermAccountTC {
        get {
            if ('12 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                || '18 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                    || '24 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                        || '36 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)){
                return true;
            }else {
                return false;
            }
        }
        set;
    }
    public boolean showSmallFixedTermAccountTC {
        get {
            if ('03 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)
                || '06 MONTH FIXED TERM DEPOSIT ACCOUNT'.equalsIgnoreCase(ibbProductName)){
                return true;
            }else {
                return false;
            }
        }
        set;
    }
    
        public boolean showCurrentText{
        get{
        if(showYPSATC || showYPNATC)
        {
            return false;
        }
        else
        {
            return showCurrentAccountTC;
        }
        }
        set;
    }
    
      public boolean showSavingText{
        get{
        if(showYPSATC || showYPNATC)
        {
            return false;
        }
        else
        {
            return !showCurrentAccountTC;
        }
        }
        set;
    }
    
    public boolean showCurrentAccountTC {
        get {
            System.debug('*** -- ibbProductName = ' + ibbProductName + ' -- ***');
            return ('CURRENT ACCOUNT'.equalsIgnoreCase(ibbProductName) ? true : false);
        }
        set;
    }
}