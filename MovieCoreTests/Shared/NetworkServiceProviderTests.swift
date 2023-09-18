//
//  NetworkServiceProviderTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import XCTest
import MovieCore

final class NetworkServiceProviderTests: XCTestCase {

    func test_perforRequest_failsOnRequestError() {
        URLProtocolSub.startInterceptingRequests()
        let anyURL = URL(string: "https://any-url.com")!
        let request = URLRequest(url: anyURL)
        let error = NSError(domain: "any error", code: 1)
        URLProtocolSub.stub(request: request, data: nil, response: nil, error: error)
        
        let sut = NetworkServiceProvider()
        
        let exp = expectation(description: "wait for completion")
         
        _ = sut.perform(request: request) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expect to receive error but instead got result \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolSub.stopInterceptingRequest()
    }

}

// MARK: - Helpers
private extension NetworkServiceProviderTests {
    class URLProtocolSub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(self)
        }
        
        static func stopInterceptingRequest () {
            URLProtocol.unregisterClass(self)
            stubs = [:]
        }
        
        static func stub(request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
            let url = request.url!
            Self.stubs[url] = Stub(data: data, response: response,  error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return Self.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
             return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = Self.stubs[url] else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
