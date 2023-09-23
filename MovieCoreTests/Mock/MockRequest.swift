//
//  MockRequest.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import MovieCore

struct MockRequest: Requestable {
    var path = "/test"
    var headers: [String : String] = ["headerField": "headerValue"]
    var httpBody: [String : Any] = ["key": "value"]
    var urlParameters: [String : String?] = ["param": "paramValue"]
    var requestType = HTTPMethod.GET
}
