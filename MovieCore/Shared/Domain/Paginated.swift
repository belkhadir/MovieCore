//
//  Page.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 22/9/2023.
//

public struct Paginated<Item: Equatable> {
    public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void

    public let items: [Item]
    public let page: Int
    public let totalPages: Int
    public let totalResults: Int
    public let loadMore: ((@escaping LoadMoreCompletion) -> Void)?
    
    public init(
        items: [Item],
        page: Int,
        totalPages: Int,
        totalResults: Int,
        loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil
    ) {
        self.items = items
        self.page = page
        self.totalPages = totalPages
        self.totalResults = totalPages
        self.loadMore = loadMore
    }
 }

// MARK: Extesion + Paginated
extension Paginated: Equatable {
    public static func == (lhs: Paginated<Item>, rhs: Paginated<Item>) -> Bool {
        lhs.items == rhs.items &&
        lhs.page == rhs.page &&
        lhs.totalPages == rhs.totalPages &&
        lhs.totalResults == rhs.totalResults
    }
}
