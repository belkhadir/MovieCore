//
//  SharedTestHelpers.swift
//  MovieCoreTests
//
//  Created by Belkhadir Anas on 13/9/2023.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://anyURL.com")!
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
