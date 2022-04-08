//
//  File.swift
//  
//
//  Created by Omran, Amr on 08.11.21.
//

import Foundation

public protocol Router {
    var baseURL: String { get }
    var path: String { get }
    var queries: [URLQueryItem]? { get }
    var parameter: Codable? { get }
    var headers: [String : String]? { get }
    var method: HttpMethod { get }
}
