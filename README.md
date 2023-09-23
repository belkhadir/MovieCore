## README for MovieCore Framework

---

### Overview

The `MovieCore` framework provides a convenient and structured approach to fetch movie data from an external API. The framework handles network requests, response parsing, and data mapping seamlessly, returning structured movie data to be used in applications.

---

### Key Components

- **NetworkService**: Manages network tasks with features like canceling ongoing tasks.
- **MoviesMapper**: Handles the decoding and mapping of movie data.
- **MoviesRequest**: Facilitates the creation of movie-related API requests.

---

### Getting Started

To get started, you'll need to set up the networking layer with the `NetworkService` and define the type of request you'd like to make using `MoviesRequest`.

#### 1. Setting up the NetworkService

```swift
let networkService = DefaultNetworkService()
```

#### 2. Creating a Movie Request
Fetch popular movies on page 1:

```swift
let movieRequest = MoviesRequest(movieDiscover: .popular, page: 1)
```

#### 3. Performing the Request
```swift
let task = networkService.execute(request: movieRequest.toURLRequest()) { result in
    switch result {
    case let .success((data, _)):
        do {
            let movies = try MoviesMapper.map(json: data, httpResponse: response)
            print(movies.items) // Access the fetched movies
        } catch {
            print("Error mapping movies: \(error)")
        }
    case let .failure(error):
        print("Network error: \(error)")
    }
}
```
