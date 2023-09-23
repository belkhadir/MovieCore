//
//  MovieRequestTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 23/9/2023.
//

import XCTest
import MovieCore

final class MovieRequestTests: XCTestCase {
    func testGivenDefaultInitialization_WhenGettingPath_ThenPopularIsChosen() {
        let sut = MoviesRequest()
        let resultPath = sut.path
            
        XCTAssertEqual(resultPath, "/3/movie/popular")
    }

    func testGivenMovieDiscoverType_WhenGettingPath_ThenCorrectPathIsReturned() {
        let types: [(MoviesRequest.MovieDiscover, String)] = [
            (.popular, "/3/movie/popular"),
            (.topRated, "/3/movie/top_rated"),
            (.upcoming, "/3/movie/upcoming")
        ]
            
        for (type, expectedPath) in types {
            let sut = MoviesRequest(movieDiscover: type)
            let resultPath = sut.path
                
            XCTAssertEqual(resultPath, expectedPath)
        }
    }

    func testGivenPageNumber_WhenGettingURLParameters_ThenCorrectPageIsReturned() {
        let pageNumber = 5
        let sut = MoviesRequest(page: pageNumber)
            
        let pageParameter = sut.urlParameters["page"]
            
        XCTAssertEqual(pageParameter, "\(pageNumber)")
    }

    func testGivenMovieRequest_WhenGettingRequestType_ThenGETIsReturned() {
        let sut = MoviesRequest()
        let requestType = sut.requestType
        XCTAssertEqual(requestType, .GET)
    }
}
