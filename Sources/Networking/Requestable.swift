//
//  File.swift
//  
//
//  Created by Omran, Amr on 08.11.21.
//

import Foundation

public protocol Requestable {
    func makeRequest<T: Router>(route: T) throws -> URLRequest
}


public extension Requestable {
    
    func makeRequest<T>(route: T) throws -> URLRequest where T : Router {
        
        guard let url = URL(string: route.baseURL) else {
            throw NetworkingError.badURL
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.path = route.path
        urlComponents?.queryItems = route.queries
    
        guard let finalURL = urlComponents?.url else {
            throw NetworkingError.badPath
        }
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.allHTTPHeaderFields = route.headers
        urlRequest.httpMethod = route.method.rawValue
        if let body = route.parameter {
            do {
                let jsonEncoder = JSONEncoder()
                let encodable = AnyEncodable(body)
                let data = try jsonEncoder.encode(encodable)
                urlRequest.httpBody = data
                
            } catch {
                throw error
            }
        }
        
        return urlRequest
    }

}
