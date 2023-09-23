//
//  ImageRequest.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 21/9/2023.
//

public struct ImageRequest: Requestable {
    private let imagePath: String
    
    public init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    public var host: String {
        "image.tmdb.org"
    }
    
    public var path: String {
        "/t/p/w200" + "\(imagePath)"
    }
    
    public var requestType: HTTPMethod {
        .GET
    }
}
