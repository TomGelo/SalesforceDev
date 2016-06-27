@RestResource(urlMapping='/Testing/*')
global with sharing class RestTest {
	@HttpPost
	global static void createChatterResponse () {
		  
		RestRequest request = RestContext.request;  //Returns the RestRequest object for our Apex REST method.
		RestContext.response.addHeader('Access-Control-Allow-Origin', 'http://polymer-dev.com:51792');
		RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize('Test'));

	}
}