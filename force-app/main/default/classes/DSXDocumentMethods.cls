/* ------------------------------------------------------------------------------------------------ */
/* C0728                                                                                            */
/* ------------------------------------------------------------------------------------------------ */


public class DSXDocumentMethods 
{ 
    public DSX_Document_Link__c a {get; Set;}
    public DSX_Document_Link__c b {get; Set;}
    public Opportunity opp {get; Set;}
    public List<string> outstandingDocs {get ; set ; }
    public DSXDocumentMethods (DSX_Document_Link__c docNew, DSX_Document_Link__c docOld)
    {
        a = docNew;
        if (docOld != null)
        {
            b = docOld;
        }
        
        
        opp = [SELECT Id,
                Opportunity_Reference__c,
                DSX_Documents_Expected__c,  
                DSX_Documents_Received__c,
                DSX_Documents_Outstanding__c        // C0728
        FROM Opportunity
        WHERE id = :a.Opportunity__c];

        outstandingDocs = new List<string>();

        system.debug ( 'Documents outstanding A ' + opp.DSX_Documents_OutStanding__c );
        if (!String.IsBlank ( opp.DSX_Documents_OutStanding__c ))
        {
            if (opp.DSX_Documents_OutStanding__c.Contains (';'))
            {
                outstandingDocs = opp.DSX_Documents_OutStanding__c.Split(';');
            }
            else
            {
                outstandingDocs.Add (opp.DSX_Documents_OutStanding__c);
            }
        }
        outstandingDocs.Sort();
    }

    public void ProcessInserts ()
    {
        if (a.Document_status__c != 'Rejected')
        {
            if (a.Document_Status__c == 'Verified')
            {
                if (outstandingDocs.Size() > 0 )
                {
                    if (opp.DSX_Documents_Expected__c.Contains (a.Document_Name__c))
                    {
                        integer i = 0;
                        for (string s : outstandingDocs)
                        {
                            system.debug ( 'OS doc ' + s);
                            system.debug ( 'Doc Name ' + a.Document_Name__c);
                            if (s.trim() == a.Document_Name__c)
                                break;
                            i = i + 1;
                        }
                        system.debug ( 'Value of i ' + i);
                        system.debug ( 'Docs Outstanding E ' + outstandingDocs );
                        outstandingDocs.Remove (i);
                    }
                }
            }
            opp.DSX_Documents_Received__c = String.isBlank(opp.DSX_Documents_Received__c) ? a.Document_Name__c : opp.DSX_Documents_Received__c + ';' + a.Document_Name__c;
        }
        else 
        {
            opp.DSX_Documents_Received__c = opp.DSX_Documents_Received__c.Replace (a.Document_Name__c + ';', '');
        }

        ProcessOutstanding ();
    }

    public void ProcessUpdates ()
    {
        // Put/Reinstate document on list of Outstanding
        if ((a.Document_status__c == 'Rejected' && b.Document_status__c != 'Rejected') || 
            (a.Document_status__c == 'Received' && (b.Document_status__c == 'Verified' || b.Document_Status__c == 'Rejected' )))
                    
        {
            system.debug ( 'Docs Outstanding C ' + opp.DSX_Documents_Outstanding__c );
            opp.DSX_Documents_Received__c = opp.DSX_Documents_Received__c.Replace (a.Document_Name__c + ';', '');

            /* C0728 Update Documents outstanding */

            if (opp.DSX_Documents_Expected__c.Contains ( a.Document_Name__c)  )
            {
                if (string.IsBlank (opp.DSX_Documents_OutStanding__c) || 
                    !opp.DSX_Documents_OutStanding__c.contains  (a.Document_Name__c))
                {
                    outstandingDocs.Add (a.Document_Name__c);
                    system.debug ( 'Docs Outstanding D ' + outstandingDocs );
                }
            }
        }
        else    // Remove from outstanding
        {
            if (outstandingDocs.Size() > 0 )
            {
                if (opp.DSX_Documents_Expected__c.Contains (a.Document_Name__c))
                {
                    integer i = 0;
                    for (string s : outstandingDocs)
                    {
                        system.debug ( 'OS doc ' + s);
                        system.debug ( 'Doc Name ' + a.Document_Name__c);
                        if (s.trim() == a.Document_Name__c)
                            break;
                        i = i + 1;
                    }
                    system.debug ( 'Value of i ' + i);
                    system.debug ( 'Docs Outstanding E ' + outstandingDocs );
                    outstandingDocs.Remove (i);
                }
            }
        }
        
        ProcessOutstanding();               
    }

    public void ProcessOutstanding ()
    {
        if (outstandingDocs.Size() > 0 )
        {
            string str = '';
            for ( string st : outstandingDocs)
            {
                str = String.isBlank(str) ? st  : str + ';' + st;
            }

            opp.DSX_Documents_Outstanding__c = str;
        }
        else
        {
            opp.DSX_Documents_Outstanding__c = '';
        }
        update opp;
    }

}