//
//  RemoteMovieServiceProvider.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import Foundation

public protocol CancelableTask {
    func cancel()
}

public protocol NetworkService {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func perform(request: URLRequest, completion: @escaping (Result) -> Void) -> CancelableTask
}
