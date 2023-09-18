//
//  NetworkServiceProviderTests.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import XCTest
import MovieCore

final class NetworkServiceProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolSub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolSub.stopInterceptingRequest()
    }
    
    func test_GivenStubbedError_WhenPerformingRequest_ThenReceivesCorrectError() {
        let anyURL = URL(string: "https://any-url.com")!
        let request = URLRequest(url: anyURL)
        let error = NSError(domain: "any error", code: 1)
        URLProtocolSub.stub(data: nil, response: nil, error: error)
        
        let sut = NetworkServiceProvider()
        
        let exp = expectation(description: "wait for completion")
         
        _ = makeSUT().perform(request: request) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expect to receive error \(error), but instead got result \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    func testGivenAnyURLRequest_WhenPerformingRequest_ThenCorrectRequestIsReceivedByURLProtocol() {
        let anyURL = URL(string: "https://any-url.com")!
        let  request = URLRequest(url: anyURL)
        
        let exp = expectation(description: "Wait for the request")
        URLProtocolSub.observeRequests { receivedRequest in
            XCTAssertEqual(receivedRequest.url, request.url)
            XCTAssertEqual(receivedRequest.httpMethod, request.httpMethod)
            exp.fulfill()
        }
        
        _ = makeSUT().perform(request: request) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Helpers
private extension NetworkServiceProviderTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> NetworkServiceProviding {
        let sut = NetworkServiceProvider()
        trackForMemoryLeaks(sut, file: file, line: line )
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file,
                         line: line)
        }
    }
    
    class URLProtocolSub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
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
            stub = nil
            requestObserver = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response,  error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
             return request
        }
        
        override func startLoading() {
            if let data = Self.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = Self.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
             
            if let error = Self.stub? .error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
