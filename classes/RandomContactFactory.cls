public class RandomContactFactory {
    public static List<Contact> generateRandomContacts(Integer count, String lastName){
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < count; i++){
            Contact contact = new Contact(
            	FirstName = 'name' + i,
                LastName = lastName
            	);
            contacts.add(contact);
        }
        System.debug('-->' + contacts);
        return contacts;
    }
}