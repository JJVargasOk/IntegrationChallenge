public with sharing class cityWeatherHandler {

    @AuraEnabled(cacheable=true)
    public static CalloutsResponsesWrapper handleCallouts(String city){
        try {
            CurrentWeatherResponseWrapper currentWrapper = new CurrentWeatherResponseWrapper(); 
            currentWrapper = doCalloutForCurrentWeather(city);
            List<ForecastWeatherResponseWrapper> forecastWrapper = new List<ForecastWeatherResponseWrapper>(); 
            forecastWrapper = doCalloutForFutureWeather(city);
            
            CalloutsResponsesWrapper calloutResponses = new CalloutsResponsesWrapper(currentWrapper, forecastWrapper);
            
            System.debug('Callout Responses: ' + calloutResponses);
            return calloutResponses;
        } catch(System.CalloutException e) {
            System.debug('Callout Exception Message: ' + e.getMessage());
            System.debug('Callout Exception Cause: ' + e.getCause());
            throw new AuraHandledException('Callout Error: ' + e.getMessage());
        }
    }

    public class CalloutsResponsesWrapper{
        @AuraEnabled 
        public CurrentWeatherResponseWrapper currentWeatherResponseWrapper {get; set;}
        @AuraEnabled
        public List<ForecastWeatherResponseWrapper> forecastWeatherResponseWrappers {get; set;}

        public CalloutsResponsesWrapper(CurrentWeatherResponseWrapper currentWrapper, List<ForecastWeatherResponseWrapper> forecastWrapper){
            this.currentWeatherResponseWrapper = currentWrapper;
            this.forecastWeatherResponseWrappers = forecastWrapper;
        }
    }

    // @future(callout=true)
    public static CurrentWeatherResponseWrapper doCalloutForCurrentWeather(String city){

        String URL = 'https://oktana-e0-dev-ed.develop.my.site.com/tech/services/apexrest/WeatherService/current/';

        String endpoint = URL + EncodingUtil.urlEncode(city, 'UTF-8');

        HttpResponse response = makeHttpCallout(endpoint);
        
        if (response.getStatusCode() == 200) {
            CurrentWeatherResponseWrapper currentWeatherWrapper = new CurrentWeatherResponseWrapper();
            currentWeatherWrapper = (CurrentWeatherResponseWrapper)JSON.deserialize(response.getBody(), CurrentWeatherResponseWrapper.class);
            System.debug(currentWeatherWrapper);
            System.debug(currentWeatherWrapper.location);

            return currentWeatherWrapper; 
        } else {
            throw new AuraHandledException('Failed to make API callout for current. Status: ' + response.getStatusCode());
        }
    }

    public class CurrentWeatherResponseWrapper {
        @AuraEnabled
        public String location {get; set;}
        @AuraEnabled
        public Integer temperature {get; set;}
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String humidity {get; set;}

        public CurrentWeatherResponseWrapper(){} 
    }

    public static List<ForecastWeatherResponseWrapper> doCalloutForFutureWeather(String city){
        String URL = 'https://oktana-e0-dev-ed.develop.my.site.com/tech/services/apexrest/WeatherService/forecast/';


        String endpoint = URL + EncodingUtil.urlEncode(city, 'UTF-8');

        HttpResponse response = makeHttpCallout(endpoint);
        System.debug(response);
        System.debug(response.getBody());

        
        if (response.getStatusCode() == 200) {
            List<ForecastWeatherResponseWrapper> currentWeatherWrapperList = new List<ForecastWeatherResponseWrapper>();
            currentWeatherWrapperList = (List<ForecastWeatherResponseWrapper>)JSON.deserialize(response.getBody(), List<ForecastWeatherResponseWrapper>.class);
            System.debug(currentWeatherWrapperList);
            
            return currentWeatherWrapperList; 
        } else {
            throw new AuraHandledException('Failed to make API callout for forecast. Status: ' + response.getStatusCode());
        }
    }

    public class ForecastWeatherResponseWrapper {
        @AuraEnabled
        public String day {get; set;}
        @AuraEnabled
        public Integer temperature {get; set;}
        @AuraEnabled
        public String description {get; set;}
    }

    public static HttpResponse makeHttpCallout(String endpoint){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint); 
        request.setMethod('GET'); 
        request.setHeader('Content-Type', 'application/json');
        request.setTimeout(30000); 

        
        HttpResponse response = http.send(request);
        return response;
    }
}