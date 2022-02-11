public class TransactionHistoryWebService {

        public List<TransactionHistoryItem> sortedItemList = new List<TransactionHistoryItem>(); 
        public Boolean isTestRun{get; set;}
                
         
//@future (callout=true)
public List<TransactionHistoryItem> getTransactionHistory(String inAccountId, String fromDate, String toDate){

        List<TransactionHistoryItem> itemList = new List<TransactionHistoryItem>(); 
        String messageType = 'TransactionHistoryEnq';
        String xmlMessageName = 'TransactionHistoryRequest';        
        String xmlRequest;
        String returnString;
        boolean dataToDisplay;

        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null){
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        Webservice_Setting__c endPoint = Webservice_Setting__c.getValues('Webservice Endpoint');
     
         XML_Message__c xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                        Service_Namespace__c, Element_Namespace__c, Buffered__c,
                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c
                        From XML_Message_Tags__r Order By Message_Order__c ASC)
                        From XML_Message__c x where x.Type__c = 'Request' and x.Name = :xmlMessageName
                        and x.Active__c = true];
                        
                                                
        List<XML_Message_Tag__c> tagList = xmlMessage.XML_Message_Tags__r;
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
        String serviceNameElement = xmlMessage.Service_Name_Element__c;
        String serviceNamespace = xmlMessage.Service_Namespace__c;

        System.debug(loggingLevel.INFO,'*** --Service Name Element: ' + serviceNameElement + '-- ***');
        System.debug(loggingLevel.INFO,'*** -- serviceNamespace: ' + serviceNamespace + '-- ***');

        Webservice_Setting__c soapWS = Webservice_Setting__c.getValues('HTTP Soap NS');
        Webservice_Setting__c xsiWS = Webservice_Setting__c.getValues('HTTP xsi');

        Webservice_Setting__c sourceID = Webservice_Setting__c.getValues('SourceID');
        Webservice_Setting__c workstationID = Webservice_Setting__c.getValues('WorkstationID');       

        if (soapNS != null){
        soapNS = soapWS.Value__c;
        }
        if (xsiWS != null){
        xsi = xsiWS.Value__c;
        }

        xmlRequest = '<soap:Envelope xmlns="' + soapNS + '" xmlns:xsi="' + xsi + '" xmlns:soap="' + soapNS + '">\n';
        xmlRequest = xmlRequest + '<soap:Body>\n';
        if (serviceNameSpace == null){
        xmlRequest = xmlRequest + '<' + serviceNameElement + '>\n';
        }else {
        xmlRequest = xmlRequest + '<' + serviceNameElement + ' xmlns="' + serviceNamespace + '">\n';
        }
        if (xmlMessage.Element_Namespace__c == null){
        xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + '>\n';
        }else {
        xmlRequest = xmlRequest + '<' + xmlMessage.Element_Name__c + ' xmlns="' + xmlMessage.Element_Namespace__c + '">\n';
        }

        xmlRequest = xmlRequest + XMLMethods.buildHeader(messageType, inAccountId);
        xmlRequest = xmlRequest + '<AccountNo>' + inAccountId + '</AccountNo>';
        if (toDate != null)
        xmlRequest = xmlRequest + '<ToDate>' + toDate + '</ToDate>'; 
        if (fromDate != null)
            xmlRequest = xmlRequest + '<FromDate>' + fromDate + '</FromDate>';   
        xmlRequest = xmlRequest + '<SourceID>' + sourceID.Value__c + '</SourceID>';              
        xmlRequest = xmlRequest + '<WorkstationID>' + workstationID.Value__c + '</WorkstationID>';                             
        xmlRequest = xmlRequest + '</' + xmlMessage.Element_Name__c + '>\n';
        xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
        xmlRequest = xmlRequest + '</soap:Body>\n';
        xmlRequest = xmlRequest + '</soap:Envelope>\n';
        
         try {
            System.debug(loggingLevel.INFO,'*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            //Test code
            giSoap.timeout_x = 120000;
            giSoap.endpoint_x = endPoint.Value__c;
            //This is the line that calls the WebService
            if (!isTestRun){
                returnString = giSoap.BrokerInboundRequest(xmlRequest);
            } else {
                returnString = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><TransactionHistoryOrchResponse xmlns="http://www.islamic-bank.com/IBBWebServices"><IBBTransactionHistoryResult xmlns="http://www.islamic-bank.com/IBBWebServices/TransactionHistory/ToIBB"><TransactionDetails xmlns=""><DisplayOrder>1</DisplayOrder><TransactionName>Card Purchase</TransactionName><TransactionType>D</TransactionType><TransactionAmount>-1.080000</TransactionAmount><TransactionDate>2012-02-10</TransactionDate><TransactionValueDate>2012-02-10</TransactionValueDate><NarrativeLine1>GBP 1.08 DATE 09/02/12</NarrativeLine1><NarrativeLine2>TESCO STORE 5750</NarrativeLine2><NarrativeLine3>PRESTON GB</NarrativeLine3><NarrativeLine4 /><RunningBalance>23.390000</RunningBalance></TransactionDetails></IBBTransactionHistoryResult></TransactionHistoryOrchResponse></soap:Body></soap:Envelope> ';
            }
            System.debug(loggingLevel.INFO,'*** -- returnString From TransactionHistoryWebServiceClass:  -- ***');
            System.debug(loggingLevel.INFO,'*** -- ' + returnString + ' -- ***');
        
        }catch (CalloutException ce){
             return null;           
        }catch (Exception e){
             return null;           
        }
     
         
         if (returnString != null){   
             System.debug(loggingLevel.INFO,' ********** MAJA  ' + returnString)    ;                  
            
         String decodedString;
            try {
                decodedString = EncodingUtil.urlDecode(returnString, 'UTF-8');
               // System.debug(loggingLevel.INFO,'*** -- DECODED STRING -- ***');
               // System.debug(loggingLevel.INFO,'*** -- ' + decodedString + ' -- ***');
            }catch (Exception decodeEx){
                return null;
               // System.debug(loggingLevel.INFO,'*** -- Error in decoding string -- ***');
               // System.debug(loggingLevel.INFO,'*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
            }                      

        XmlStreamReader xsr = new XmlStreamReader(decodedString);

        //Check how many records we're processing
        integer transactionCount = 0;
        //Build map for xml data 
        Map<String,String> mapFieldsToValues = new Map<String,String>();

        TransactionHistoryItem item;
        String fieldName;
        String fieldValue;
        boolean firstTime = true;

          
        while (xsr.hasNext()){
 
            if (xsr.getEventType() == XmlTag.START_ELEMENT){

                if ('TransactionDetails'.equalsIgnoreCase(xsr.getLocalName())){
                    transactionCount ++;
                    if (!firstTime)
                        itemList.add(item); 
                     
                    firstTime = false; 
                    item = new TransactionHistoryItem();                                    
                } else {
                    fieldName = xsr.getLocalName(); 
                }
            } else if (xsr.isCharacters()){
             
                fieldValue = xsr.getText();
                mapFieldsToValues.put(fieldName.toUpperCase() + '_' + transactionCount, fieldValue); 
 
               if (fieldName == 'DISPLAYORDER'){         
                     item.itemDisplayOrder = Integer.ValueOf(fieldValue);             
                        if( item.itemDisplayOrder == 0){
                              dataToDisplay = false;
                              break;                        
                         } else {
                             dataToDisplay = true; 
                         }                   
               }    
   
               if (fieldName == 'TRANSACTIONDATE'){
                    item.itemPostingDate = fieldValue.substring(8,10) + '-' + fieldValue.substring(5,7) + '-' + fieldValue.substring(0,4);                          
                     //item.itemPostingDate = fieldValue.length().format(); 
               }
                if (fieldName == 'TRANSACTIONVALUEDATE'){
                    item.itemValueDate = fieldValue.substring(8,10) + '-' + fieldValue.substring(5,7) + '-' + fieldValue.substring(0,4);      
                    if (item.itemValueDate == item.itemPostingDate)
                        item.itemValueDate = '';    
               }                    
               if (fieldName == 'TRANSACTIONNAME'){
                    item.itemTranName = fieldValue;             
               }      
               if (fieldName == 'TRANSACTIONREFERENCE'){
                    item.itemRef = fieldValue;          
               }      
               if (fieldName == 'TRANSACTIONAMOUNT'){
                          
                    if (fieldValue.lastIndexOf('-') == -1){                   
                        item.itemCredit = Decimal.valueOf(fieldValue).setScale(2);
                        item.itemDisplayCredit = item.itemCredit.toPlainString();                       
                        //item.itemDisplayCredit = fieldValue.substring(0,fieldValue.length() - 4);                            
                    } else {
                        item.itemDebit = Decimal.valueOf(fieldValue).setScale(2);
                        item.itemDisplayDebit = item.itemDebit.toPlainString();                       
                    }          
               }   
               if (fieldName == 'RUNNINGBALANCE'){
                    item.itemRunningBalance = Double.valueOf(fieldValue);
                    item.itemDisplayRunningBalance = fieldValue.substring(0,fieldValue.length() - 4);          
               }  
               if (fieldName == 'NARRATIVELINE1'){
                    item.itemDesc = fieldValue;         
               } 
               if (fieldName == 'NARRATIVELINE2'){
                    item.itemDesc = item.itemDesc + '  ' + fieldValue;         
               } 
               if (fieldName == 'NARRATIVELINE3'){
                    item.itemDesc = item.itemDesc + '  ' + fieldValue;         
               } 
               if (fieldName == 'NARRATIVELINE4'){
                    item.itemDesc = item.itemDesc + '  ' + fieldValue;         
               }                                          
                                                                                                                              
               }    
        xsr.next();
               System.debug(loggingLevel.INFO,' ********** MAJA : Total Count ' + transactionCount )    ;     
               System.debug(loggingLevel.INFO,' ********** MAJA : END OF LOOP' );   
    } // while
               // Add the last one into the list
               if (dataToDisplay)  
                   itemList.add(item);
                               
 } // return string != null;                 
                  
               if (dataToDisplay){ 
                   // Sort the list by display order before return            
                   Map<integer,TransactionHistoryItem> sortMap = new Map<integer,TransactionHistoryItem>();                           
                   List<TransactionHistoryItem> sortedItemList = new TransactionHistoryItem[itemList.size()];       
                   for(TransactionHistoryItem itemToSort:itemList){             
                        sortMap.put(itemToSort.itemDisplayOrder - 1, itemToSort);
                   }  
               
                   for (integer i=0;i< itemList.size();i++){                   
                       sortedItemList.set(i, sortMap.get(i));                
                   }                 
                   return sortedItemList;
               } else {
                  return null;                   
               }
    }


}//