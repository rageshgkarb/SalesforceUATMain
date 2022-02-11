/* ---------------------------------------------------------------------------------------------------- */
/* C0744    New service for replicating Personal Customers                                              */
/* ---------------------------------------------------------------------------------------------------- */
/* C0758    Fix date contamination, remove setting of account recordtype                                */
/* ---------------------------------------------------------------------------------------------------- */


global class SFDCReplicatePersonalCustomers
{ 
    public static Schema.SobjectField externalIdField {get ; set ; }
    public static XML_Message__c xmlMessage {get ; set ; }
    public static List<XML_Message_Tag__c> tagList {get ; set ; }
    public static Map<String, String> fieldMap {get ; Set ;}
    public static Map<String, String> fieldToTypeMap {get ; Set ;}
    public static Map<String, String> fieldToValuesMap {get ; Set ;}
    public static Map<String, Schema.SObjectField> objectMap {get ; set; }
    public static List<String> Custnos {get ; set ; }
    public static Dom.Document xDoc { get ; set ; }
    public static List<SObject> objectsToUpsert { get ; set ; }
    public static Map<String, String> custNosToMessageIDsMap { get ; set ; }
    public static Map<String, Account> custMap {get ; set ; }
    public static List<Account> accList { get ; set ; }
    public static string theQuery {get ;Set; }
    public static List<ReplicatePersonalCustomerResponse> TheResponses { get ; set ; }
    public static List<ReplicatePersonalCustomerResponse> TheResponsesToRespond { get ; set ; }

    webservice static string ReplicatePersonalCustomer (string inRequest)
    {
        GetTheMessageStructure ();
        String decodedString;
        try 
        {
            decodedString = EncodingUtil.urlDecode(inRequest, 'UTF-8');
            System.debug('*** -- DECODED STRING -- ***');
            System.debug('*** -- ' + decodedString + ' -- ***');
        }
        catch (Exception decodeEx)
        {
            System.debug('*** -- Error in processCustomers decoding string -- ***');
            System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }

        xDoc = new Dom.Document();
        xDoc.Load (decodedString );
        getCustomerNumbers (xDoc);
        getAccounts ();


        /* C0758 *
        RecordType personalRecType = [select id 
                                        from recordType 
                                        where ispersontype=true 
                                        and sobjectType='account' limit 1];
        C0758 end */
        TheResponsesToRespond = new List<ReplicatePersonalCustomerResponse>();
        /* Create Response for account numbers not found */
        System.debug ('The accMap ' + custMap );
        for (string custno : custnos )
        {

            if (!custMap.ContainsKey ( custno ))
            {
                ReplicatePersonalCustomerResponse resp = new ReplicatePersonalCustomerResponse ();
                resp.MessageID = custNosToMessageIDsMap.get (custno);
                resp.CustNo =custno;
                resp.ResponseCode = '00';
                resp.responseMessage = 'Customer not found';
                TheResponsesToRespond.add (resp);
                 
            }
        }

        if (accList.size() > 0)
        {
            String targetField;
            String targetValue;
            String fieldDataType;
            String strTargetValue;
            integer intTargetValue;
            Date dtTargetValue;
            double dblTargetValue;
            objectsToUpsert = new List<SObject>();
            SObject theObject;
            ReplicatePersonalCustomerResponse response;
            TheResponses = new List<ReplicatePersonalCustomerResponse>();

            DOM.XMLNode root = xDoc.getRootElement();
            for (Dom.XmlNode child : root.getChildElements ())
            {
                if (child.getNodeType () == Dom.XmlNodeType.ELEMENT)
                {
                    if (child.GetName () == 'SFDCPersonalCustomerUpdateRequest')
                    {
                        boolean accFound = false ;
                        for (Dom.XMLNode upd : child.getChildElements())
                        {
                            if (upd.getNodeType () == Dom.XmlNodeType.ELEMENT)
                            {
                                if (upd.getName () == 'CustNo')
                                {
                                    if (custMap.containsKey (upd.getText()))
                                    {
                                        theObject = (Account)custMap.get(upd.getText());
                                        
                                        response = new ReplicatePersonalCustomerResponse ();
                                        response.MessageID = custNosToMessageIDsMap.get (upd.getText());
                                        response.custno = upd.getText();
                                        System.debug ('The response - ' + response );
                                        accFound = true ;
                                    }
                                }
                                else 
                                {
                                    if (accFound )
                                    {
                                        string nodeName = upd.getName ();
                                        targetField = fieldMap.get (nodeName);
                                        fieldDataType = fieldToTypeMap.get (nodeName);
                                        if (targetField != null && fieldDataType != null)
                                        {
                                            if ('STRING'.equalsIgnoreCase(fieldDataType))
                                            {
                                                theObject.put (targetField, upd.getText());
                                            }
                                            else if ('INTEGER'.equalsIgnoreCase(fieldDataType))
                                            {
                                                intTargetValue = null;        //C0758
                                                boolean goodInt = true;
                                                if (String.isBlank(upd.getText ()))
                                                {
                                                    intTargetValue = null;
                                                }
                                                else 
                                                {
                                                    try 
                                                    {
                                                        intTargetValue = Integer.valueOf (upd.getText ());
                                                    }
                                                    catch (exception ei )
                                                    {
                                                        goodInt = false;
                                                    }
                                                }
                                                if (goodInt)
                                                {
                                                    theObject.put (targetField, intTargetValue);
                                                }
                                            }
                                            else if ('DOUBLE'.equalsIgnoreCase(fieldDataType))
                                            {
                                                dblTargetValue = null;        //C0758
                                                boolean goodDbl = true;
                                                if (String.isBlank(upd.getText ()))
                                                {
                                                    dblTargetValue = null;
                                                }
                                                else 
                                                {
                                                    try 
                                                    {
                                                        dblTargetValue = Double.valueof (upd.getText ());
                                                    }
                                                    catch (exception ed )
                                                    {
                                                        goodDbl = false;
                                                    }
                                                }
                                                if (goodDbl)
                                                {
                                                    theObject.put (targetField , dblTargetValue );
                                                }
                                                
                                                
                                            }
                                            else if ('DATE'.equalsIgnoreCase(fieldDataType))
                                            {
                                                dtTargetValue = null;        //C0758
                                                boolean goodDate = true ;
                                                if (String.isBlank(upd.getText ()))
                                                {
                                                    dtTargetValue = null;
                                                }
                                                else 
                                                {
                                                    try 
                                                    {
                                                        dtTargetValue = Date.Parse (upd.getText ());
                                                
                                                    }
                                                    catch (exception e)
                                                    {
                                                    }

                                                    if (dtTargetValue == null )
                                                    {
                                                        try 
                                                        {
                                                            dtTargetValue = Date.valueOf(upd.getText ());
                                                        }
                                                        catch (exception ex)
                                                        {
                                                            goodDate = false;
                                                        }
                                                    }
                                                }
                                                if (goodDate )
                                                {
                                                    theObject.put (targetField , dtTargetValue );   
                                                }
                                            }

                                        }
                                    }

                                }
                            }
                        }

                        
                        if (accFound )
                        {
                            System.debug ('The sobject ' + theObject );
                            // C0758 theObject.put ('RecordTypeId', PersonalRecType.id );
                            objectsToUpsert.add (theObject );
                            TheResponses.add (response);
                        }
                    }
                }
            }
            System.debug ('ObjectsToUpsert ' + objectsToupsert);
            //update objectsToUpsert;

            List<Database.SaveResult>   upResults = Database.update(objectsToupsert, false);

            if (upResults.size() > 0)
            {
                for (integer i = 0 ; i < upResults.size() ; i++)
                {
                    Database.Saveresult sr = upResults.get(i);
                    ReplicatePersonalCustomerResponse repMsg = TheResponses.get(i);
                    System.debug ('The RespMsg ' + repMsg );
                    if (sr.isSuccess())
                    {
                        repMsg.responseCode = '00';
                        repMsg.responseMessage = 'SUCCEEDED';
                    }
                    else 
                    {
                        repMsg.responseCode = '21';
                        List<Database.Error> dbErr = sr.getErrors();
                        Database.Error e = dbErr[0];
                        repMsg.responseMessage = e.getMessage();  
                    }
                    TheResponsesToRespond.add(repMsg);
                    System.debug ('The repMsg 2 ' + repMsg);
                }
            }
            System.debug ( 'The Responses ' + TheResponsesToRespond );
        }
        return ResponseMessage(TheResponsesToRespond);


    }

    public static void getCustomerNumbers ( Dom.Document xDoc )
    {
        CustNos = new List<String>();
        custNosToMessageIDsMap = new Map<string , String>();
        string custNo;
        string msgID;
        DOM.XMLNode root = xDoc.getRootElement();
        for (Dom.XmlNode child : root.getChildElements ())
        {
            if (child.getNodeType () == Dom.XmlNodeType.ELEMENT)
            {
                if (child.GetName () == 'SFDCPersonalCustomerUpdateRequest')
                {
                    for (Dom.XMLNode upd : child.getChildElements())
                    {
                        if (upd.getNodeType () == Dom.XmlNodeType.ELEMENT)
                        {
                            if (upd.getName () == 'CustNo' )
                            {
                                System.debug ( 'The accNo  '  + upd.getText());
                                custNo = upd.getText();
                                custNos.Add(custNo);
                            }
                            else if (upd.getName () == 'MessageID' )
                            {
                                System.debug ( 'The  MID  ' + custNo + ' - ' + upd.getText());
                                msgid = upd.getText();
                            }
                            

                        }
                        
                    }
                    System.debug ( 'The  accno & MID  ' + custNo + ' - ' + msgid);
                    custNosToMessageIDsMap.put (custNo, msgId);
                }
            }
        }

        System.debug ( 'The accNos to MID map ' + custNosToMessageIDsMap);
    }

    public static void getAccounts ()
    {
        string theEBSIDs = DataHelper.ConvertListToString (custNos);
        theQuery = 'SELECT iD, ' + theQuery + ' FROM Account WHERE EBS_ID__c in (' + theEBSIDs + ')';
        accList = Database.query (theQuery);

        custMap = new Map<String, Account>();

        if (accList.size() > 0)
        {
            for (Account acc : accList)
            {
                custMap.put(acc.EBS_ID__c, acc);

            }
        } 
        System.debug ( 'Accmap ' + custMap);
    }

    public static void GetTheMessageStructure ()
    {
        fieldMap = new Map<String, String>();
        fieldToTypeMap = new Map<String, String>();
        xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                        Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                        From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                        From XML_Message__c x where x.Type__c = 'Inbound' and x.Name = 'ReplicatePersonalCustomer' 
                                        and x.Active__c = true];
        tagList = xmlMessage.XML_Message_Tags__r;
        Map<String, xml_message_tag__c> doneTagNames = new Map<String, XML_Message_Tag__c>();
        for (XML_Message_Tag__c xmlTag : tagList)
        {
            fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
            fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
            if (!String.isBlank(xmlTag.Field_API_Name__c) )
            {
                if (doneTagNames.get(xmlTag.Field_API_Name__c) == null)
                {
                    theQuery = String.isBlank(theQuery) ? xmlTag.Field_API_Name__c : theQuery + ',' + xmlTag.Field_API_Name__c;
                }
            }
            doneTagNames.put(xmlTag.Field_API_Name__c, xmlTag);
        }
    }

    public static String ResponseMessage (List<ReplicatePersonalCustomerResponse> resps)
    {
        string rtv = '';
        rtv = '<ReplicatePersonalCustomerResponses>';
        for (ReplicatePersonalCustomerResponse resp : resps)
        {
            system.debug ( 'The resp ' + resp );
            rtv = rtv + '<ReplicatePersonalCustomerResponse>';
            rtv = rtv + '<MessageID>' + resp.messageID + '</MessageID>';
            rtv = rtv + '<CustomerNo>' + resp.custno + '</CustomerNo>';
            rtv = rtv + '<ResponseCode>' + resp.responseCode +  '</ResponseCode>';
            rtv = rtv + '<ResponseMsg>' + resp.responseMessage + '</ResponseMsg>';
            rtv = rtv + '</ReplicatePersonalCustomerResponse>';
            
        }
        rtv = rtv + '</ReplicatePersonalCustomerResponses>';
        
        
        return rtv;
    }

    public class ReplicatePersonalCustomerResponse
    {
        public string messageID {get ; set ; }
        public string CustNo {get ; set ; }
        public string responseCode {get ; set ; }
        public string responseMessage {get ; set ; }
        //public Account_With_IBB__c AWI {get ; set }
    }
}