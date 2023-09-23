//
//  NetworkServiceProvider.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import Foundation

public final class DefaultNetworkService {
    private let session: URLSession
    
    private struct URLSessionTaskAdapter: CancelableTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }
    
    private struct UnexpectedResponseError: Error {}
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - NetworkService
extension DefaultNetworkService: NetworkService {
    public func perform(request: URLRequest, completion: @escaping (NetworkService.Result) -> Void) -> CancelableTask {
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedResponseError()
                }
            })
        }
        task.resume()
        return URLSessionTaskAdapter(wrapped: task)
    }
}
