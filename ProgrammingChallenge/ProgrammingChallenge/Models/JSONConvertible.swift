//
//  JSONConvertible.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation

protocol JSONConvertible {
    static func fromJSON(json: [String: Any]) -> Self?
}
