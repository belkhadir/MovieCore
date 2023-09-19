//
//  ResourceViewModelTests.swift
//  MovieiOSTests
//
//  Created by Belkhadir Anas on 19/9/2023.
//

import XCTest
@testable import MovieiOS

final class ResourceViewModelTests: XCTestCase {

    func testGivenInitialState_WhenInitialized_ThenStateIsNone() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.state, .none)
    }
    
    func testGivenLoadingState_WhenLoadingResource_ThenStateIsLoading() {
        assertThat(givenResult: nil, expectedState: .loading)
    }
    
    func testGivenFailedState_WhenFetchFails_ThenStateIsFailed() {
        let anyError = NSError(domain: "Any error", code: 1)
        
        assertThat(givenResult: .failure(anyError), expectedState: .failed(anyError))
    }

    func testGivenLoadedState_WhenFetchSuccessful_ThenStateIsLoaded() {
        let result = "Any string data"
        
        assertThat(givenResult: .success(result), expectedState: .loaded(result))
    }
    
    func testNoRetainCycle() {
        var sut: ResourceViewModel<MockResourceProvider>? = makeSUT().sut
        weak var weakSUT = sut
        
        sut?.loadResource()
        
        sut = nil
        
        XCTAssertNil(weakSUT)
    }
}

// MARK: - Helpers
private extension ResourceViewModelTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ResourceViewModel<MockResourceProvider>, resource: MockResourceProvider) {
        let resource = MockResourceProvider()
        let viewModel = ResourceViewModel(resourceProvider: resource)
        trackForMemoryLeaks(resource, file: file, line: line)
        trackForMemoryLeaks(viewModel, file: file, line: line)
        return (viewModel, resource)
    }
    
    func assertThat(givenResult: Result<String, Error>?, expectedState: ResourceState<String>, file: StaticString = #file, line: UInt = #line) {
        let (sut, resource) = makeSUT()
        resource.stubbedResult = givenResult
        sut.loadResource()
        XCTAssertEqual(sut.state, expectedState)
    }
}
