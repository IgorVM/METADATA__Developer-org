public class AccountHandler {
    public static Account insertNewAccount(String incomingName){
        try{
            Account testAcc = new Account(Name=incomingName);
            insert testAcc;
            return testAcc;
        }
        catch(DmlException e){
            return null;
        }
    }
}
//ihjiklhnikoh