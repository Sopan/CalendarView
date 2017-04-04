//
//  Forecast+JSONConvertible.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation

extension Forecast: JSONConvertible {
    
    static func fromJSON(json: [String : Any]) -> Forecast? {
        
        let location: Location?
        if let json = json["location"] as? [String: Any] {
            location = Location.fromJSON(json: json)
        } else {
            location = nil
        }

        let daily: [ForecastDay]? = (keypath(json, path: "forecast.simpleforecast.forecastday") as [[String: Any]]?)?.flatMap({ (json: [String: Any]) in
            return ForecastDay.fromJSON(json: json)
        })
        
        let hourly: [ForecastHourly]? = (json["hourly_forecast"] as? [[String: Any]])?.flatMap({ (json: [String: Any]) in
            return ForecastHourly.fromJSON(json: json)
        })
        
        return Forecast(
            location: location,
            daily: daily,
            hourly: hourly
        )
    }
    
}
