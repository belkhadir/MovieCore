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
        let anyRequest = anyRequest()
        
        let exp = expectation(description: "Wait for the request")
        
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
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        assertThat(receivedResult: receivedValues!, expectData: data, expectedHTTPResponse: response)
    }
    
    func testGivenValidHTTPResponse_And_NilData_WhenPerformingRequest_ThenSucceed () {
        let emptyData = Data()
        let response = anyHTTPResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        assertThat(receivedResult: receivedValues!, expectData: emptyData, expectedHTTPResponse: response)
    }
}

// MARK: - Helpers
private extension NetworkServiceProviderTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> NetworkServiceProviding {
        let sut = NetworkServiceProvider()
        trackForMemoryLeaks(sut, file: file, line: line )
        return sut
    }
    
    func assertThat(receivedResult: (data: Data, response: HTTPURLResponse), expectData: Data, expectedHTTPResponse: HTTPURLResponse, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(receivedResult.data, expectData)
        XCTAssertEqual(receivedResult.response.url, expectedHTTPResponse.url)
        XCTAssertEqual(receivedResult.response.statusCode, expectedHTTPResponse.statusCode)
    }
    
    func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) ->  (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        let sut = makeSUT(file: file, line: line  )
        
        switch result {
            case let .success((data, response)):
                return (data, response)
            default:
                XCTFail("Expect result but got error instead", file: file, line: line)
                return nil
        }
    }
    
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
            case .failure(let error):
                return error
            default:
                XCTFail("Expect an error but instead got result \(result)", file: file, line: line)
                return nil
        }
    }
    
    func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) ->  NetworkServiceProviding.Result {
        URLProtocolSub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line )
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: NetworkServiceProviding.Result!
        sut.perform(request: anyRequest()) { result in
            receivedResult = result
            exp.fulfill()
        }
         
        wait(for: [exp], timeout: 1.0)
        return receivedResult
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
