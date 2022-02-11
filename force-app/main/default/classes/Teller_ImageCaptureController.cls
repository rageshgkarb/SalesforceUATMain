public with sharing class Teller_ImageCaptureController {

    public String imageType { get; set; }
    public String imageBase64Binary { get; set; }

    private class ImageBlob {
        Blob Image;
    }
	
	public Boolean SaveImage(String ebsId, String imgType, String imgBase64Binary)
	{
		return SaveImageInternal(ebsId, imgType, imgBase64Binary);
	}
	
	private Boolean SaveImageInternal(String ebsId, String imgType, String imgBase64Binary)
	{
		 system.debug('Teller_ImageCaptureController.SaveImage Entry');
        
        if (!String.isBlank(imgBase64Binary))
        {	
            system.debug('EBSID: ' + ebsId);
            system.debug('imageType: ' + imgType);

			//Image Types
			//imageType = 'Photo';
			//imageType = 'Signature';

            List<Account> acc = [select Id from Account where EBS_ID__c=:ebsId];
			
            Customer_Image__c image = new Customer_Image__c(); // Create image object
            System.debug('Account Id: ' + acc.get(0).Id);
            
            image.Account__c = acc.get(0).Id;
            image.Added_By__c = UserInfo.getUserId();
            image.Added_Date__c = datetime.now();
            image.Status__c = 'Not Approved';
            image.Approved_By__c = null;
            image.Approved_Date__c = null;
            image.Image_Type__c = imgType;
            
            insert(image);  // insert Cosign_Image__c record           
            
            //String image64Text = imgBase64Binary;
             Blob imageBlobToSave = EncodingUtil.base64Decode(imgBase64Binary);
			
			//(ImageBlob) JSON.deserialize(image64Text, ImageBlob.class);
            
            Attachment imageAttachment = new Attachment();
                    imageAttachment.ParentId = image.Id;
                    imageAttachment.Name = 'myImage.png';
                    imageAttachment.Body = imageBlobToSave;
                    imageAttachment.contentType = 'image/png';
    
            insert(imageAttachment);        // insert Attachment image to new Cosign_Image__c record
            
            // Update image with Attachment Id
            image.Image_Id__c = imageAttachment.Id;
            update(image);
			
			return true;
        }
        return false;
	}

    public PageReference SaveImage() {
        system.debug('Teller_ImageCaptureController.SaveImage Entry');
        
        if (!String.isBlank(imageBase64Binary))
        {
            String EBSId = apexpages.currentpage().getparameters().get('EBSId');
            String imageType = apexpages.currentpage().getparameters().get('Photo');
            system.debug('EBSID: ' + EBSId);
            system.debug('imageType: ' + imageType);
            
            if (imageType == 'Y')
            {
                imageType = 'Photo';
            }
            else
            {
                imageType = 'Signature';
            }

            List<Account> acc = [select Id from Account where EBS_ID__c=:EBSId];
			
            Customer_Image__c image = new Customer_Image__c(); // Create image object
            System.debug('Account Id: ' + acc.get(0).Id);
            
            image.Account__c = acc.get(0).Id;
            image.Added_By__c = UserInfo.getUserId();
            image.Added_Date__c = datetime.now();
            image.Status__c = 'Not Approved';
            image.Approved_By__c = null;
            image.Approved_Date__c = null;
            image.Image_Type__c = imageType;
            
            insert(image);  // insert Cosign_Image__c record
            
            
            String image64Text = '{"Image":"' + imageBase64Binary + '"}';
            ImageBlob imageBlobToSave = (ImageBlob) JSON.deserialize(image64Text, ImageBlob.class);
            
            Attachment imageAttachment = new Attachment();
                    imageAttachment.ParentId = image.Id;
                    imageAttachment.Name = 'myImage.jpg';
                    imageAttachment.Body = imageBlobToSave.Image;
                    imageAttachment.contentType = 'image/jpeg';
    
            insert(imageAttachment);        // insert Attachment image to new Cosign_Image__c record
            
            // Update image with Attachment Id
            image.Image_Id__c = imageAttachment.Id;
            update(image);
        }
        return null;
    }
}