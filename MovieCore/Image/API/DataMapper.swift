//
//  ImageMapper.swift
//  MovieCore
//
//  Created by Belkhadir Anas on 21/9/2023.
//

import Foundation

public final class DataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}
