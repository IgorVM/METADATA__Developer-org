public class ContactAndLeadSearch {
    public static List<List<SObject>> searchContactsAndLeads(String param){
        return [FIND :param RETURNING Contact(FirstName,LastName), Lead(FirstName,LastName)];
    }
}