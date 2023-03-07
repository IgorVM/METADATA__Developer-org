@isTest 
private class TestVerifyDate {
    @isTest static void TestCheckDates(){
        Date date1 = Date.newInstance(1960, 3, 17);
        Date date2 = date1.addDays(-1);
        //Test.startTest();
        Date result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(Date.newInstance(1960, 3, 31), result);
        date2 = date1.addDays(31);
        result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(Date.newInstance(1960, 3, 31), result);
        date2 = date1.addDays(20);
        result = VerifyDate.CheckDates(date1, date2);
        System.assertEquals(date2, result);
        //Test.stopTest();
    }
}