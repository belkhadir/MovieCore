//
//  LoadResourceView.swift
//  MovieiOS
//
//  Created by Belkhadir Anas on 19/9/2023.
//

import SwiftUI

struct LoadResourceView<ViewModel: ResourceLoadable & ObservableObject >: View {
    @ObservedObject private var viewModel: ViewModel
    typealias ResourceView = (ViewModel.Resource) -> AnyView
    typealias ErrorView = (Error) -> AnyView
    
    private let view: ResourceView
    private let errorView: ErrorView
    
    init(
        viewModel: ViewModel,
        view: @escaping ResourceView,
        errorView: @escaping ErrorView
    ) {
        self.viewModel = viewModel
        self.view = view
        self.errorView = errorView
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
                case .loading:
                    ProgressView {
                        Text("Loading...")
                    }
                case .loaded(let resource):
                    view(resource)
                case .failed(let error):
                    errorView(error)
                case .none:
                    Text("No data to present")
            }
        }.onAppear(perform: { viewModel.loadResource() })
    }
}

struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        let resource = MockResourceProvider()
        let viewModel = ResourceViewModel(resourceProvider: resource)

        return LoadResourceView(
            viewModel: viewModel,
            view: { movies in
                AnyView(
                    List {
                        ForEach(movies, id: \.self) { movie in
                            Text("Movies Here, title: \(movie)")
                        }
                    }
                )
            },
            errorView: { _ in
                AnyView(GenericAlertView(
                    title: "Title",
                    description: "Descrption",
                    buttonText: "Tap me!",
                    buttonAction: { print("me") }))
            }
        )
    }
    
    private final class MockResourceProvider: ResourceProviding {
        typealias Resource = [String]
        
        func fetchResource(completion: @escaping (Result<Resource, Error>) -> Void) {
            completion(.success(["Anas", "Belkhadir", "Coucou", "Foufou"]))
        }
    }
}
