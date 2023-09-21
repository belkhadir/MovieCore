//
//  Movie.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 16/9/2023.
//

import Foundation

public struct Movie: Equatable {
    public let id: Int
    public let title: String
    public let releaseDate: Date
    public let imagePath: String
    public let overview: String
    public let voteAverage: Double
    public let voteCount: Int
    
    public init(
        id: Int,
        title: String,
        releaseDate: Date,
        imagePath: String,
        overview: String,
        voteAverage: Double,
        voteCount: Int
    ) {
        self.id = id
        self.title = title
        self.releaseDate = releaseDate
        self.imagePath = imagePath
        self.overview = overview
        self.voteAverage = voteAverage
        self.voteCount = voteCount
    }
}
