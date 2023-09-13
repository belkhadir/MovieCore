//
//  MovieMapperTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 13/9/2023.
//

import XCTest

final public class MovieMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    static func map(json: Data, httpResponse: HTTPURLResponse) throws {
        if httpResponse.statusCode != 200 {
            throw Error.invalidData
        }
    }
}


final class MovieMapperTests: XCTestCase {

    func testGivenNon200HTTPResponses_WhenMappingJSON_ThenThrowsError() throws {
        let json = [String: Any]()
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        let anyURL = URL(string: "http://anyURL.com")!
        let sample = [199, 201, 299, 400]
        try sample.forEach { statusCode in
            let httpResponse = HTTPURLResponse(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            XCTAssertThrowsError(try MovieMapper.map(json: jsonData, httpResponse: httpResponse))
        }
    }
}
