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
    
    public var path: String {
        "/t/p/w500\(imagePath)"
    }
    
    public var requestType: RequestType {
        .GET
    }
}
