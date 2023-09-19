//
//  ResourceProviding.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 19/9/2023.
//

public protocol ResourceProviding {
    associatedtype Resource
    
    typealias Result = Swift.Result<Resource, Error>
    
    func fetchResource(completion: @escaping (Result) -> Void)
}
