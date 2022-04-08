//
//  File.swift
//  
//
//  Created by Omran, Amr on 09.11.21.
//

import Foundation

public enum NetworkResult<T: Codable> {
    case success(T)
    case failure(Error)
    case loading
    case idle
}
