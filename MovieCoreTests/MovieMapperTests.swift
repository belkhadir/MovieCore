//
//  MovieMapperTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 13/9/2023.
//

import XCTest


final public class MoviesMapper {
    private struct Root: Decodable {
        private let results: [MovieAPI]
        
        private struct MovieAPI: Decodable {
            let id: Int
            let title: String
            let release_date: Date
            let poster_path: String
            let overview: String
            let vote_average: Double
            let vote_count: Int
        }
        
        var movies: [Movie] {
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
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    static public func map(json: Data, httpResponse: HTTPURLResponse) throws -> [Movie] {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        guard httpResponse.statusCode == 200,
            let root = try? decoder.decode(Root.self, from: json) else {
            throw Error.invalidData
        }
        
        return root.movies
    }
}

public struct Movie: Equatable {
    let id: Int
    let title: String
    let releaseDate: Date
    let imagePath: String
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    
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


final class MovieMapperTests: XCTestCase {
    func testGivenNon200HTTPResponses_WhenMappingJSON_ThenThrowsError() throws {
        let json = [String: Any]()
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        try assertThatThrows(json: jsonData, statusCodes: [199, 201, 299, 400])
    }
    
    func testGivenInvalidJSON_And_200HTTPResponse_WhenMapping_ThenThrowsError() throws {
        let invalidData = Data("invalid json".utf8)
        
        try assertThatThrows(json: invalidData, statusCodes: [200])
    }
    
    func testGivenInvalidJSON_And_Non200HTTPResponse_WhenMappingJSON_ThenThrowsError() throws {
        let invalidData = Data("invalid json".utf8)
        
        try assertThatThrows(json: invalidData, statusCodes: [199, 201, 299, 400])
    }
    
    func testGivenValidJSON_And_200HTTPResponse_WhenMappingJSON_ThenDeliverMovies() throws {
        let item1 = makeItem(
            id: 0,
            title: "title",
            releaseDate: (Date.fromUTCString("2020-08-28")!, "2020-08-28"),
            imagePath: "/poster/path.png",
            overview: "descrption",
            voteAverage: 1,
            voteCount: 1
        )
        
        let item2 = makeItem(
            id: 1,
            title: "another title",
            releaseDate: (Date.fromUTCString("2020-08-28")!, "2020-08-28"),
            imagePath: "/poster/another_path.png",
            overview: "another descrption",
            voteAverage: 2,
            voteCount: 2
        )
        
        let json = makeItemsJSON([item1.json, item2.json])
        
        let movies = try MoviesMapper.map(json: json, httpResponse: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(movies, [item1.model, item2.model])
    }
}


// MARK: - Helpers
private extension MovieMapperTests {
    func assertThatThrows(json: Data, statusCodes: [Int], file: StaticString = #file, line: UInt = #line) throws {
        try statusCodes.forEach { statusCode in
            XCTAssertThrowsError(
                try MoviesMapper.map(json: json, httpResponse: HTTPURLResponse(statusCode: statusCode)),
                "Expected to throw error",
                file: file,
                line: line
            )
        }
    }
    
    func makeItem(
        id: Int,
        title: String,
        releaseDate: (date: Date, iso8601String: String),
        imagePath: String,
        overview: String,
        voteAverage: Double,
        voteCount: Int)
    -> (model: Movie, json: [String: Any]) {
        let movie = Movie(
            id: id,
            title: title,
            releaseDate: releaseDate.date,
            imagePath: imagePath,
            overview: overview,
            voteAverage: voteAverage,
            voteCount: voteCount)
        
        let json: [String: Any] = [
            "id": movie.id,
            "poster_path": movie.imagePath,
            "overview": movie.overview,
            "release_date": releaseDate.iso8601String,
            "title": movie.title,
            "vote_average": movie.voteAverage,
            "vote_count": movie.voteCount
        ]
        
        return (movie, json)
    }
    
    func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["results": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
