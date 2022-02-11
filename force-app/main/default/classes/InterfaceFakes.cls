@IsTest
public with sharing class InterfaceFakes {

    public class FakeCongaSettings implements Interfaces.ICongaSettings
    {
        public String Id {get;set;}
        
        public FakeCongaSettings()
        {
            Id = '';
        }
        
        public String GetAttachmentId()
        {
            return Id;
        }

        public String CallConga(String id)
        {
            return Id;
        }
        
        public String CallConga(String id, Boolean UsePortalUser)
        {
            return Id;
        }
    }

    
}