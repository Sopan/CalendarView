//
//  KeypathParsing.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation

public func keypath<T>(_ dict: [String: Any], path: String) -> T? {
    let keys: [String] = path.components(separatedBy: ".")
    var next = dict
    for key in keys {
        let entry = next[key]
        if let data = entry as? [String: Any] {
            next = data
        } else if let type = entry as? T,
            key == keys.last {
            return type
        }
    }
    
    return nil
}
