//
//  NetworkServiceProviderTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import XCTest
import MovieCore

final class RemoteMovieServiceProviderTests: XCTestCase {
    private let mockRequest = MockRequest()
    
    func test_init_doesNotRequestDataFromRequestable() {
        let (client, _) = makeSUT(request: mockRequest)
        
        XCTAssertTrue(client.requests.isEmpty)
    }

    func test_fetchMovies_requestDataFromRequestable() {
        let (client, sut) = makeSUT(request: mockRequest)
        
        sut.fetchMovies() { _ in  }
        
        XCTAssertEqual(client.requests as? [MockRequest], [mockRequest])
    }
    
    func test_fetchMovies_deliversErrorOnClientError() {
        let (client, sut) = makeSUT(request: mockRequest)
        
        var capturedErrors = [RemoteMovieServiceProvider.Error]()
        sut.fetchMovies { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Any error", code: 1)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
}

// MARK: - Helpers
private extension RemoteMovieServiceProviderTests {
    func makeSUT(request: Requestable) -> (client: NetworkServiceProviderSpy, RemoteMovieServiceProvider) {
        let client = NetworkServiceProviderSpy()
        let sut = RemoteMovieServiceProvider(request: request, networkService: client)
        return (client, sut)
    }
    
    
    final class NetworkServiceProviderSpy: NetworkServiceProviding {
        private var messages = [(request: Requestable, completion: (Error) -> Void)]()
        var requests: [Requestable] {
            messages.map { $0.request }
        }
        
        func perform(request: Requestable, completion: @escaping (Error) -> Void) {
            messages.append((request, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }
}

// MARK: - Requestable+Equatable
extension Requestable where Self: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        let lhsRequest = try! lhs.createURLRequest()
        let rhsRequest = try! rhs.createURLRequest()
        return lhsRequest == rhsRequest
    }
}
