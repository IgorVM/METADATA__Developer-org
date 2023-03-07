/*
* Controller to implement the auto-complete feature on the Visualforce page
*/
global with sharing class AutoCompleteController {
	
	// Instance fields
	public String searchTerm {get; set;}
	public String selectedMovie {get; set;}
	
	// Constructor
	public AutoCompleteController() {
		
	}
	
	// JS Remoting action called when searching for a movie name
    @RemoteAction
    global static List<Account> searchMovie(String searchTerm) {
        System.debug('Movie Name is: '+searchTerm );
        List<Account> movies = Database.query('Select Id, Name from Movie__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return movies;
    }
	
}