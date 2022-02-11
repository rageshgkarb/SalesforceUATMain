public without sharing class DecisionEngineMethods
{
    public static string  ProcessTheReturnValues (IBBEvents.CompleteEventArgs args)
    {
        string rtv = '';
        boolean decline = false;
        boolean refer = false;
        boolean systemerror = false;
        boolean addressMismatch = false;
        
        for (integer i = 0; i < args.DEResponse.DecisionReasons.Size(); i++)
        {
            if (String.IsEmpty(args.DEResponse.DecisionReasons[i].ReasonCode) ||
                args.DEResponse.DecisionReasons[i].ReasonCode == 'SUCCESS')
            {
                continue;
            }
            else if (args.DEResponse.DecisionReasons[i].ReasonCode.Contains('ADDRESSMISSMATCH'))
            {
                system.debug ('We in here ? ' + args.DEResponse.DecisionReasons[i].ReasonCode);
                addressMismatch = true;
            }
            else if (args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,5) == 'REFER')
            {
                refer = true;
            }
            
            else if (args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,7) == 'DECLINE')
            {
                decline = true;
            }
            
            else if (args.DEResponse.DecisionReasons[i].ReasonCode == 'SYSTEMERROR' ||
                args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0, 11) == 'SYSTEMERROR' ||
                args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,4) == 'FAIL')
            {
                systemerror = true;
            }                          
        }
        
        if (addressMisMatch)
        {
            rtv = 'ADDRESSMISMATCH';
        }
        else if (decline)
        {
            rtv = 'DECLINE';
        }
        else if (refer)
        {
            rtv = 'REFER';
        }
        else if (systemerror)
        {
            rtv = 'SYSTEMERROR';
        }
        else
        {
            rtv = 'SUCCESS';
        }
    
        return rtv;
    }
    
    
}