@isTest
private class EarthquakeTests
{
	@isTest
	static void testEarthQuakeController(){

		//create Mock resposne from static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('CalloutMockResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        //custom setting that stores endpoint information
		Geonames__c quake = new Geonames__c();
		quake.Name = 'earthquake';
		quake.url__c = 'http://api.geonames.org/';
		quake.webservice__c = 'earthqaukes';
		quake.format__c = 'JSON';
		quake.username__c = 'tgeloDev';
		insert quake;

		//earthquake test data
		Double magnitude = 4.5;
		Double latitude = 142.369;
		Double depth = 24.4;
		Double longitude = 38.322;
		String testBounds = '49.410973,-4.515381,53.514184,4.273681';
		String testDate = '2014-07-01';

		//instantiate controller
		EarthquakeController testController = new EarthquakeController();

		Test.startTest();
			Test.setMock(HttpCalloutMock.class, mock);
			EarthquakeController.findQuakes(testBounds);
			EarthquakeController.allQuakes(testDate);

			EarthquakeController.Earthquake testObject = new EarthquakeController.Earthquake(
					'c0001xgp', magnitude, longitude, 'us', '2011-03-11 04:46:23', depth, latitude);
		Test.stopTest();

	}

}