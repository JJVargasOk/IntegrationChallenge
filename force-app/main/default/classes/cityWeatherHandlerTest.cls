@isTest
private class cityWeatherHandlerTest {
    
    
    private class cityWeatherCalloutMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('https://oktana-e0-dev-ed.develop.my.site.com/tech/services/apexrest/WeatherService/current/')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{"location":"montevideo","temperature":"15","description":"Partly Cloudy","humidity":"34%"}');
                res.setStatusCode(200);
                return res;

            } else if (req.getEndpoint().startsWith('https://oktana-e0-dev-ed.develop.my.site.com/tech/services/apexrest/WeatherService/forecast/')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('[' +
                                '{"day":"Monday","temperature":"33","description":"Rainy"},'   +
                                '{"day":"Tuesday","temperature":"42","description":"Thunderstorms"},'   +
                                '{"day":"Wednesday","temperature":"27","description":"Thunderstorms"},'   +
                                '{"day":"Thursday","temperature":"12","description":"Partly Cloudy"},'   + 
                                '{"day":"Friday","temperature":"42","description":"Sunny"}' +  
                            ']');
                res.setStatusCode(200);
                return res;

            } else if (req.getEndpoint().startsWith('https://oktana-e0-dev-ed.develop.my.site.com/tech/services/apexrest/WeatherService/fail/')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('An error occurred while processing your request.');
                res.setStatusCode(500);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }

    @isTest
    static void testHandleCallouts() {
        String city = 'Montevideo';

        Test.setMock(HttpCalloutMock.class, new cityWeatherCalloutMock());

        Test.startTest();
        cityWeatherHandler.CalloutsResponsesWrapper cityWeatherHandlerResponse = cityWeatherHandler.handleCallouts(city);
        Test.stopTest();

        System.assertEquals('montevideo', cityWeatherHandlerResponse.currentWeatherResponseWrapper.location, 'Location did not match');
        System.assertEquals(15, cityWeatherHandlerResponse.currentWeatherResponseWrapper.temperature, 'Temperature did not match');
    }     
}