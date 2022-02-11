global class CustomerImageLoad
{

    public static List<ID> GetAccounts(integer numAccounts,string lastDigit)
    {
        lastDigit = '%' + lastDigit;
    
        List<account> accs = [select id from account 
                                where image_load__c = 'GetImage' and ebs_id__c != null 
                                and ebs_id__c like : lastDigit
                                limit :numAccounts];
                   
        List<ID> lst = new List<ID>();                        
        for(account a : accs)
        {
            lst.add(a.id);
        }
        return lst;      
    }
    
    
    
    
    public static String imageString{get;set;}
    public static String signatureString {get;set;}
    
    public static String getImageAndSignature(String accountId){
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
        
        system.debug(theAccount);
        
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
        String endPoint = 'https://www.ibb-bank.com/InboundBroker/GenericInboundBroker.asmx?op=BrokerInboundRequest';
        //String endPoint = 'https://80.194.71.201:80/GenericInboundBroker.asmx';
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
            giSoap.endpoint_x = endPoint;
            //This is the line that calls the WebService
            returnString = giSoap.BrokerInboundRequest(xmlRequest);
            System.debug('*** -- returnString From AccountPopupClass:  -- ***');
            System.debug('*** -- ' + returnString + ' -- ***');
        
        }catch (CalloutException ce){
            
        }catch (Exception e){
            
        }
       
        System.debug('returnString : ' + returnString);
        String messageStatus ;
        if (returnString != null)
          messageStatus = getStatusFromXML(returnString);
        
        System.debug('messageStatus : ' + messageStatus);
        
        if ('SUCCESS'.equalsIgnoreCase(messageStatus)){
            XmlStreamReader xsr = new XmlStreamReader(returnString);
            xsr.setCoalescing(true);
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
       
        System.debug('*** -- Image String = : ' + imageString + ' -- ***');
        System.debug('*** -- Signature String = : ' + signatureString + ' -- ***');
    
        return messageStatus;
    }
    
    public  static void getAccountAndSignatureImages(Id accountId)
    {
        System.debug('going to get Account Image');
        getImageAndSignature(accountId);
        Account acc = [select image_load__c from account where id=:accountId]; 
        // OVERWRITING WITH OWN IMAGE STRING
          
        System.debug('Account Image Base64 : ' + imageString);
        System.debug('Signature Image Base64 : ' + signatureString);
        
        if (imageString == null && signatureString == null){
                       acc.image_load__c = 'Tried to fetch';
                       update acc;
        
        
            return;
        }
        Blob accImageBlob = EncodingUtil.base64Decode(imageString);
        Blob sigImageBlob = EncodingUtil.base64Decode(signatureString);
        
        System.debug('*** -- accImageBlob = ' + accImageBlob + ' -- ***');
        System.debug('*** -- sigImageBlob = ' + sigImageBlob + ' -- ***');
        
        String accDocName = 'Image' + accountId;
        String sigDocName = 'Signature' + accountId;
        System.debug('*** -- accDocName = ' + accDocName + ' -- ***');
        System.debug('*** -- sigDocName = ' + sigDocName + ' -- ***');
        
        Document imgDoc = new Document();
        Document sigDoc = new Document();
        List<Document> imgDocList = [select d.Id, d.Body from Document d where d.Name = :accDocName];
        List<Document> sigDocList = [select d.Id, d.Body from Document d where d.Name = :sigDocName];
        List<Document> docsToInsert = new List<Document>();

        if (imgDocList.size() > 0)
        {
            System.debug('Document found for Account Image');
            
            //imgDoc = imgDocList[0];
            //imgDoc.Body = accImageBlob;
        }
        else 
        {
            System.debug('No Document found for Account Image');
        
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            
            if (fList.size() > 0)
            {
                f = fList[0];
            }
            
            imgDoc.Name = accDocName;
            imgDoc.Body = accImageBlob;
            if ( f!= null ) imgDoc.FolderId = f.Id;    
            imgDoc.Type = 'gif';
            imgDoc.ContentType = 'image/gif';
            docsToInsert.add(imgDoc);
        }
        
        System.debug('*** -- About to insert Account Image -- ***');
        
        
        if (sigDocList.size() > 0)
        {
            System.debug('Document found for Account Image');
            
            //sigDoc = sigDocList[0];
            //sigDoc.Body = sigImageBlob;
        }
        else 
        {
            System.debug('No Document found for Account Image');
        
            List<Folder> fList = [select Id, Name from Folder where Name = 'ImagesAndSignatures'];
            Folder f;
            
            if (fList.size() > 0)
            {
                f = fList[0];
            }
            
            sigDoc.Name = sigDocName;
            sigDoc.Body = sigImageBlob;
            if ( f!= null ) sigDoc.FolderId = f.Id;    
            sigDoc.Type = 'gif';
            sigDoc.ContentType = 'image/gif';
            
            System.debug('*** -- About to insert Signature Image -- ***');
        docsToInsert.add(sigDoc);
        }
        
        
       
        try 
        {
            if(docsToInsert.size() > 0)
            {
                upsert docsToInsert;
                System.debug('*** -- upserting Account Image & Signature Image documents successful -- ***');
            //accountImage = '/servlet/servlet.FileDownload?file=' + imgDoc.Id;
            //signatureImage = '/servlet/servlet.FileDownload?file=' + sigDoc.Id;
            //System.debug('## accountImage URL loaded from documents : ' + accountImage);
            //System.debug('## signatureImage URL loaded from documents : ' + signatureImage);
            }
            
            
            
            if(docsToInsert.size() >0 )
            {
                //update the account object
                acc.image_load__c = 'Loaded';                               
            }
            else
            {
                acc.image_load__c = 'Tried to fetch';
            }
            
            Trigger_Helper.TriggerItem item = new Trigger_Helper.TriggerItem();
item.Name = 'Account';
item.IgnoreTrigger = true;
item.IgnoreAudit = true;

Trigger_Helper.Items.add(item);
            
            
            
            update acc;
            
        }
        catch (Exception docE)
        {
            System.debug('*** -- Error upserting Account Image & Signature Image documents -- ***');
        }
    }
    
   
    
    public static String getStatusFromXML(String xmlString){
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
    
    
    
    
 
    
    
    
    @RemoteAction
    global static CAA_Data.GenericResponse ProcessAccount(ID accountId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        try
        {    
            getAccountAndSignatureImages(accountId);
            response.Success= signatureString != null && imageString != null;
        }
        catch(Exception ex)
        {
            response.Error = ex.GetMessage();            
        }
        
        
        return response;
    }
    

    @RemoteAction
    global static CAA_Data.GenericResponse GetAccountsToProcess(integer numAccounts, string lastDigit)
    {
       AccountListResponse response = new AccountListResponse ();
        try
        {                         
            //PROCESS REQUEST             
            response.Data = new AccountList(GetAccounts(numAccounts,lastDigit));
            
        }
        catch(Exception ex)
        {            
            response.Success = false;
            response.error = ex.getMessage();
            throw ex;
        }
        
        return response;
    }
    
 
    public class AccountListResponse extends CAA_Data.GenericResponse
    {
        public AccountList Data {get;set;}
    }
 
    public class AccountList
    {
        public AccountList(List<id> Items)
        {
            this.Items = Items;
        }
        
        public AccountList()
        {
            Items = new List<ID>();
        }
        
        
    
        List<ID> Items {get;set;}
    }
}