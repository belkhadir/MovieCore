//
//  RequestableTest.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 16/9/2023.
//

import XCTest
import MovieCore

final class RequestableTest: XCTestCase {
    struct MockRequest: Requestable {
        var path = "/test"
        var headers: [String : String] = ["headerField": "headerValue"]
        var httpBody: [String : Any] = ["key": "value"]
        var urlParameters: [String : String?] = ["param": "paramValue"]
        var requestType = RequestType.GET
    }
    
    func testDefaultValues() {
        let request = MockRequest()
        XCTAssertEqual(request.host, "api.themoviedb.org")
        XCTAssertEqual(request.httpBody as? [String: String], ["key": "value"])
        XCTAssertEqual(request.urlParameters as? [String: String], ["param": "paramValue"])
        XCTAssertEqual(request.headers, ["headerField": "headerValue"])
    }
    
    func testCreateURLRequest() throws {
        let request = MockRequest()
        let bearerToken = "sampleToken"
        let urlRequest = try request.createURLRequest(bearerTokonize: bearerToken)
        
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.themoviedb.org/test?param=paramValue")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["headerField"], "headerValue")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], bearerToken)
        
        let httpBody = try JSONSerialization.jsonObject(with: urlRequest.httpBody!, options: []) as? [String: String]
        XCTAssertEqual(httpBody, ["key": "value"])
    }
    
    func testInvalidURL() {
        struct InvalidRequest: Requestable {
            var path = "This is not a valid path"
            var requestType = RequestType.GET
        }
        
        let request = InvalidRequest()
        XCTAssertThrowsError(try request.createURLRequest(bearerTokonize: "token")) { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.invalidURL)
        }
    }
}
