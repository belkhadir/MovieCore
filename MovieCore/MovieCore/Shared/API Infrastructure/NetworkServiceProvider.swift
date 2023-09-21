//
//  NetworkServiceProvider.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import Foundation

public final class NetworkServiceProvider {
    private let session: URLSession
    
    private struct URLSessionTaskWrapper: NetworkServiceTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
}

// MARK: - NetworkServiceProviding
extension NetworkServiceProvider: NetworkServiceProviding {
    public func perform(request: URLRequest, completion: @escaping (NetworkServiceProviding.Result) -> Void) -> NetworkServiceTask {
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
