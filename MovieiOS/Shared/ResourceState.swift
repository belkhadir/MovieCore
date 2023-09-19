//
//  ResourceState.swift
//  MovieiOS
//
//  Created by Belkhadir Anas on 19/9/2023.
//

enum ResourceState<T: Equatable> {
    case none
    case loading
    case loaded(T)
    case failed(Error)
}

extension ResourceState: Equatable {
    static func == (lhs: ResourceState<T>, rhs: ResourceState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loading, .loading):
            return true
        case (.failed(let leftError), .failed(let rightError)):
            return leftError.localizedDescription == rightError.localizedDescription
        case (.loaded(let leftResource), .loaded(let rightResource)):
            return leftResource == rightResource
        default:
            return false
        }
    }
}
