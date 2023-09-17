//
//  RemoteMovieServiceProvider.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 17/9/2023.
//

import Foundation

public protocol NetworkServiceProviding {
    func perform(request: Requestable, completion: @escaping (Error) -> Void)
}

public final class RemoteMovieServiceProvider {
    private let request: Requestable
    private let networkService: NetworkServiceProviding
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(request: Requestable, networkService: NetworkServiceProviding) {
        self.request = request
        self.networkService = networkService
    }
    
    public func fetchMovies(completion: @escaping (Error) -> Void) {
        networkService.perform(request: request) { error in
            completion (.connectivity)
        }
    }
}
