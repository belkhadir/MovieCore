//
//  MoviesMapper.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 16/9/2023.
//

import Foundation

final public class MoviesMapper {
    private struct Root: Decodable {
        private let page: Int
        private let results: [MovieAPI]
        private let total_pages: Int
        private let total_results: Int
        
        private struct MovieAPI: Decodable {
            let id: Int
            let title: String
            let release_date: Date
            let poster_path: String
            let overview: String
            let vote_average: Double
            let vote_count: Int
        }
        
        private var movies: [Movie] {
            results.map {
                Movie(
                    id:$0.id,
                    title: $0.title,
                    releaseDate: $0.release_date,
                    imagePath: $0.poster_path,
                    overview: $0.overview,
                    voteAverage: $0.vote_average,
                    voteCount: $0.vote_count
                )
            }
        }
        
        var paginatedMovies: Paginated<Movie> {
            Paginated(
                items: movies,
                page: page,
                totalPages: total_pages,
                totalResults: total_results
            )
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    static public func map(json: Data, httpResponse: HTTPURLResponse) throws -> Paginated<Movie> {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        guard httpResponse.isOK else {
            throw Error.invalidData
        }
        
        return try decoder.decode(Root.self, from: json).paginatedMovies
    }
}
