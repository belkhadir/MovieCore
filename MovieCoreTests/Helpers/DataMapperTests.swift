//
//  ImageDataMapperTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 21/9/2023.
//

import XCTest
import MovieCore

final class DataMapperTests: XCTestCase {
    func testGivenNon200HTTPResponses_WhenMappingAnyData_ThenThrowsError() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try DataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func testGivenEmptyDataAnd200HTTPResponse_WhenMapping_ThenThrowsInvalidDataError() {
        let emptyData = Data()

        XCTAssertThrowsError(
            try DataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }

    func testGivenNonEmptyDataAnd200HTTPResponse_WhenMapping_ThenReturnsReceivedData() throws {
        let nonEmptyData = Data("non-empty data".utf8)

        let result = try DataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, nonEmptyData)
    }
}
