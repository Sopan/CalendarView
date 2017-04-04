//
//  NetworkAPITest.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/20/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import XCTest

class NetworkAPITest: XCTestCase {
    
    func jsonHandler(json: Any) -> Forecast? {
        guard let json = json as? [String: Any],
            // for testing purposes, only parse when "response" key is present
            json["response"] != nil
            else { return nil }
        return Forecast.fromJSON(json: json)
    }
    
    func testBuildingURL() {
        let base = "http://api.wunderground.com"
        let paths = ["api", "TEST_KEY", "forecast", "geolookup", "conditions", "forecast10day", "alerts", "hourly", "astronomy", "q", "40.71,-74.json"]
        let url = URLBuilder(base: base, paths: paths, query: nil)
        XCTAssertEqual(url?.absoluteString, "http://api.wunderground.com/api/TEST_KEY/forecast/geolookup/conditions/forecast10day/alerts/hourly/astronomy/q/40.71,-74.json")
    }

    func testForecastObjectWithNoErrors() {
        let url = Bundle(for: ProgrammingChallengeTests.self).url(forResource: "SampleResponse", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        let result = URLSessionDataTaskResponse(
            serializeJSON: true,
            parse: self.jsonHandler
            ).handle(data: data, error: nil)
        
        switch result {
        case .success(let r):
            XCTAssertEqual(r.location?.city, "Manhattan")
        case .failure(_):
            XCTFail()
        }
    }
    
    func testEmptyResponse() {
        let result = URLSessionDataTaskResponse(
            serializeJSON: true,
            parse: self.jsonHandler
            ).handle(data: nil, error: nil)
        
        switch result {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertTrue(error == .emptyResponse)
        }
    }
    
    func testCorruptResponse() {
        let data = NSKeyedArchiver.archivedData(withRootObject: "someBad:json")
        
        let result = URLSessionDataTaskResponse(
            serializeJSON: true,
            parse: self.jsonHandler
            ).handle(data: data, error: nil)
        
        switch result {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertTrue(error == .json("The data couldn’t be read because it isn’t in the correct format."))
        }
    }
    
    func testJSONCastingError() {
        // json array not dictionary
        let data = try! JSONSerialization.data(withJSONObject: [["key": "value"]], options: [])
        
        let result = URLSessionDataTaskResponse(
            serializeJSON: true,
            parse: self.jsonHandler
            ).handle(data: data, error: nil)
        
        switch result {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertTrue(error == .jsonCast)
        }
    }
    
    func testWrongDataParsingError() {
        let data = try! JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
        
        let result = URLSessionDataTaskResponse(
            serializeJSON: true,
            parse: self.jsonHandler
            ).handle(data: data, error: nil)
        
        switch result {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertTrue(error == .parsing)
        }
    }
    
    func testNetworkError() {
        let error = NSError(domain: "test", code: 100, userInfo: [NSLocalizedDescriptionKey: "Testing"])
        
        let result = URLSessionDataTaskResponse(
            serializeJSON: true,
            parse: self.jsonHandler
            ).handle(data: nil, error: error)
        
        switch result {
        case .success(_):
            XCTFail()
        case .failure(let error):
            XCTAssertTrue(error == .network("Testing"))
        }
    }
    
}
