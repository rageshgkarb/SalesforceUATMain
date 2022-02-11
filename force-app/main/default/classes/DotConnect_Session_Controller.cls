/**
 * Created by lbrindle on 20/09/2018.
 */

public class DotConnect_Session_Controller {
    public PageReference Redirect(){
        String token = ApexPages.currentPage().getParameters().get('token');
        String successUrl = ApexPages.currentPage().getParameters().get('successUrl');
        String failureUrl = ApexPages.currentPage().getParameters().get('failureUrl');

        try {


            String sessionId = Caa_Helper.DecryptData(token);

            List<External_Session__c> sessions = [
                    Select Id, IP_Address__c, Account__c, Opportunity__c
                    From External_Session__c
                    Where Id = :sessionId and Is_Active__c = true
            ];

            system.debug('1');
            if (sessions.size() == 1) {
                system.debug('2');
                ApexPages.currentPage().setCookies(new Cookie[]{
                        CAA_Helper.CreateCookie(sessions[0])
                });
                system.debug('3');
                system.debug(successUrl);
                return new PageReference(successUrl);
            }

            system.debug('4');
            if (string.isNotBlank(failureUrl)) return new PageReference(failureUrl);
            system.debug('5');

        }catch(Exception e){
            return new PageReference(failureUrl);
        }


        return new PageReference(successUrl);
    }
}