@IsTest
public class z_XmlMessage2
{
    public static void CreateProductSwitchMessage()
    {
        XML_Message__c message = new XML_Message__c();
        message.name='ProductSwitch';
        message.Active__c=true;
        message.Element_Name__c='HPPProductSwitch';
        message.Service_Name_Element__c='HPPProductSwitch';
        message.Service_Namespace__c='http://www.islamic-bank.com/HPPProductSwitch';
        message.Type__c='Request';
        insert message;

        List<XML_Message_tag__c> tags = new List<XML_Message_tag__c>();
        
        Xml_Message_tag__c tag0 = New Xml_Message_tag__c ();
        tag0.name = 'AcctNo';
        tag0.Data_Type__c = 'String';
        tag0.Field_API_Name__c = 'EBS_ID__c';
        tag0.Field_Label__c = 'EBS ID';
        tag0.Message_Order__c = 1;
        tag0.XML_Message__c = message.id;
        tags.add(tag0);
        
        Xml_Message_tag__c tag1 = New Xml_Message_tag__c ();
        tag1.name = 'ProductSwitchTo';
        tag1.Data_Type__c = 'String';
        tag1.Field_API_Name__c = 'EBS_ID__c';
        tag1.Field_Label__c = 'EBS ID';
        tag1.Message_Order__c = 2;
        tag1.XML_Message__c = message.id;
        tags.add(tag1);
        
        Xml_Message_tag__c tag2 = New Xml_Message_tag__c ();
        tag2.name = 'EBSUserID';
        tag2.Data_Type__c = 'String';
        tag2.Field_API_Name__c = 'EBS_ID__c';
        tag2.Field_Label__c = 'EBS ID';
        tag2.Message_Order__c = 3;
        tag2.XML_Message__c = message.id;
        tags.add(tag2);
        
        Xml_Message_tag__c tag3 = New Xml_Message_tag__c ();
        tag3.name = 'Spare1';
        tag3.Data_Type__c = 'String';
        tag3.Field_API_Name__c = 'EBS_ID__c';
        tag3.Field_Label__c = 'EBS ID';
        tag3.Message_Order__c = 4;
        tag3.XML_Message__c = message.id;
        tags.add(tag3);
        
        Xml_Message_tag__c tag4 = New Xml_Message_tag__c ();
        tag4.name = 'Spare2';
        tag4.Data_Type__c = 'String';
        tag4.Field_API_Name__c = 'EBS_ID__c';
        tag4.Field_Label__c = 'EBS ID';
        tag4.Message_Order__c = 5;
        tag4.XML_Message__c = message.id;
        tags.add(tag4);
        
        Xml_Message_tag__c tag5 = New Xml_Message_tag__c ();
        tag5.name = 'Spare3';
        tag5.Data_Type__c = 'String';
        tag5.Field_API_Name__c = 'EBS_ID__c';
        tag5.Field_Label__c = 'EBS ID';
        tag5.Message_Order__c = 6;
        tag5.XML_Message__c = message.id;
        tags.add(tag5);
        
        Xml_Message_tag__c tag6 = New Xml_Message_tag__c ();
        tag6.name = 'Spare4';
        tag6.Data_Type__c = 'String';
        tag6.Field_API_Name__c = 'EBS_ID__c';
        tag6.Field_Label__c = 'EBS ID';
        tag6.Message_Order__c = 7;
        tag6.XML_Message__c = message.id;
        tags.add(tag6);
        
        Xml_Message_tag__c tag7 = New Xml_Message_tag__c ();
        tag7.name = 'Spare5';
        tag7.Data_Type__c = 'String';
        tag7.Field_API_Name__c = 'EBS_ID__c';
        tag7.Field_Label__c = 'EBS ID';
        tag7.Message_Order__c = 8;
        tag7.XML_Message__c = message.id;
        tags.add(tag7);
        
        Xml_Message_tag__c tag8 = New Xml_Message_tag__c ();
        tag8.name = 'ProductSwitchStartDate';
        tag8.Data_Type__c = 'String';
        tag8.Field_API_Name__c = 'EBS_ID__c';
        tag8.Field_Label__c = 'EBS ID';
        tag8.Message_Order__c = 9;
        tag8.XML_Message__c = message.id;
        tags.add(tag8);
        
        
        
        insert tags;
    }
}