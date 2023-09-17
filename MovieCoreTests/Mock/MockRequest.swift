//
//  MockRequest.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import MovieCore

struct MockRequest: Requestable, Equatable {
    var path = "/test"
    var headers: [String : String] = ["headerField": "headerValue"]
    var httpBody: [String : Any] = ["key": "value"]
    var urlParameters: [String : String?] = ["param": "paramValue"]
    var requestType = RequestType.GET
    var bearerTokonize: String = "sampleToken"
}
