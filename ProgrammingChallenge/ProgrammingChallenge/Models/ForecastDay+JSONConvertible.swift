//
//  ForecastDay+JSONConvertible.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation

extension ForecastDay: JSONConvertible {
    
    static func fromJSON(json: [String : Any]) -> ForecastDay? {
        guard let epoch_string = keypath(json, path: "date.epoch") as String?,
            let date_interval = TimeInterval(epoch_string),
            let high = (keypath(json, path: "high.fahrenheit") as NSString?)?.integerValue,
            let low = (keypath(json, path: "low.fahrenheit") as NSString?)?.integerValue,
            let description = json["conditions"] as? String,
            let pop = json["pop"] as? Int,
            let qpf_allday = keypath(json, path: "qpf_allday.in") as Double?,
            let qpf_day = keypath(json, path: "qpf_day.in") as Double?,
            let qpf_night = keypath(json, path: "qpf_night.in") as Double?,
            let snow_allday = keypath(json, path: "snow_allday.in") as Double?,
            let snow_day = keypath(json, path: "snow_day.in") as Double?,
            let snow_night = keypath(json, path: "snow_night.in") as Double?,
            let avehumidity = json["avehumidity"] as? Int,
            let maxhumidity = json["maxhumidity"] as? Int,
            let minhumidity = json["minhumidity"] as? Int
            else { return nil }
        
        return ForecastDay(
            date: Date(timeIntervalSince1970: date_interval),
            high: high,
            low: low,
            description: description,
            pop: max(Double(pop) / 100.0, 0),
            qpf_allday: max(qpf_allday, 0),
            qpf_day: max(qpf_day, 0),
            qpf_night: max(qpf_night, 0),
            snow_allday: max(snow_allday, 0),
            snow_day: max(snow_day, 0),
            snow_night: max(snow_night, 0),
            avehumidity: avehumidity,
            maxhumidity: maxhumidity,
            minhumidity: minhumidity
        )
    }
    
}
