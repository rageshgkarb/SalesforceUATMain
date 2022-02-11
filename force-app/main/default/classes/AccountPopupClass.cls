/*
2012-01-25 jba/dm - fix code so it will test.
*/
public class AccountPopupClass {
    public String imageString {get; set;}
    public String signatureString {get; set;}
    public String loadingImage {get; set;}
    public String inAccountId {get; set;}
    
    public AccountPopupClass(String accountId){
        inAccountId = accountId;
        List<Document> loadingDocumentList = [select Id from Document where Name = 'LoadingImage'];
        if (loadingDocumentList.size() > 0){
            loadingImage = loadingDocumentList[0].Id;
        }
        
        getImageAndSignature(accountId);
    }
    
    public String getImageAndSignature(String accountId){
        //TODO:  Need to provide a Web Log ID - how do we create it?
        String messageType = 'CustomerImages';
        String xmlMessageName = 'GetCustomerImages';
        String returnString;
        String xmlRequest;

        Account theAccount;
        List<Account> listAccounts = [select Id, EBS_ID__c from Account where Id = :accountId];
        if (listAccounts.size() > 0){
            theAccount = listAccounts[0];   
        }
        String ebsID = theAccount.EBS_ID__c;
        
        if (ebsID == null){
            returnString = 'NO EBS ACCOUNT FOUND';
            return returnString;
        }
        Webservice_Setting__c ws = Webservice_Setting__c.getValues('HTTP Request Timeout');
        Integer httpTimeout = 30000;
        if (ws != null){
            httpTimeout = Integer.valueOf(ws.Value__c);
        }
        
        ws = Webservice_Setting__c.getValues('Webservice Endpoint'); 
        String endPoint = 'http://80.194.71.201:80/GenericInboundBroker.asmx';
        if (ws != null){
            endPoint = ws.Value__c;
        }
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

        System.debug('*** --Service Name Element: ' + serviceNameElement + '-- ***');
        System.debug('*** -- serviceNamespace: ' + serviceNamespace + '-- ***');

        Webservice_Setting__c soapWS = Webservice_Setting__c.getValues('HTTP Soap NS');
        Webservice_Setting__c xsiWS = Webservice_Setting__c.getValues('HTTP xsi');

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

        xmlRequest = xmlRequest + XMLMethods.buildHeader(messageType, accountId);
        xmlRequest = xmlRequest + '<CustomerID>' + ebsID + '</CustomerID>';
        xmlRequest = xmlRequest + '</' + xmlMessage.Element_Name__c + '>\n';
        xmlRequest = xmlRequest + '</' + serviceNameElement + '>\n';
        xmlRequest = xmlRequest + '</soap:Body>\n';
        xmlRequest = xmlRequest + '</soap:Envelope>\n';
        
         try {
            System.debug('*** -- About to send request... -- ***');
            tempuriOrg.GenericInboundBrokerSoap giSoap = new tempuriOrg.GenericInboundBrokerSoap();
            giSoap.timeout_x = httpTimeout;
            //Test code
            giSoap.timeout_x = 120000;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            System.debug('*** -- returnString From AccountPopupClass:  -- ***');
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }catch (CalloutException ce){
            
        }catch (Exception e){
            
        }
       
        System.debug('returnString : ' + returnString);
        
        String messageStatus = getStatusFromXML(returnString);
        
        System.debug('messageStatus : ' + messageStatus);
        
        if ('SUCCESS'.equalsIgnoreCase(messageStatus)){
            XmlStreamReader xsr = new XmlStreamReader(returnString);
            while (xsr.hasNext()){
                if (xsr.getEventType() == XmlTag.START_ELEMENT){
                    if ('IMAGE'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            imageString = xsr.getText();
                        }
                    }else if ('SIGNATURE'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            signatureString = xsr.getText();
                        }
                    }
                }
                xsr.next();
            }
        }
       
        //Test Code
        /*
        Blob imageBlob = EncodingUtil.base64Decode(imageString);
        String docName = 'Image' + accountId;
        Document doc = new Document();
        List<Document> docList = [select d.Id, d.Body from Document d where d.Name = :docName];
        if (docList.size() > 0){
            doc = docList[0];
            doc.Body = imageBlob;
        }else {
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            if (fList.size() > 0){
                f = fList[0];
            }
            doc.Name = docName;
            doc.Body = imageBlob;
            doc.FolderId = f.Id;    
        }
        
        try {
            upsert doc;
        }catch (Exception docE){
            System.debug('*** -- Error upserting document -- ***');
            return 'FAILED';
        }
        */
        System.debug('*** -- Image String = : ' + imageString + ' -- ***');
        System.debug('*** -- Signature String = : ' + signatureString + ' -- ***');
        
        return messageStatus;
    }
    
    public String storeImageInDoc(String imageString){
        System.debug('*** -- Into storeImageInDoc -- ***');
        Blob imageBlob = EncodingUtil.base64Decode(imageString);
        String docName = 'Image' + inAccountId;
        System.debug('*** -- docName = ' + docName + ' -- ***');
        Document doc = new Document();
        List<Document> docList = [select d.Id, d.Body from Document d where d.Name = :docName];
        if (docList.size() > 0){
            doc = docList[0];
            doc.Body = imageBlob;
        }else {
            doc.Name = docName;
            doc.Body = imageBlob;
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            if (fList.size() > 0){
                doc.FolderId = fList[0].Id;
            }   
        }
        System.debug('*** -- About to insert -- ***');
        try {
            upsert doc;
        }catch (Exception docE){
            System.debug('*** -- Error upserting document -- ***');
            return 'FAILED';
        }
        return doc.Id;
    }
    
    public static String getStatusFromXML(String xmlString){
        if ( xmlString == null ) return null;
        
        String statusCode;
        String statusMessage;
        XmlStreamReader xsr = new XmlStreamReader(xmlString);
        while (xsr.hasNext()){
            if (xsr.getEventType() == XmlTag.START_ELEMENT){
                if ('StatusCode'.equalsIgnoreCase(xsr.getLocalName())){
                    xsr.next();
                    if (xsr.isCharacters()){
                        statusCode = xsr.getText();
                    }
                }
            }
            xsr.next();
        }
        if (statusCode == '5'){
            statusMessage = 'BUFFERED';
        }else if (statusCode == '7'){
            statusMessage = 'FAILED';
        }else {
            statusMessage = 'SUCCESS';
        }
        return statusMessage;
    }
}