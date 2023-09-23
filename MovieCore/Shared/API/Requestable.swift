//
//  Requestable.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 16/9/2023.
//

import Foundation

public protocol Requestable {
    var host: String { get }
    var path: String { get }
    var headers: [String: String] { get }
    var httpBody: [String: Any] { get }
    var urlParameters: [String: String?] { get }
    var requestType: HTTPMethod { get }
}

// MARK: - Default values, some request doesn't require `params`, `urlParams` and `headers`
public extension Requestable {
    var host: String {
        "api.themoviedb.org"
    }
    
    var httpBody: [String: Any] {
        [:]
    }
    
    var urlParameters: [String: String?] {
        [:]
    }
    
    var headers: [String: String] {
        [:]
    }
}

public extension Requestable {
    func createURLRequest(bearerTokonize: String? = nil) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        
        if !urlParameters.isEmpty {
            components.queryItems = urlParameters.map {
                URLQueryItem(name: $0, value: $1)
            }
        }
        
        guard let url = components.url else {
            throw RequestError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.rawValue
          
        if !headers.isEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        if let bearerTokonize {
            urlRequest.setValue(bearerTokonize, forHTTPHeaderField: "Authorization")
        }
        if !httpBody.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: httpBody)
        }
        return urlRequest
    }
}
