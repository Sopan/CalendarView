//
//  ForecastHourly+JSONConvertible.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation

extension ForecastHourly: JSONConvertible {
    
    static func fromJSON(json: [String : Any]) -> ForecastHourly? {
        guard let epoch_string = keypath(json, path: "FCTTIME.epoch") as String?,
            let date_interval = TimeInterval(epoch_string),
            let description = json["condition"] as? String,
            let _ = json["icon"] as? String,
            let wx = json["wx"] as? String,
            let uvi = (json["uvi"] as? NSString)?.integerValue,
            let humidity = (json["humidity"] as? NSString)?.integerValue,
            let pop = (json["pop"] as? NSString)?.doubleValue,
            let temp = (keypath(json, path: "temp.english") as NSString?)?.integerValue,
            let windchill = (keypath(json, path: "windchill.english") as NSString?)?.integerValue,
            let heatindex = (keypath(json, path: "heatindex.english") as NSString?)?.integerValue,
            let feelslike = (keypath(json, path: "feelslike.english") as NSString?)?.integerValue,
            let dewpoint = (keypath(json, path: "dewpoint.english") as NSString?)?.integerValue,
            let qpf = (keypath(json, path: "qpf.english") as NSString?)?.doubleValue,
            let snow = (keypath(json, path: "snow.english") as NSString?)?.doubleValue,
            let mslp = (keypath(json, path: "mslp.english") as NSString?)?.doubleValue
            else { return nil }
        
        return ForecastHourly(
            date: Date(timeIntervalSince1970: date_interval),
            temp: temp,
            dewpoint: dewpoint,
            description: description,
            wx: wx,
            uvi: uvi,
            humidity: humidity,
            windchill: windchill,
            heatindex: heatindex,
            feelslike: feelslike,
            qpf: qpf,
            snow: max(snow, 0),
            pop: max(pop / 100.0, 0),
            mslp: mslp
        )
    }
    
}
