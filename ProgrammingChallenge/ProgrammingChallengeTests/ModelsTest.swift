//
//  ModelsTest.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/20/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import XCTest

class ModelsTest: XCTestCase {
    
    let sampleJSONResponse: [String: Any] = {
        // hard crash on all of this if something is wrong
        let url = Bundle(for: ProgrammingChallengeTests.self).url(forResource: "SampleResponse", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }()
    
    func testLocationFromValidJSON() {
        let json = [
            "type": "CITY",
            "country": "US",
            "country_iso3166": "US",
            "country_name": "USA",
            "state": "NY",
            "city": "Manhattan",
            "tz_short": "EST",
            "tz_long": "America/New_York",
            "lat": "40.710000",
            "lon": "-74.000000",
            "zip": "11201",
            "magic": "9",
            "wmo": "99999",
            "l": "/q/zmw:11201.9.99999",
            "requesturl": "US/NY/Fulton_Ferry.html",
            "wuiurl": "https://www.wunderground.com/US/NY/Fulton_Ferry.html"
        ]
        let location = Location.fromJSON(json: json)
        XCTAssertEqual(location?.type, "CITY")
        XCTAssertEqual(location?.country, "US")
        XCTAssertEqual(location?.country_iso3166, "US")
        XCTAssertEqual(location?.country_name, "USA")
        XCTAssertEqual(location?.state, "NY")
        XCTAssertEqual(location?.city, "Manhattan")
        XCTAssertEqual(location?.tz_short, "EST")
        XCTAssertEqual(location?.tz_long, "America/New_York")
        XCTAssertEqual(location?.lat, 40.71)
        XCTAssertEqual(location?.lon, -74)
        XCTAssertEqual(location?.zip, 11201)
        XCTAssertEqual(location?.magic, "9")
        XCTAssertEqual(location?.wmo, "99999")
        XCTAssertEqual(location?.l, "/q/zmw:11201.9.99999")
        XCTAssertEqual(location?.requesturl, "US/NY/Fulton_Ferry.html")
        XCTAssertEqual(location?.wuiurl, "https://www.wunderground.com/US/NY/Fulton_Ferry.html")
    }
    
    func testLocationFromSampleJSON() {
        let json = sampleJSONResponse["location"] as! [String: Any]
        let location = Location.fromJSON(json: json)
        XCTAssertNotNil(location)
    }
    
    func testForecastFromValidJSON() {
        let json: [String: Any] = [
            "date": [
                "epoch": "1479168000",
            ],
            "high": [
                "fahrenheit": "64",
            ],
            "low": [
                "fahrenheit": "50",
            ],
            "conditions": "Partly Cloudy",
            "icon": "partlycloudy",
            "pop": 50,
            "qpf_allday": [
                "in": 0.1,
            ],
            "qpf_day": [
                "in": 0.2,
            ],
            "qpf_night": [
                "in": 0.3,
            ],
            "snow_allday": [
                "in": 0.4,
            ],
            "snow_day": [
                "in": 0.5,
            ],
            "snow_night": [
                "in": 0.6,
            ],
            "maxwind": [
                "mph": 10.0,
                "dir": "SW",
            ],
            "avewind": [
                "mph": 5.0,
                "dir": "NW",
            ],
            "avehumidity": 39,
            "maxhumidity": 56,
            "minhumidity": 30
        ]
        let forecast = ForecastDay.fromJSON(json: json)
        XCTAssertEqual(forecast?.date, Date(timeIntervalSince1970: 1479168000))
        XCTAssertEqual(forecast?.high, 64)
        XCTAssertEqual(forecast?.low, 50)
        XCTAssertEqual(forecast?.description, "Partly Cloudy")
        XCTAssertEqual(forecast?.pop, 0.5)
        XCTAssertEqual(forecast?.qpf_allday, 0.1)
        XCTAssertEqual(forecast?.qpf_day, 0.2)
        XCTAssertEqual(forecast?.qpf_night, 0.3)
        XCTAssertEqual(forecast?.snow_allday, 0.4)
        XCTAssertEqual(forecast?.snow_day, 0.5)
        XCTAssertEqual(forecast?.snow_night, 0.6)
        XCTAssertEqual(forecast?.avehumidity, 39)
        XCTAssertEqual(forecast?.maxhumidity, 56)
        XCTAssertEqual(forecast?.minhumidity, 30)
    }
    
    func testForecastFromSampleJSON() {
        let forecast_json = sampleJSONResponse["forecast"] as! [String: Any]
        let simpleforecast = forecast_json["simpleforecast"] as! [String: Any]
        let forecastday = simpleforecast["forecastday"] as! [ [String: Any] ]
        let forecast = ForecastDay.fromJSON(json: forecastday.first!)
        XCTAssertNotNil(forecast)
    }
    
    func testForecastHourlyFromValidJSON() {
        let json: [String: Any] = [
            "FCTTIME": [
                "epoch": "1479135600",
            ],
            "temp": [
                "english": "53",
            ],
            "dewpoint": [
                "english": "29",
            ],
            "condition": "Clear",
            "icon": "clear",
            "wspd": [
                "english": "4",
            ],
            "wdir": [
                "dir": "SW",
            ],
            "wx": "Sunny",
            "uvi": "2",
            "humidity": "39",
            "windchill": [
                "english": "-9999",
            ],
            "heatindex": [
                "english": "48",
            ],
            "feelslike": [
                "english": "53",
            ],
            "qpf": [
                "english": "0.6",
            ],
            "snow": [
                "english": "1.2",
            ],
            "pop": "30",
            "mslp": [
                "english": "30.06",
            ]
        ]
        let forecast = ForecastHourly.fromJSON(json: json)
        XCTAssertEqual(forecast?.date, Date(timeIntervalSince1970: 1479135600))
        XCTAssertEqual(forecast?.temp, 53)
        XCTAssertEqual(forecast?.dewpoint, 29)
        XCTAssertEqual(forecast?.description, "Clear")
        XCTAssertEqual(forecast?.wx, "Sunny")
        XCTAssertEqual(forecast?.uvi, 2)
        XCTAssertEqual(forecast?.humidity, 39)
        XCTAssertEqual(forecast?.windchill, -9999)
        XCTAssertEqual(forecast?.heatindex, 48)
        XCTAssertEqual(forecast?.feelslike, 53)
        XCTAssertEqual(forecast?.qpf, 0.6)
        XCTAssertEqual(forecast?.snow, 1.2)
        XCTAssertEqual(forecast?.pop, 0.3)
        XCTAssertEqual(forecast?.mslp, 30.06)
    }
    
    func testForecastHourlyFromSampleJSON() {
        let json = (sampleJSONResponse["hourly_forecast"] as! [ [String: Any] ]).first!
        let forecast = ForecastHourly.fromJSON(json: json)
        XCTAssertNotNil(forecast)
    }
    
    func testForecastCreatedFromSampleJSON() {
        let forecast = Forecast.fromJSON(json: sampleJSONResponse)
        XCTAssertNotNil(forecast?.location)
        XCTAssertEqual(forecast?.daily?.count, 10)
        XCTAssertEqual(forecast?.hourly?.count, 36)
    }

    
}
