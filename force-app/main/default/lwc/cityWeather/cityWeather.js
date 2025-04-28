// Salesforce utilities
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Importing the Apex method to handle callouts
import handleCallouts from "@salesforce/apex/cityWeatherHandler.handleCallouts";


// Static resources for icons
import HUMIDITY from "@salesforce/resourceUrl/Humidity";
import PARTIALLYCLOUDY from "@salesforce/resourceUrl/PartiallyCloudy";
import RAINY from "@salesforce/resourceUrl/Rainy";
import SNOWY from "@salesforce/resourceUrl/Snowy";
import SUNNY from "@salesforce/resourceUrl/Sunny";
import THUNDERSTORM from "@salesforce/resourceUrl/Thunderstrom";

export default class CityWeather extends LightningElement {
    // Href for svgs
    humidity = HUMIDITY;
    partiallyCloudy = PARTIALLYCLOUDY;
    rainy = RAINY;
    snowy = SNOWY;
    sunny = SUNNY;
    thunderstorm = THUNDERSTORM;

    // Variables to show in front
    // currentWeather
    currentTitle = 'No city selected';
    currentTemp = 32;
    currentSrc = this.sunny;
    currentDescription = 'test des';
    currentHumidity = 50;
    // forecastWeather
    forecastDays = [];

    
    selectedContinent = '';
    selectedCity = '';
    citySelected = false;

    showSpinner = false;

    cityOptions = [];
    isCityDisabled = true;


    
    // Continent options
    continentOptions = [
        { label: 'Asia', value: 'asia' },
        { label: 'Europe', value: 'europe' },
        { label: 'America', value: 'america' },
    ];

    // Method to handle continent change
    handleContinentChange(event) {
        this.selectedContinent = event.target.value;

        // Fetch city options
        this.updateCityOptions();
    }

    cityOptionsByContinent = {
        asia: [
            {label: 'Tokyo', value: 'Tokyo'},
            {label: 'Bangkok', value: 'Bangkok'},
            {label: 'Seoul', value: 'Seoul'}
        ],

        europe: [
            {label: 'Paris', value: 'Paris'},
            {label: 'London', value: 'London'},
            {label: 'Madrid', value: 'Madrid'}
        ],

        america: [
            {label: 'Montevideo', value: 'Montevideo'},
            {label: 'Miami', value: 'Miami'},
            {label: 'Rio de Janeiro', value: 'Rio de Janeiro'},
            {label: 'Bogota', value: 'Bogota'}
        ]
    };

    updateCityOptions(){
        this.cityOptions = this.cityOptionsByContinent[this.selectedContinent];
        this.isCityDisabled = this.cityOptions.length === 0 ? true : false;
    }

    async handleCityChange(event){
        this.selectedCity = event.target.value;

        this.showSpinner = true;

        await handleCallouts({ city: this.selectedCity })
        .then(response => {
            // We set the current weather data
            try {  
                this.currentTemp = response.currentWeatherResponseWrapper.temperature;
                this.currentDescription = response.currentWeatherResponseWrapper.description;
                this.currentHumidity = response.currentWeatherResponseWrapper.humidity;
                this.currentTitle = this.selectedCity;
                this.currentSrc = this.getWeatherIcon(this.currentDescription);
            } catch (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while setting current weather data',
                        variant: 'error'
                    })
                )
            }

            // We set the forecast data
            try {  
                let forecasts = response.forecastWeatherResponseWrappers;
                // We reset it for next city data
                this.forecastDays = [];
                forecasts.forEach(forecast => {
                    this.forecastDays.push({
                        day: forecast.day,
                        temperature: forecast.temperature,
                        description: forecast.description,
                        weather: this.getWeatherIcon(forecast.description)
                    });
                });
            } catch (error) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error while setting forecast data',
                        variant: 'error'
                    })
                )
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while fetching data from API',
                    variant: 'error'
                })
            );
        });
        this.showSpinner = false;
        this.citySelected = true;
    }
    
    getWeatherIcon(description) {
        switch (description) {
            case 'Sunny':
                return this.sunny;
            case 'Partially Cloudy':
                return this.partiallyCloudy;
            case 'Rainy':
                return this.rainy;
            case 'Snowy':
                return this.snowy;
            case 'Thunderstorms':
                return this.thunderstorm;
            default:
                return this.sunny;
        }
    }
}