global class CustomerImages
{

    private static String ImageType_Photo = 'Photo';
    
    /*
    @RemoteAction
    global static Teller_Integration_CustomerImage.ImageData GetImages(string customerId)
    {                    
       Teller_Integration_CustomerImage images = new Teller_Integration_CustomerImage ();
       return images.GetImages(customerId);
    }
    */

    public String CurrentImageId(String accountId)
    {
        String ImageId = getCurrentImageId(accountId, 'Photo');
        if (ImageId == null){
            ImageId = getLegacyImageId(accountId, 'Photo');
        }
        return ImageId;
    }
    
    public String CurrentSignatureId(String accountId)
    {
        String SignatureId = getCurrentImageId(accountId, 'Signature');
        if (SignatureId == null){
            SignatureId = getLegacyImageId(accountId, 'Signature');
        }
        return SignatureId;
    }
    
    public String CurrentImageURL(String accountId)
    {
        String ImageId = getCurrentImageId(accountId, 'Photo');
        system.debug('Image:'+ImageId );
        if (ImageId == null){
            ImageId = getLegacyImageId(accountId, 'Photo');
        }
        system.debug('Legacy Image:'+ImageId );
        return getImageURL(ImageId);
    }
    
    ////SAJ - Logic to get bulk customer images for accounts, to correct SOQL 101 error on account summary call
    public Map<String, String> CurrentImageURLs(List<String> accountIds)
    {
        Map<String, String> photos = getCurrentImageId(accountIds, 'Photo');
        List<String> legacyPhotoAccIds = new List<String>();
        
        for(String accountId : accountIds)
        {
            if(!photos.containsKey(accountId))
            {
                legacyPhotoAccIds.add(accountId);
            }
        }
        
        Map<String, String> legacyPhotos = null;
        if(legacyPhotoAccIds != null && legacyPhotoAccIds.size() > 0)
        {
            legacyPhotos = getLegacyImageId(legacyPhotoAccIds, 'Photo');
        }
        
        if(legacyPhotos != null)
        {
            photos.putAll(legacyPhotos);    
        }
        
        Map<String, String> result = new Map<String, String>();
        
        if(photos != null && photos.size() > 0)
        {
            for(String key : photos.keySet())
            {
                result.put(key, getImageURL(photos.get(key)));
            }
        }
        
        return result;
    }
    
    public String CurrentSignatureURL(String accountId)
    {
        String SignatureId = getCurrentImageId(accountId, 'Signature');
        system.debug('Signature:'+SignatureId);
        if (SignatureId == null){
            SignatureId = getLegacyImageId(accountId, 'Signature');
        }
        return getImageURL(SignatureId);
    }
    
    //SAJ - Logic to get bulk customer images for accounts, to correct SOQL 101 error on account summary call
    private Map<String, String> getCurrentImageId(List<String> accountIds, String ImageType)
    {
        String soql = '';
        Map<String, String> map_result = new Map<String, String>();
        
        for(String account : accountIds)
        {
            soql += '\'' + account + '\'' + ',';    
        }   
        
        if(soql != '')
        {
            soql = 'select Id, Name, Status__c, Image_Id__c, Image_Type__c, Current_Image__c, Account__r.Id from Customer_Image__c where Account__r.Id In (' + soql.removeEnd(',') + ') and Current_Image__c = true and Image_Type__c=' + '\'' + ImageType + '\'';
            List<Customer_Image__c> ci = Database.query(soql);
            
            if(ci.size() > 0)
            {
                for(Customer_Image__c item : ci)
                {
                    map_result.put(item.Account__r.Id, item.Image_Id__c);
                }
            }
        }
        
        return map_result;
    }
    
    private String getCurrentImageId(String accountId, String ImageType)
    {
        String returnId;
            
        // First need to get Current Image for Image Type
        List<Customer_Image__c> ci = [select Id, Name, Status__c, Image_Id__c, Image_Type__c, Current_Image__c
                                      from Customer_Image__c
                                      where Account__r.Id=:accountId and Current_Image__c = true and 
                                      Image_Type__c=:ImageType];
        
        if (ci.size() > 0){
            // Current Image found
            returnId = ci[0].Image_Id__c;
        }
        else{
            // Image not found
            returnId = null;
        }
        
        return returnId;
    }
    
    //SAJ - Logic to get bulk customer images for accounts, to correct SOQL 101 error on account summary call
    private Map<String, String> getLegacyImageId(List<String> accountIds, String ImageType)
    {
        String soql = '';
        Map<String, String> map_result = new Map<String, String>();
        
        for(String accountId : accountIds)
        {
            if (ImageType == 'Photo')
            {
                soql += '\'' + 'Image' + accountId + '\'' + ',';
            }
            else if (ImageType == 'Signature')
            {
                soql += '\'' + 'Signature' + accountId + '\'' + ',';
            }
        }   
        
        if(soql != '')
        {
            soql = 'select d.Id, d.Body, d.Name from Document d where d.Name in (' + soql.removeEnd(',') + ')';
        }
        
        List<Document> ci = Database.query(soql);
        
        if(ci.size() > 0)
        {
            for(Document item : ci)
            {
                String accountId = '';
                if (ImageType == 'Photo')
                {
                    accountId = item.Name.removeStart('Image');
                }
                else
                {
                    accountId = item.Name.removeStart(ImageType);
                }
                map_result.put(accountId, item.Id);
            }
        }
                
        return map_result;
    }
    
    private String getLegacyImageId(String accountId, String ImageType)
    {
        system.debug('getLegacyImageId Check:'+ImageType);
        String accDocName = '';
        String imageId = '';
        
        if (ImageType == 'Photo'){
            accDocName = 'Image' + accountId;
        }
        else if (ImageType == 'Signature'){
            accDocName = 'Signature' + accountId;
        }
        system.debug('getLegacyImageId Check:'+ImageType+'---'+accDocName);
        string soql = 'select Id, Body, Name  from Document d where Name = :accDocName';
        //List<Document> imgDocList = [select Id, Body, Name  from Document d where Name = :accDocName];
        system.debug('*****'+ [select Id, Body, Name  from Document d where Name = :accDocName].size());
        List<Document> imgDocList = new List<Document>();
        system.debug('getLegacyImageId'+imgDocList);
        if(imgDocList.size() > 0)
        {
            imageId = imgDocList[0].Id;
        }
        else
        {
            imageId = 'null';
        }
        return imageId;
    }
    
    private String getImageURL(String imageId)
    {
        return '"/servlet/servlet.FileDownload?file=' + imageId + '"';
    }
    
    //This gets called from Teller_CustomerDetailsController    
    public CustomerIdentityImages GetCustomerImages(String accountId)
    {
        System.debug('Starting GetCustomerImages');
        CustomerIdentityImages result = new CustomerIdentityImages();
        result.ImageURL = CurrentImageURL(accountId);
        System.debug('Images: ' + result.ImageURL);
        result.SignatureURL = CurrentSignatureURL(accountId);
        System.debug('Signature: ' + result.SignatureURL);
        
        //LB - disable calling EBA
        /*
        if((result.ImageURL.contains('file=null') || result.SignatureURL.contains('file=null')))
        {
            Map<String, String> ebaImages = getImageAndSignature(accountId);
            if(ebaImages != null && ebaImages.size() > 0)
            {   
                System.debug('EBA Images: ' + ebaImages);
                if(ebaImages.containsKey('Image') && result.ImageURL.contains('file=null'))
                {
                    result.ImageURL = 'data:image/jpg;base64,' + ebaImages.get('Image');
                }
                
                if(ebaImages.containsKey('Signature') && result.SignatureURL.contains('file=null'))
                {
                    result.SignatureURL = 'data:image/jpg;base64,' + ebaImages.get('Signature');
                }
            }
            
        }
        */
        
        return result;
        
    }   
    
    
    /* =============================================================================================================== */
    /* EBA Images Methods Start                                                                                        */
    /* =============================================================================================================== */
    
    //LB - i don't think this is being called, commented out for testing
    /*
    public Map<String, String> getImageAndSignature(String accountId){
        //TODO:  Need to provide a Web Log ID - how do we create it?
        String messageType = 'CustomerImages';
        String xmlMessageName = 'GetCustomerImages';
        String returnString;
        String xmlRequest;
        Map<String, String> result = new Map<String, String>();
        
        Account theAccount;
        List<Account> listAccounts = [select Id, EBS_ID__c from Account where Id = :accountId];
        if (listAccounts.size() > 0){
            theAccount = listAccounts[0];   
        }
        String ebsID = theAccount.EBS_ID__c;
        
        if (ebsID == null){
            returnString = 'NO EBS ACCOUNT FOUND';
            //return returnString;
            return result;
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
                            String tempImage = xsr.getText();
                            result.put('Image', tempImage);
                            System.debug('*** -- Image String = : ' + tempImage + ' -- ***');
                        }
                    }else if ('SIGNATURE'.equalsIgnoreCase(xsr.getLocalName())){
                        xsr.next();
                        if (xsr.isCharacters()){
                            String tempSignature = xsr.getText();
                            result.put('Signature', tempSignature);
                            System.debug('*** -- Signature String = : ' + tempSignature + ' -- ***');
                        }
                    }
                }
                xsr.next();
            }
        }       
   
        return result;
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
    
    */
    /* ============================================================================================================== */
    /* EBA Images Methods End                                                                                          */
    /* =============================================================================================================== */
    
    
    /* =============================================================================================================== */
    /* Trigger Methods Start                                                                                           */
    /* =============================================================================================================== */
    
    global static void AutomateSubmitApproval(Id id) 
    {
        Approval.ProcessSubmitRequest procReq;
        
        procReq = new Approval.ProcessSubmitRequest();
        
        procReq.setComments('Submitting Customer Image for approval');
        
        procReq.setObjectId(id);
        
        // Submit the record for approval
        Approval.ProcessResult result = Approval.Process(procReq);
    }

    global static void CustomerImageApproval(Customer_Image__c oldImage, Customer_Image__c newImage)
    {
        if ((newImage.Status__c == 'Approved') && (oldImage.Status__c != 'Approved'))
        {
            // Newly Approved Customer Image
            // need to update all Customer_Images.Current_Image__c of that Image_Type__c to false for that customer
            List<Customer_Image__c> customerImagesToUpdate = [select Id, Status__c, Current_Image__c, Image_Type__c from Customer_Image__c
                                                              where Image_Type__c = :newImage.Image_Type__c and Account__r.Id = :newImage.Account__c
                                                              and Id != :newImage.Id];
            
            for (Customer_Image__c ci : customerImagesToUpdate)
            {
                ci.Current_Image__c = false;
            }
            
            update(customerImagesToUpdate);

            // Update Newly Approved Image to be Current Image        
            newImage.Current_Image__c = true;
        }
    }

    public static void Customer_Image_Activity(List<Customer_Image__c> newCustomerImages, List<Customer_Image__c> oldCustomerImages, String dmlOperation)
    {
        system.debug('CustomerImages.Customer_Image_Activity Entry');
        system.debug('newCustomerImages: ' + newCustomerImages);
        system.debug('oldCustomerImages: ' + oldCustomerImages);
        system.debug('dmlOperation: ' + dmlOperation);

        List<Teller_TillTransactions.ActivityAudit> audits = new List<Teller_TillTransactions.ActivityAudit>();
        String branchNo = Teller_TillController.UsersCurrentBranchNo();
        String tillName = Teller_TillController.UsersCurrentTillName();

        for (Customer_Image__c image : newCustomerImages)
        {
            Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();

            audit.ActivityAmount = 0;
            audit.ActivityBlob = '';
            audit.ActivityCurrency = '';
            audit.ActivityDateTime = image.LastModifiedDate;
            audit.ActivityType = 'Customer Image';
            audit.DMLOperation = dmlOperation;
            audit.ObjectId = image.Id;
            audit.Status = image.Status__c;
            audit.BranchNo = branchNo;
            audit.TillName = tillName;

            if (dmlOperation == 'Insert')
            {
                audit.ActivityDescription = 'Inserted Image';
            }
            else if (dmlOperation == 'Update')
            {
                audit.ActivityDescription = 'Updated Image';
            }
            else
            {
                audit.ActivityDescription = 'Other Operation';
            }

            audits.add(audit);
        }

        for (Customer_Image__c image : oldCustomerImages)
        {
            if (dmlOperation == 'Delete')
            {
                Teller_TillTransactions.ActivityAudit audit = new Teller_TillTransactions.ActivityAudit();
                
                audit.ActivityAmount = 0;
                audit.ActivityBlob = '';
                audit.ActivityCurrency = '';
                audit.ActivityDateTime = image.LastModifiedDate;
                audit.ActivityDescription = 'Deleted Image';
                audit.ActivityType = 'Customer Image';
                audit.DMLOperation = dmlOperation;
                audit.ObjectId = image.Id;
                audit.Status = image.Status__c;
                audit.BranchNo = branchNo;
                audit.TillName = tillName;
 

                audits.add(audit);
            }
        }

        Teller_TillTransactions.SaveTellerActivityAuditRecord(audits);
    }

    /* =============================================================================================================== */
    /* Trigger Methods End                                                                                             */
    /* =============================================================================================================== */

    
    public class CustomerIdentityImages
    {
        public String ImageURL {get;Set;}
        public String SignatureURL {get;Set;}
    }
    
}