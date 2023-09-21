//
//  MovieRequest.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 16/9/2023.
//

public enum MovieRequest: String, Requestable {
    case popular
    case topRated = "top_rated"
    case upcoming
    
    public var path: String {
        "/" + rawValue
    }
    
    public var requestType: RequestType {
        .GET
    }
}
