//
//  ImageDataMapperTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 23/9/2023.
//

import XCTest
import MovieCore

final class ImageRequestTests: XCTestCase {
    func testGivenImagePath_WhenGettingPath_ThenCorrectPathIsConstructed() {
        let givenImagePath = "/sample.jpg"
        let sut = ImageRequest(imagePath: givenImagePath)
        let resultPath = sut.path
        
        XCTAssertEqual(resultPath, "/t/p/w200/sample.jpg")
    }

    func testGivenImageRequest_WhenGettingHost_ThenDefaultHostIsReturned() {
        let sut = ImageRequest(imagePath: "/sample.jpg")
        let host = sut.host
        
        XCTAssertEqual(host, "image.tmdb.org")
    }

    func testGivenImageRequest_WhenGettingRequestType_ThenGETIsReturned() {
        let sut = ImageRequest(imagePath: "/sample.jpg")
        let requestType = sut.requestType
        
        XCTAssertEqual(requestType, .GET)
    }
}
