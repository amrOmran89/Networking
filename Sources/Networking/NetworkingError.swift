//
//  File.swift
//  
//
//  Created by Omran, Amr on 08.11.21.
//

import Foundation

public enum NetworkingError: Error {
    case badURL
    case badPath
    case badRequest
    case dataNotFound
    case serverResponse(Int)
}
