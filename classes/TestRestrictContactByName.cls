@isTest
private class TestRestrictContactByName {
    @isTest static void TestTrigger(){
        Contact contact = new Contact(
            FirstName = '123',
            LastName = 'INVALIDNAME');
        Test.startTest();
        Database.SaveResult result = null;
        try{
        	result = Database.insert(contact);
            System.assertEquals(false, result.isSuccess());
        }
        catch(DMLException e){
            System.assert(e.getMessage() != '' && e.getMessage() != null);
        }
        Test.stopTest();
    }

}