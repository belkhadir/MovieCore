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
        guard let _ = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
              httpResponse.statusCode == 200 else {
            throw Error.invalidData
        }
    }
}


final class MovieMapperTests: XCTestCase {
    func testGivenNon200HTTPResponses_WhenMappingJSON_ThenThrowsError() throws {
        let json = [String: Any]()
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        try assertThatThrows(json: jsonData, statusCodes: [199, 201, 299, 400])
    }
    
    func testGivenInvalidJSON_And_200HTTPResponse_WhenMapping_ThenThrowsError() throws {
        let invalidData = Data("invalid json".utf8)
        
        try assertThatThrows(json: invalidData, statusCodes: [200])
    }
    
    func testGivenInvalidJSON_And_Non200HTTPResponse_WhenMappingJSON_ThenThrowsError() throws {
        let invalidData = Data("invalid json".utf8)
        
        try assertThatThrows(json: invalidData, statusCodes: [199, 201, 299, 400])
    }
}


// MARK: - Helpers
private extension MovieMapperTests {
    func assertThatThrows(json: Data, statusCodes: [Int], file: StaticString = #file, line: UInt = #line) throws {
        try statusCodes.forEach { statusCode in
            XCTAssertThrowsError(
                try MovieMapper.map(json: json, httpResponse: HTTPURLResponse(statusCode: statusCode)),
                "Expected to throw error",
                file: file,
                line: line
            )
        }
    }
}
