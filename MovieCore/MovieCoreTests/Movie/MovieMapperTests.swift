//
//  MovieMapperTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 13/9/2023.
//

import XCTest
import MovieCore

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
            releaseDate: (Date.fromDateString("2020-08-28")!, "2020-08-28"),
            imagePath: "/poster/path.png",
            overview: "descrption",
            voteAverage: 1,
            voteCount: 1
        )
        
        let item2 = makeItem(
            id: 1,
            title: "another title",
            releaseDate: (Date.fromDateString("2020-08-28")!, "2020-08-28"),
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
