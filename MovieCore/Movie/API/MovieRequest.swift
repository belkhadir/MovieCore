//
//  MovieRequest.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 16/9/2023.
//

public struct MovieRequest: Requestable {
    private let movieDiscover: MovieDiscover
    private let page: Page
    
    public enum MovieDiscover: String {
        case popular
        case topRated = "top_rated"
        case upcoming
    }
    
    public init(movieDiscover: MovieDiscover = .popular, page: Page = Page(page: 1)) {
        self.movieDiscover = movieDiscover
        self.page = page
    }
    
    public var path: String {
        "/3/discover/" + movieDiscover.rawValue
    }
    
    public var requestType: RequestType {
        .GET
    }
    
    public var urlParameters: [String : String?] {
        ["page": "\(page.page)"]
    }
}
