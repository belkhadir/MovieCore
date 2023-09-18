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
    
    func testGivenAnyURLRequest_WhenPerformingRequest_ThenCorrectRequestIsReceivedByURLProtocol() {
        let exp = expectation(description: "Wait for the request")
        let anyRequest = anyRequest()
        
        URLProtocolSub.observeRequests { receivedRequest in
            XCTAssertEqual(receivedRequest.url, anyRequest.url)
            XCTAssertEqual(receivedRequest.httpMethod, anyRequest.httpMethod)
            exp.fulfill()
        }
        
        _ = makeSUT().perform(request: anyRequest ) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_GivenStubbedError_WhenPerformingRequest_ThenReceivesCorrectError() {
        let error = anyError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as? NSError
        
         
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
     
    func testGivenVariousInvalidInputs_WhenPerformingRequest_ThenAlwaysReceiveError() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse() , error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse (), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: nil))
    }
    
    func testGivenValidHTTPResponse_And_data_WhenPerformingRequest_ThenSucceed() {
        let data = anyData()
        let response = anyHTTPResponse()
        URLProtocolSub.stub(data: data , response: response, error: nil)
        
        let exp = expectation(description: "Wait for completion")
        makeSUT().perform(request:  anyRequest()) { result in
            switch result {
            case let .success((receivedData, receivedHTTPResponse)):
                XCTAssertEqual(receivedData, data)
                XCTAssertEqual(receivedHTTPResponse.url, response.url)
                XCTAssertEqual(receivedHTTPResponse.statusCode, response.statusCode )
            default:
                XCTFail("Expect result success but got result \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func testGivenValidHTTPResponse_And_NilData_WhenPerformingRequest_ThenSucceed () {
        let response = anyHTTPResponse()
        URLProtocolSub.stub(data: nil , response: response, error: nil)
        
        let exp = expectation(description: "Wait for completion")
        makeSUT().perform(request:  anyRequest()) { result in
            switch result {
            case let .success((receivedData, receivedHTTPResponse)):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedHTTPResponse.url, response.url)
                XCTAssertEqual(receivedHTTPResponse.statusCode, response.statusCode )
            default:
                XCTFail("Expect result success but got result \(result)")
            }
            exp.fulfill()
        }
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
    
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolSub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line )
        let exp = expectation(description: "Wait for completion")
        
        var receivedError: Error?
        sut.perform(request: anyRequest()) { result in
            switch result {
                case .failure(let error):
                    receivedError = error
                default:
                    XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
         
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    func anyRequest() -> URLRequest {
        URLRequest(url: anyURL())
    }
    
    func nonHTTPResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(statusCode: 200)
    }
    
    func anyData() -> Data {
        Data("any data".utf8)
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 1)
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
