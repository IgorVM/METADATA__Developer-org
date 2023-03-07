/** @author imorozov@forefrontcorp.com
  * @version 1.0
  * @description Test class for LoginAccessor class
  *
  * PURPOSE
  *
  *     Purpose is to test LoginAccessor class which is a class for webservices
  *
  * CHANGE LOG
  *
  *    [[Version; Date; Author; Description]]
  *    v1.0; 2016/12/05; imorozov@forefrontcorp.com; First Build
  *
  **/
@isTest
private class FFM_LoginAccessor_TEST {
	
	@isTest static void testGetPassword() {
		List<User> users = [Select Id From User Where Id != :UserInfo.getUserId() and IsActive=true];
		
		FFM_LoginTracker__c testLogin = new FFM_LoginTracker__c();
		testLogin.FFM_Username__c = 'testName';
		testLogin.FFM_Encrypted_Password__c = 'testPassword';
		testLogin.FFM_LoginType__c = 'Salesforce Sandbox';
		testLogin.Name = 'test';
		System.runAs(users[0]){
			insert testLogin;
		}

		Test.startTest();

		
		List<String> result = FFM_LoginAccessor.getPasswordService(testLogin.Id, 'Maestro');
		if(FFM_LoginAccessor.isUserFromAllowedGroup(UserInfo.getUserId())){
			System.assert(result[1] == testLogin.FFM_Encrypted_Password__c);	
		}
		else{
			System.assert(result[1] == '');

			insertGroup(UserInfo.getUserId());

			List<String> result2 = FFM_LoginAccessor.getPasswordService(testLogin.Id, 'Maestro');
			System.assert(result2[1] == testLogin.FFM_Encrypted_Password__c);
		}
		
		Test.stopTest();
	}

	private static void insertGroup(Id userId){
		List<Profile> p = [SELECT Id FROM Profile WHERE Name like '%Admin%'];
      	List<User> users = [Select Id From User Where ProfileId in :p and IsActive=true];
      	if(users.size() > 0){
	      	System.runAs(users[0]){

				List<Group> groups = [Select Id, DeveloperName From Group Where DeveloperName = 'FFM_Allow_Password'];

				Group testGroup = new Group();
				if(groups.size() > 0){
					testGroup = groups[0];
				}
				else{
					testGroup.Name = 'FFM_Allow_Password';
					testGroup.DeveloperName = 'FFM_Allow_Password';
					insert testGroup;
				}
				
				GroupMember gm = new GroupMember();
				gm.GroupId = testGroup.Id;
				gm.UserOrGroupId = userId;
				insert gm;

			}
		}
	}

	@isTest static void testUpdatePassword() {
		insertGroup(UserInfo.getUserId());
        
        Boolean settingsSet = FFM_LoginAccessor.checkSettingsValue();
        if(settingsSet == true){
            FFM_LoginAccessor.setSettingsValue();
        }

		Test.startTest();

		FFM_LoginTracker__c testLogin = new FFM_LoginTracker__c();
		testLogin.FFM_Username__c = 'testName';
		testLogin.FFM_Encrypted_Password__c = 'testPassword';
		testLogin.FFM_LoginType__c = 'Salesforce Sandbox';
		testLogin.Name = 'test';
		insert testLogin;
		String newPassword = '123';

		FFM_LoginAccessor.updatePasswordService(testLogin.Id, newPassword);
        System.debug('-->' + FFM_LoginAccessor.getPasswordService(testLogin.Id, 'Maestro')[1]);
		System.assert('123' == FFM_LoginAccessor.getPasswordService(testLogin.Id, 'Maestro')[1]);
		
		Test.stopTest();
	}

	@isTest static void testGetSessionIdSandbox(){
		Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
		List<String> result0 = FFM_LoginAccessor.getSessionId('123', '37.0');
		System.assert(result0 == null);
		
		FFM_LoginTracker__c testLogin1 = new FFM_LoginTracker__c();
		testLogin1.FFM_Username__c = 'someUsername';
		testLogin1.FFM_Encrypted_Password__c = 'somePassword';
		testLogin1.FFM_LoginType__c = 'Salesforce Sandbox';
		testLogin1.FFM_SecurityToken__c = 'someSecToken';
		testLogin1.Name = 'test';
		insert testLogin1;

		Test.startTest();

		Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
		List<String> result1 = FFM_LoginAccessor.getSessionId(testLogin1.Id, '37.0');
		System.assert(result1 == null);

		Test.stopTest();
	}

	@isTest static void testGetSessionIdProduction(){
		FFM_LoginTracker__c testLogin1 = new FFM_LoginTracker__c();
		testLogin1.FFM_Username__c = 'someUsername';
		testLogin1.FFM_Encrypted_Password__c = 'somePassword';
		testLogin1.FFM_LoginType__c = 'Salesforce Production';
		testLogin1.FFM_SecurityToken__c = 'someSecToken';
		testLogin1.Name = 'test';
		insert testLogin1;

		Test.startTest();

		Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
		List<String> result1 = FFM_LoginAccessor.getSessionId(testLogin1.Id, '37.0');
		System.assert(result1 == null);

		Test.stopTest();
	}

	@isTest static void testGetUserCanSeePassword(){
		Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
		User testUser = null;
		List<User> users = [SELECT Id, Name, IsActive FROM User WHERE IsActive=true];
		if(users.size() > 0){
			List<Group> groups = [Select Id, DeveloperName From Group Where DeveloperName = 'FFM_Allow_Password'];
			Group testGroup = new Group();
			if(groups.size() > 0){
				testGroup = groups[0];
			}
			else{
				testGroup.Name = 'FFM_Allow_Password';
				testGroup.DeveloperName = 'FFM_Allow_Password';
				insert testGroup;
			}

			Set<Id> usersFromGroup = FFM_LoginAccessor.GetUserIdsFromGroup(groups[0].Id);
			for(User u : users){
				if(!usersFromGroup.contains(u.Id)){
					testUser = u;
					break;
				}
			}

			Boolean result0 = FFM_LoginAccessor.getUserCanSeePassword(testUser.Id);
			System.assert(result0 == false);
			
			GroupMember gm = new GroupMember();
			gm.GroupId = testGroup.Id;
			gm.UserOrGroupId = testUser.Id;
			insert gm;

			Test.startTest();

			Test.setMock(WebServiceMock.class, new PartnerSoapSforceComMockImpl());
			Boolean result1 = FFM_LoginAccessor.getUserCanSeePassword(testUser.Id);
			System.assert(result1 == true);

			Test.stopTest();

		}
	}
}