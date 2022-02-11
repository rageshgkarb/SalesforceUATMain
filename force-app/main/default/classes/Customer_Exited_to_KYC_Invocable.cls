/**********************************************************************************
Class Name: Customer_Exited_to_KYC_Invocable
Author: Raiyan
Created Date: 25-05-2021
Purpose: To send an email whenever the value is updated on customer profile from no true
        to true match and some value, this is invoked by process builder customer exited email to KYC team.

************************************************************************************/ 
public class Customer_Exited_to_KYC_Invocable{
    @InvocableMethod(label = 'CustomerExitedEmail')
    public static void CustomerExitedEmail(List<Account> AccountList){
        try{
            contact con = [SELECT id,email FROM contact WHERE name = 'KYC Team' LIMIT 1]; 
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(con.id); 
            message.setSenderDisplayName('FCU Team'); 
            message.setReplyTo('no-reply@alrayanbank.co.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Customer Exited to KYC'];
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(AccountList[0].Id); //This is important for the merge fields in template to work
            message.toAddresses = new String[] { con.email};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         
            if (results[0].success){
                System.debug('The email was sent successfully.');
            }else {
                System.debug('The email failed to send: '+  results[0].errors[0].message);
            }   
        }catch(exception e){
            system.debug('Exception occured while fetching contact'+e.getMessage());
        }
        
    }
}