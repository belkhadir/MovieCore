//
//  MovieRequest.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 16/9/2023.
//

public struct MoviesRequest: Requestable {
    private let movieDiscover: MovieDiscover
    private let page: Int
    
    public enum MovieDiscover: String {
        case popular
        case topRated = "top_rated"
        case upcoming
    }
    
    public init(movieDiscover: MovieDiscover = .popular, page: Int = 1) {
        self.movieDiscover = movieDiscover
        self.page = page
    }
    
    public var path: String {
        "/3/movie/" + movieDiscover.rawValue
    }
    
    public var requestType: HTTPMethod {
        .GET
    }
    
    public var urlParameters: [String : String?] {
        ["page": "\(page)"]
    }
}
