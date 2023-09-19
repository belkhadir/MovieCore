//
//  MoviesListViewModel.swift
//  MovieiOS
//
//  Created by Belkhadir Anas on 19/9/2023.
//

import MovieCore
import SwiftUI

protocol ResourceLoadable {
    associatedtype Resource: Equatable
    
    var state: ResourceState<Resource> { get }
    func loadResource()
}

final class ResourceViewModel<ResourceProvider: ResourceProviding>: ObservableObject where ResourceProvider.Resource: Equatable  {
    typealias Resource = ResourceProvider.Resource
    
    private let resourceProvider: ResourceProvider
    
    @Published private(set) var state: ResourceState<Resource> = .none
    
    init(resourceProvider: ResourceProvider) {
        self.resourceProvider = resourceProvider
    }
}

// MARK: - ResourceLoadable
extension ResourceViewModel: ResourceLoadable {
    func loadResource() {
        state = .loading
        resourceProvider.fetchResource { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let resource):
                self.state = .loaded(resource)
            case .failure(let error):
                self.state = .failed(error)
            }
        }
    }
}
