/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class partnerSoapSforceCom_Test {

    static testMethod void myUnitTest() {
        partnerSoapSforceCom p = new partnerSoapSforceCom ();
        
       partnerSoapSforceCom.GetUserInfoResult s = new partnerSoapSforceCom.GetUserInfoResult ();
       partnerSoapSforceCom.login_element s1 = new partnerSoapSforceCom.login_element ();
       partnerSoapSforceCom.logout_element s2 = new partnerSoapSforceCom.logout_element ();
       partnerSoapSforceCom.ResetPasswordResult s3 = new partnerSoapSforceCom.ResetPasswordResult ();
       partnerSoapSforceCom.ProcessResult  s4 = new partnerSoapSforceCom.ProcessResult  ();
       partnerSoapSforceCom.LoginResult  s5 = new partnerSoapSforceCom.LoginResult  ();
       partnerSoapSforceCom.loginResponse_element s6 = new partnerSoapSforceCom.loginResponse_element ();
       
       partnerSoapSforceCom.CallOptions_element s7 = new partnerSoapSforceCom.CallOptions_element ();
       partnerSoapSforceCom.CallOptions_element s8 = new partnerSoapSforceCom.CallOptions_element ();
       partnerSoapSforceCom.processResponse_element s9 = new partnerSoapSforceCom.processResponse_element ();
       partnerSoapSforceCom.Soap  s10 = new partnerSoapSforceCom.Soap  ();
       
       
        partnerSoapSforceCom.getUserInfo_element l1 = new partnerSoapSforceCom.getUserInfo_element();
       
       
       
       
       
       
       partnerSoapSforceCom.loginResponse_element s11 = new partnerSoapSforceCom.loginResponse_element ();
       
       partnerSoapSforceCom.resetPasswordResponse_element s12 = new partnerSoapSforceCom.resetPasswordResponse_element ();
       partnerSoapSforceCom.DebuggingHeader_element s13 = new partnerSoapSforceCom.DebuggingHeader_element ();
       partnerSoapSforceCom.SetPasswordResult  s14 = new partnerSoapSforceCom.SetPasswordResult  ();
       partnerSoapSforceCom.Error   s15 = new partnerSoapSforceCom.Error   ();
       partnerSoapSforceCom.InvalidateSessionsResult  s16 = new partnerSoapSforceCom.InvalidateSessionsResult  ();
       partnerSoapSforceCom.logoutResponse_element s17 = new partnerSoapSforceCom.logoutResponse_element ();
       partnerSoapSforceCom.invalidateSessions_element s18 = new partnerSoapSforceCom.invalidateSessions_element ();
       partnerSoapSforceCom.LoginScopeHeader_element  s19 = new partnerSoapSforceCom.LoginScopeHeader_element  ();
       partnerSoapSforceCom.invalidateSessionsResponse_element   s20 = new partnerSoapSforceCom.invalidateSessionsResponse_element   ();
       partnerSoapSforceCom.invalidateSessionsResponse_element  s21 = new partnerSoapSforceCom.invalidateSessionsResponse_element  ();
             
       partnerSoapSforceCom.SessionHeader_element ss = new partnerSoapSforceCom.SessionHeader_element();
             
                
       // GetUserInfoResult info = new GetUserInfoResult ();
        
        
        
    }
}