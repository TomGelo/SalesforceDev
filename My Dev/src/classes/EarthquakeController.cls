global with sharing class EarthquakeController {

    public EarthquakeController(){}

    public static String username = Geonames__c.getInstance('earthquake').username__c;

    public static String createBaseEndpoint(){

        Geonames__c quake = Geonames__c.getInstance('earthquake');

        return quake.url__c + quake.webservice__c + quake.format__c + '?';

    }

    public static Earthquake[] retrieveData(String endpoint){

        Earthquake[] quakes = new Earthquake[]{};

        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        
        HTTPResponse res = http.send(req);

        String jsonResponse = res.getBody().replace('datetime','quakeTime');
        JSONParser parser = JSON.createParser(jsonResponse);
        while (parser.nextToken() != null) {
        // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                 while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire invoice object, including its array of line items.
                        Earthquake eq = (Earthquake)parser.readValueAs(Earthquake.class);
                        // For debugging purposes, serialize again to verify what was parsed.
                        String s = JSON.serialize(eq);
                        system.debug('Serialized earthquakes: ' + s);
                        quakes.add(eq);
                    }
                }
            }
        }

        return quakes;

    }

    @RemoteAction
    global static Earthquake[] findQuakes(String bounds){

        String[] mapBounds = bounds.split(',');
        
        String endpoint = createBaseEndpoint();
        endpoint += 'north=' + mapBounds[0] + '&';
        endpoint += 'south=' + mapBounds[2] + '&';
        endpoint += 'east=' + mapBounds[3] + '&';
        endpoint += 'west=' + mapBounds[1] + '&';
        endpoint += 'username=' + username;
        System.debug(endpoint);

        Earthquake[] earthquakes = retrieveData(endpoint);
       
        earthquakes.sort();
        return earthquakes;

    }

    @RemoteAction
    global static Earthquake[] allQuakes(String startdate){

        Earthquake[] finalQuakeList = new Earthquake[]{};

        String endpoint = createBaseEndpoint();
        endpoint += 'north=89.9&';
        endpoint += 'south=-89.9&';
        endpoint += 'east=-179.9&';
        endpoint += 'west=179.9&';
        endpoint += 'date='+ startdate + '&';
        endpoint += 'maxRows=' + 120 + '&';
        endpoint += 'username=' + username;
        System.debug(endpoint);

        Earthquake[] earthquakes = retrieveData(endpoint);

        earthquakes.sort();
        
        for(Integer i = 9; i>=0; i--){
            finalQuakeList.add(earthquakes[i]);
        }

        return finalQuakeList;
    }

    global class Earthquake implements Comparable{

        public String eqid;
        public Double magnitude;
        public Double lng;
        public String src;
        public String quakeTime;
        public Double depth;
        public Double lat;

        public Earthquake(String Id, Double size, Double longitude, String source, String quakeDT, Double deep, Double latitude){
            eqid = Id;
            magnitude = size;
            lng = longitude;
            src = source;
            quakeTime = quakeDT;
            depth = deep;
            lat = latitude;
        }

        public Integer compareTo(Object compareTo) {
            Earthquake compareQuakes = (Earthquake)compareTo;
            if (magnitude == compareQuakes.magnitude) return 0;
            if (magnitude < compareQuakes.magnitude) return 1;
            return -1;
        }

    }

}