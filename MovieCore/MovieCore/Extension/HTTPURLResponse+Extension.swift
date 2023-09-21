//
//  HTTPURLResponse+Extension.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 21/9/2023.
//

import Foundation

extension HTTPURLResponse {
    var isOK: Bool {
        return statusCode == 200
    }
}
