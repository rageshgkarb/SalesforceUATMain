/* ----------------------------------------------------------------------- */
/* C00233 Class to try and sort out address street and district for EBS    */
/* ----------------------------------------------------------------------- */

public without sharing class EBSAddress
{

    public string theAddress {get;set;}
    public string theStreet {get;set;}
    public string theDistrict {get;set;}
    public string theSeparator {get;set;}
    public List<string> theLines {get;set;}
    public integer theLength {get;set;}
    public integer theCount {get;set;}
    
    public EBSAddress (string address, string Separator, integer addressLength)
    {
        theAddress = address;
        theSeparator = separator;
        theLength = addressLength;
        SortOutAddress ();
    }

    public void SortOutAddress ()
    {
    
        if ( theAddress.Length() <= theLength )
        {
            theStreet = theAddress;
            theDistrict = '';
        }
        else
        {
            if ( theAddress.Contains (theSeparator))
            {
                theLines = new List<string>();
                theLines = theAddress.Split (theSeparator);
                theCount = theLines.Size();
                ProcessTheAddress ();
            }
            else
            {
                theStreet = theAddress.Substring (0, theLength);
            }
        }
    }
    
    private void ProcessTheAddress ()
    {
        if ( theCount  > 1 )
        {
            if ( theCount  == 2 )
            {
                /*
                if ( ( theLines[ 0 ] + theSeparator + theLines[ 1 ] ).Length() < theLength)
                {
                    theStreet = theLines[ 0 ] + theSeparator + theLines[ 1 ];
                }
                else
                {
                */
                    theStreet = theLines[ 0 ].Length() < theLength ? theLines[ 0 ] : theLines[ 0 ].Substring ( 0, theLength );
                    theDistrict = theLines[ 1 ].Length() < theLength ? theLines[ 1 ] : theLines[ 1 ].Substring ( 0, theLength );
                //}
            }

            if ( theCount == 3 )
            {
                /*
                if ( ( theLines[ 0 ] + theSeparator + theLines[ 1 ] + theSeparator + theLines[ 2 ] ).Length() < theLength )
                {
                    theStreet = theLines[ 0 ] + theSeparator + theLines[ 1 ] + theSeparator + theLines[ 2 ];
                }
                else
                {
                */
                    if ( ( theLines[ 0 ] + theSeparator + theLines[ 1 ] ).Length() < theLength )
                    {
                        theStreet = theLines[ 0 ] + theSeparator + theLines[ 1 ];
                        theDistrict = theLines[ 2 ].Length() < theLength ? theLines[ 2 ] : theLines[ 2 ].Substring ( 0, theLength );
                    }
                    else
                    {
                        if ((theLines[1] + theSeparator + theLines[2]).Length() < theLength )
                        {
                            theStreet = theLines[0];
                            theDistrict = theLines[1] + theSeparator + theLines[2];
                        }
                        else
                        {
                            theStreet = theLines[0];
                            theDistrict = (theLines[1] + theSeparator + theLines[2]).Substring (0, theLength);
                        }
                    }
                //}
            }

            if ( theCount == 4 )
            {
                /*
                if ( ( theLines[ 0 ] + 
                        theSeparator + 
                        theLines[ 1 ] + 
                        theSeparator + 
                        theLines[ 2 ] + 
                        theSeparator +
                        theLines[ 3 ] ).Length() < theLength )
                {
                    theStreet = theLines[ 0 ] + 
                                theSeparator + 
                                theLines[ 1 ] + 
                                theSeparator + 
                                theLines[ 2 ] +
                                theSeparator +
                                theLines[ 3 ];
                }
                else
                {
                */
                    if ( ( theLines[ 0 ] + theSeparator + theLines[ 1 ] ).Length() < theLength )
                    {
                        theStreet = theLines[ 0 ] + theSeparator + theLines[ 1 ];
                        if (( theLines[ 2 ] + theSeparator + theLines[ 3 ] ).Length() < theLength)
                        {
                            theDistrict = theLines[ 2 ] + theSeparator + theLines[ 3 ];
                        }
                        else
                        {
                            theDistrict = (theLines[ 2 ] + theSeparator + theLines[ 3 ]).Substring(0, theLength);   
                        }
                    }
                    else
                    {
                        if ((theLines[1] + theSeparator + theLines[2]).Length() < theLength )
                        {
                            theStreet = theLines[0];
                            theDistrict = (theLines[1] + theSeparator + theLines[2] + theSeparator + theLines[3]).Length() < theLength ? theLines[1] + theSeparator + theLines[2] + theSeparator + theLines[3] : (theLines[1] + theSeparator + theLines[2] + theSeparator + theLines[3]).Substring(0, theLength);
                        }
                        
                    }
                //}
            }
            
            if ( theCount == 5 )
            {
                /*
                if ( ( theLines[ 0 ] + 
                        theSeparator + 
                        theLines[ 1 ] + 
                        theSeparator + 
                        theLines[ 2 ] + 
                        theSeparator +
                        theLines[ 3 ] +
                        theSeparator +
                        theLines[ 4 ]).Length() < theLength )
                {
                    theStreet = theLines[ 0 ] + 
                                theSeparator + 
                                theLines[ 1 ] + 
                                theSeparator + 
                                theLines[ 2 ] +
                                theSeparator +
                                theLines[ 3 ] +
                                theSeparator +
                                theLines[ 4 ];
                }
                else
                {
                */
                    if ( ( theLines[ 0 ] + theSeparator + theLines[ 1 ] + theSeparator + theLines[ 2 ]).Length() < theLength )
                    {
                        theStreet = theLines[ 0 ] + theSeparator + theLines[ 1 ] + theSeparator + theLines[ 2 ];
                        if (( theLines[ 3 ] + theSeparator + theLines[ 4 ] ).Length() < theLength)
                        {
                            theDistrict = theLines[ 3 ] + theSeparator + theLines[ 4 ];
                        }
                        else
                        {
                            theDistrict = (theLines[ 3 ] + theSeparator + theLines[ 4 ]).Substring(0, theLength);   
                        }
                    }
                    else
                    {
                        if ((theLines[ 0 ] + theSeparator + theLines[ 1 ]).Length() < theLength )
                        {
                            theStreet = theLines[ 0 ] + theSeparator + theLines[ 1 ];
                            theDistrict = (theLines[ 2 ] + theSeparator + theLines[ 3 ] + theSeparator + theLines[ 4 ]).Length() < theLength ? 
                                                                    theLines[ 2 ] + theSeparator + theLines[ 3 ] + theSeparator + theLines[ 4 ] : 
                                                                    (theLines[ 2 ] + theSeparator + theLines[ 3 ] + theSeparator + theLines[ 4 ]).Substring(0, theLength);
                        }
                        else
                        {
                            theStreet = theLines[ 0 ];
                            theDistrict = (theLines[ 1 ] + theSeparator + theLines[ 2 ] + theSeparator + theLines[ 3 ]  + theSeparator + theLines[ 4 ]).Length() < theLength ? 
                                                                    theLines[ 1 ] + theSeparator + theLines[ 2 ] + theSeparator + theLines[ 3 ]  + theSeparator + theLines[ 4 ] : 
                                                                    (theLines[ 1 ] + theSeparator + theLines[ 2 ] + theSeparator + theLines[ 3 ]  + theSeparator + theLines[ 4 ]).Substring(0, theLength);
                        }
                        
                    }
                //}
            }
        }
        else
        {
            theStreet = theAddress.Substring ( 0, theLength );
        }
    }

}