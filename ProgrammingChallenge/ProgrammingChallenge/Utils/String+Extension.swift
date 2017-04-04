//
//  String+Extension.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/13/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

extension String {
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < characters.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from,
            let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from,
            start >= 0 {
            startIndex = index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to,
            end >= 0,
            end < characters.count {
            endIndex = index(self.startIndex, offsetBy: end)
        } else {
            endIndex = self.endIndex
        }
        
        return self[startIndex ..< endIndex]
    }
    
    func substring(from: Int) -> String {
        return substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from,
            start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to,
            end > 0,
            length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to,
            end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return substring(from: start, to: to)
    }
}
