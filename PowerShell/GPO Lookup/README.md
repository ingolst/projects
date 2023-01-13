Basic GPO lookup script to search for group policy objects using a keyword on the server that your group policy objects are located.

Uses Get-GPO to fetch all GPOs in your domain and uses a for loop to return all entries that match the given keyword.