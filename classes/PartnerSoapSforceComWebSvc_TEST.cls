//Generated by FuseIT WSDL2Apex (http://www.fuseit.com/Solutions/SFDC-Explorer/Help-WSDL-Parser.aspx)
/** @author imorozov@forefrontcorp.com
  * @version 1.0
  * @description Test class for PartnerSoapSforceCom class
  *
  * PURPOSE
  *
  *     Purpose is to test PartnerSoapSforceCom class which is a class for salesforce partner SOAP API
  *
  * CHANGE LOG
  *
  *    [[Version; Date; Author; Description]]
  *    v1.0; 2017/04/20; imorozov@forefrontcorp.com; First Build
  *
  **/
@isTest
private class PartnerSoapSforceComWebSvc_TEST {
    
    @isTest static void coverGeneratedCodeTypes() {
        Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
        PartnerSoapSforceCom parentObject = new PartnerSoapSforceCom();
        new PartnerSoapSforceCom.CallOptions_element();
        new PartnerSoapSforceCom.GetUserInfoResult();
        new PartnerSoapSforceCom.login_element();
        new PartnerSoapSforceCom.loginResponse_element();
        new PartnerSoapSforceCom.LoginResult();
        new PartnerSoapSforceCom.LoginScopeHeader_element();
    }
    @isTest static void coverCodeForlogin(){
        Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
        PartnerSoapSforceCom.Soap testObject = new PartnerSoapSforceCom.Soap();
        System.assertEquals(null, testObject.login(null, null));
    }
}