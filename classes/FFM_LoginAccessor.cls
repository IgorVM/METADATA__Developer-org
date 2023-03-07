/**
  * @author imorozov@forefrontcorp.com
  * @version 1.0
  * @description Class for webservices
  *
  * PURPOSE
  *
  *     Class to store webservices and procedures
  *
  * TEST CLASS
  *
  *     FFM_LoginAccessor_TEST
  *
  * ENTRY POINTS
  *
  *     From pages or other classes
  *
  * CHANGE LOG
  *
  *    [[Version; Date; Author; Description]]
  *    v1.0; 2016/12/05; imorozov@forefrontcorp.com; First Build
  **/
global class FFM_LoginAccessor {

	// web service for getting password by login id
	webservice static List<String> getPasswordService(String loginId, String application){
		Id currentUser = UserInfo.getUserId();
		FF_Maestro_Test__FFM_LoginTracker__c login = getLoginInfo(loginId);
		if(isUserFromAllowedGroup(currentUser) || (login != null && currentUser == login.OwnerId)){
			return new List<String> { 'true', getPassword(loginId, application)};
		}
		else{
			if(application == 'Salesforce' && (login.FF_Maestro_Test__FFM_LoginType__c == 'Salesforce Production' || login.FF_Maestro_Test__FFM_LoginType__c == 'Salesforce Sandbox')){
				return new List<String> {'false', 'Please use Maestro to access this login'};
			}
			if(application == 'Salesforce' && login.FF_Maestro_Test__FFM_LoginType__c != 'Salesforce Production' && login.FF_Maestro_Test__FFM_LoginType__c != 'Salesforce Sandbox'){
				return new List<String> {'false', 'Your account does not have access to this record, please contact the record owner'};
			}
			return new List<String> {'false', ''};
		}
	}

	//method for getting owner id of the login record
	private static FF_Maestro_Test__FFM_LoginTracker__c getLoginInfo(String loginId){
		String [] loginTrackerFields = new String [] {'Id', 'OwnerId', 'FF_Maestro_Test__FFM_LoginType__c'};
	    Map<String,Schema.SObjectField> m = Schema.SObjectType.FF_Maestro_Test__FFM_LoginTracker__c.fields.getMap();
	      for (String fieldToCheck : loginTrackerFields) {
	        // Check if the user has create access on the each field
	        if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
	    		return null;
	        }
	    }
		List<FF_Maestro_Test__FFM_LoginTracker__c> loginTrackers = [Select l.Id, l.OwnerId, l.FF_Maestro_Test__FFM_LoginType__c from FF_Maestro_Test__FFM_LoginTracker__c l where l.Id = :loginId];
		if(loginTrackers.size() > 0){
			return loginTrackers[0];
		}
		return null;
	}

	// method which creates login audit record and then retrieves login's password
	private static String getPassword(String loginId, String application){
		String loginAuditId = createLoginAuditRecord(loginId, 'Read', application);
		if(loginAuditId != '')
		{	
			return retrievePassword(loginId);
		}
		return '';
	}

	// method for creating login audit record by login id and action
	private static String createLoginAuditRecord(String loginId, String action, String application){
		String [] loginAuditFields = new String [] {'FF_Maestro_Test__Action_Type__c',
	                                                     'FF_Maestro_Test__Login__c',
	                                                     'FF_Maestro_Test__User__c',
	                                                     'FF_Maestro_Test__Application__c'};
	    Map<String,Schema.SObjectField> m = Schema.SObjectType.FF_Maestro_Test__FFM_Login_Audit__c.fields.getMap();
	      for (String fieldToCheck : loginAuditFields) {
              System.debug('fieldToCheck ->' + fieldToCheck);
              System.debug('m.get(fieldToCheck).getDescribe().isCreateable() ->' + m.get(fieldToCheck).getDescribe().isCreateable());
	        // Check if the user has create access on the each field
	        if (!m.get(fieldToCheck).getDescribe().isCreateable()) {
	    		return null;
	        }
	    }
		FF_Maestro_Test__FFM_Login_Audit__c loginAudit = new FF_Maestro_Test__FFM_Login_Audit__c();
		loginAudit.FF_Maestro_Test__Action_Type__c = action;
		loginAudit.FF_Maestro_Test__Login__c = loginId;
		loginAudit.FF_Maestro_Test__User__c = UserInfo.getUserId();
		loginAudit.FF_Maestro_Test__Application__c = application;
		insert loginAudit;
		return loginAudit.Id;
	}

	// method for retrieving login's password by login id
	private static String retrievePassword(String loginId){
		String [] loginTrackerFields = new String [] {'Id', 'FF_Maestro_Test__FFM_Encrypted_Password__c'};
	    Map<String,Schema.SObjectField> m = Schema.SObjectType.FF_Maestro_Test__FFM_LoginTracker__c.fields.getMap();
	      for (String fieldToCheck : loginTrackerFields) {
	        // Check if the user has create access on the each field
	        if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
	    		return '';
	        }
	    }
		List<FF_Maestro_Test__FFM_LoginTracker__c> loginTrackers = [Select l.Id, l.FF_Maestro_Test__FFM_Encrypted_Password__c from FF_Maestro_Test__FFM_LoginTracker__c l where l.Id = :loginId];
		if(loginTrackers.size() > 0){
			return decrypt(loginTrackers[0].FF_Maestro_Test__FFM_Encrypted_Password__c);
		}
		return '';
	}

	// web service for identifying if user has update access for login record by login id
	webservice static Boolean userCanUpdatePassword(String loginId){
		Id currentUser = UserInfo.getUserId();
		FF_Maestro_Test__FFM_LoginTracker__c login = getLoginInfo(loginId);
		if(isUserFromAllowedGroup(currentUser) || (login != null && currentUser == login.OwnerId)){
			String [] userRecordAccessFields = new String [] {'RecordId',
		                                                     'HasEditAccess',
		                                                     'UserId'};
		    Map<String,Schema.SObjectField> m = Schema.SObjectType.UserRecordAccess.fields.getMap();
		      for (String fieldToCheck : userRecordAccessFields) {
		        // Check if the user has create access on the each field
		        if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
		    		return false;
		        }
		    }
			List<UserRecordAccess> listUserRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :loginId];
			if(listUserRecordAccess.size() > 0){
				return listUserRecordAccess[0].HasEditAccess;
			}
		}
		else{
			return false;
		}
		return false;
	}

	// web service for updating password and creating login audit record for this action
	webservice static void updatePasswordService(String loginId, String newPassword){
		Id currentUser = UserInfo.getUserId();
		FF_Maestro_Test__FFM_LoginTracker__c login = getLoginInfo(loginId);
		if(isUserFromAllowedGroup(currentUser) || (login != null && currentUser == login.OwnerId)){
			Boolean userHasEditPermissions = userCanUpdatePassword(loginId);
			if(loginId != '' && newPassword != '' && userHasEditPermissions){
				String loginAuditId = createLoginAuditRecord(loginId, 'Update', 'Salesforce');
				String [] loginTrackerFields = new String [] {'Id',
		                                                     'FF_Maestro_Test__FFM_Encrypted_Password__c'};
			    Map<String,Schema.SObjectField> m = Schema.SObjectType.FF_Maestro_Test__FFM_LoginTracker__c.fields.getMap();
			      for (String fieldToCheck : loginTrackerFields) {
			        // Check if the user has create access on the each field
			        if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
			    		return;
			        }
			    }
				FF_Maestro_Test__FFM_LoginTracker__c loginWithPassword = [Select Id, FF_Maestro_Test__FFM_Encrypted_Password__c From FF_Maestro_Test__FFM_LoginTracker__c Where Id = :loginId];
				loginWithPassword.FF_Maestro_Test__FFM_Encrypted_Password__c = encrypt(newPassword);
				update loginWithPassword;
			}
		}
	}

	//get session id by using login method from SOAP partner API
	webservice static List<String> getSessionId(String loginId, String apiVersion){
		String [] loginTrackerFields = new String [] {'Id', 'FF_Maestro_Test__FFM_Encrypted_Password__c', 'FF_Maestro_Test__FFM_Username__c', 'FF_Maestro_Test__FFM_SecurityToken__c', 'FF_Maestro_Test__FFM_LoginType__c'};
	    Map<String,Schema.SObjectField> m = Schema.SObjectType.FF_Maestro_Test__FFM_LoginTracker__c.fields.getMap();
	      for (String fieldToCheck : loginTrackerFields) {
	        // Check if the user has create access on the each field
	        if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
	    		return null;
	        }
	    }
    
		List<FF_Maestro_Test__FFM_LoginTracker__c> loginTrackers = [Select l.Id, FF_Maestro_Test__FFM_Username__c, FF_Maestro_Test__FFM_SecurityToken__c, FF_Maestro_Test__FFM_LoginType__c, l.FF_Maestro_Test__FFM_Encrypted_Password__c from FF_Maestro_Test__FFM_LoginTracker__c l where l.Id = :loginId];
		
		if(loginTrackers.size() > 0){
			string userName = loginTrackers[0].FF_Maestro_Test__FFM_Username__c;
			string securityToken = loginTrackers[0].FF_Maestro_Test__FFM_SecurityToken__c;
			string password = decrypt(loginTrackers[0].FF_Maestro_Test__FFM_Encrypted_Password__c);
			Boolean isSandbox = loginTrackers[0].FF_Maestro_Test__FFM_LoginType__c == 'Salesforce Sandbox';
            string strEndpoint = '';
            if (isSandbox)
            {
            	strEndpoint = 'https://test.salesforce.com/services/Soap/u/' + apiVersion;
            }
            else
            {
            	strEndpoint = 'https://login.salesforce.com/services/Soap/u/' + apiVersion;
            }
            PartnerSoapSforceCom.Soap psc = new PartnerSoapSforceCom.Soap();
            psc.endPoint_x = strEndpoint;
            PartnerSoapSforceCom.LoginResult lr = null;
            
            try{
            	lr = psc.login(userName, password);
        	}
        	catch(Exception ex){
        		lr = psc.login(userName, password + securityToken);
        	}
        	String loginAuditId = createLoginAuditRecord(loginId, 'Read', 'Web Service');
        	if(loginAuditId != ''){
            	return lr == null ? null : new List<String>{ lr.sessionId, lr.serverUrl, lr.metadataServerUrl, string.valueOf(lr.passwordExpired) };
            }
            else{
            	return null;
            }
		}
		return null;
	}


	// web service for finding out if user is in the public group for seeing passwords in Maestro
	webservice static Boolean getUserCanSeePassword(String userId){
		return isUserFromAllowedGroup(userId);
	}

	public static Boolean isUserFromAllowedGroup(Id userId){
		String [] groupFields = new String [] {'Id', 'DeveloperName', 'Type'};
	    Map<String,Schema.SObjectField> m = Schema.SObjectType.Group.fields.getMap();
	      for (String fieldToCheck : groupFields) {
	        // Check if the user has create access on the each field
	        if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
	    		return null;
	        }
	    }
        List<Group> groups = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular' AND DeveloperName = 'FFM_Allow_Password'];
        if(groups.size() > 0){
            Set<Id> usersFromGroup = GetUserIdsFromGroup(groups[0].Id);
            if(usersFromGroup.contains(userId))
                return true;
            else
                return false;
        }
        return false;
    }
    
    //check if everyting is set up
    webservice static Boolean checkSettingsValue(){
        try{
            FF_Maestro_Test__FFM_Encryption__c setting = FF_Maestro_Test__FFM_Encryption__c.getOrgDefaults();
            return setting.FF_Maestro_Test__FFM_Encryption_Key__c == null || setting.FF_Maestro_Test__FFM_Encryption_Key__c == '';
        }
        catch(Exception ex){
            return null;
        }
    }
    
    //set encryption key and create public group
    webservice static String setSettingsValue(){
        try{
            FF_Maestro_Test__FFM_Encryption__c setting = FF_Maestro_Test__FFM_Encryption__c.getOrgDefaults();
            if(setting.FF_Maestro_Test__FFM_Encryption_Key__c == null || setting.FF_Maestro_Test__FFM_Encryption_Key__c == ''){
                Blob key = Crypto.generateAesKey(256);
                setting.FF_Maestro_Test__FFM_Encryption_Key__c = EncodingUtil.base64Encode(key);
                upsert setting;
                //create public group
                List<Group> groups = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Regular' AND DeveloperName = 'FFM_Allow_Password'];
                if(groups.size() == 0){
                    Group testGroup = new Group();
                    testGroup.Name = 'FFM_Allow_Password';
                    testGroup.DeveloperName = 'FFM_Allow_Password';
                    insert testGroup;
                }
                return 'Completed!';
            }
            return 'Everything is set up already';
        }
        catch(Exception ex){
            return ex.getMessage();
        }
    }

    //encrypt something by using AES256
    private static String encrypt(string textForEncryption){
    	try{
            FF_Maestro_Test__FFM_Encryption__c encryptionSettings = FF_Maestro_Test__FFM_Encryption__c.getOrgDefaults();
            string ecryptionKey = encryptionSettings.FF_Maestro_Test__FFM_Encryption_Key__c;
            Blob blobKey = EncodingUtil.base64Decode(ecryptionKey);
            Blob data = Blob.valueOf(textForEncryption);
        
            Blob encrypted = Crypto.encryptWithManagedIV('AES256', blobKey, data);
            return EncodingUtil.base64Encode(encrypted);
        }
        catch(Exception e){
           	return '';
        }
    }

    //decrypt something by using AES256
    private static String decrypt(string textForDecryption){
        try{
            FF_Maestro_Test__FFM_Encryption__c encryptionSettings = FF_Maestro_Test__FFM_Encryption__c.getOrgDefaults();
            string ecryptionKey = encryptionSettings.FF_Maestro_Test__FFM_Encryption_Key__c;
            Blob blobKey = EncodingUtil.base64Decode(ecryptionKey);
            Blob data = EncodingUtil.base64Decode(textForDecryption);
        
            Blob decrypted = Crypto.decryptWithManagedIV('AES256', blobKey, data);
            return decrypted.toString();
        }
        catch(Exception e){
            return textForDecryption;
        }
    }

    public static Set<id> GetUserIdsFromGroup(Id groupId)
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result = new Set<Id>();
        List<GroupMember> groupMembers = [Select Id, UserOrGroupId, GroupId From GroupMember];
        result = GetUserIdsFromGroupRecursive(groupId, groupMembers);

        return result;  
    }

    private static Set<id> GetUserIdsFromGroupRecursive(Id groupId, List<GroupMember> groupMembers)
    {
        // store the results in a set so we don't get duplicates
        Set<Id> result = new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        List<GroupMember> groupMembersForGroupId = new List<GroupMember>();
        for(GroupMember m : groupMembers){
            if(m.GroupId == groupId){
                groupMembersForGroupId.add(m);
            }
        }

        // Loop through all group members in a group
        for (GroupMember m : groupMembersForGroupId)
        {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                result.addAll(GetUserIdsFromGroupRecursive(m.UserOrGroupId, groupMembers));
            }
        }

        return result;
    }
}