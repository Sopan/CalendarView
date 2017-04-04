//
//  KeypathParsingTest.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/20/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import XCTest

class KeypathParsingTest: XCTestCase {
    
    func test_whenKeypathExists_withProperValueCast_thatValueReturned() {
        let dict = [ "shape": [ "rectangle" : "1" ] ]
        let result: String? = keypath(dict: dict, path: "shape.rectangle")
        XCTAssertEqual(result, "1")
    }
    
    func test_whenKeypathExists_withIncorrectValueCast_thatValueReturned() {
        let dict = [ "shape": [ "rectangle" : "1" ] ]
        let result: Int? = keypath(dict: dict, path: "shape.rectangle")
        XCTAssertNil(result)
    }
    
    func test_whenKeypathNotDeepEnough_thatNilReturned() {
        let dict = [ "shape": [ "rectangle" : "1" ] ]
        let result: String? = keypath(dict: dict, path: "shape")
        XCTAssertNil(result)
    }
    
    func test_whenKeypathDoesNotExist_withTooDeep_thatNilReturned() {
        let dict = [ "shape": [ "rectangle" : "1" ] ]
        let result: String? = keypath(dict: dict, path: "shape.rectangle.point")
        XCTAssertNil(result)
    }
    
    func test_whenKeypathDoesNotExist_withCorrectDepth_thatValueReturned() {
        let dict = [ "shape": [ "rectangle" : "1" ] ]
        let result: String? = keypath(dict: dict, path: "shape.point")
        XCTAssertNil(result)
    }
    
}
