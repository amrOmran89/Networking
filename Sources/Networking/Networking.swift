import Foundation
import Combine

public class Network<R: Router>: Requestable {
    
    public init() {}
    
    public func fetch<T>(url: URL,
                         decoder: JSONDecoder = JSONDecoder(),
                         compilation: @escaping (Result<T, Error>) -> Void) where T: Codable {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return compilation(.failure(NetworkingError.dataNotFound))
            }
            
            do {
                let json = try decoder.decode(T.self, from: data)
                compilation(.success(json))
            } catch {
                return compilation(.failure(error))
            }
            
        }.resume()
    }
    
    public func fetch<T>(router: R,
                         decoder: JSONDecoder = JSONDecoder(),
                         compilation: @escaping (Result<T, Error>) -> Void) where T : Decodable, T : Encodable, R : Router {
        do {
            let request = try makeRequest(route: router)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    return compilation(.failure(NetworkingError.dataNotFound))
                }
                
                do {
                    let json = try decoder.decode(T.self, from: data)
                    compilation(.success(json))
                } catch {
                    return compilation(.failure(error))
                }
                
            }.resume()
            
        } catch {
            return compilation(.failure(error))
        }
    }
    
    public func fetch<T: Codable>(url: URL, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        URLSession
            .shared
            .dataTaskPublisher(for: url)
            .tryMap { (data: Data, res: URLResponse) in
                if let response = res as? HTTPURLResponse, response.statusCode != 200 {
                    throw NetworkingError.serverResponse(response.statusCode)
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    
    public func fetch<T>(router: R, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> where T : Codable, R : Router {
        
        do {
            let request = try makeRequest(route: router)
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data: Data, res: URLResponse) in
                    if let response = res as? HTTPURLResponse, response.statusCode != 200 {
                        throw NetworkingError.serverResponse(response.statusCode)
                    }
                    return data
                }
                .decode(type: T.self, decoder: decoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    
    public func fetch<T: Codable>(url: URL, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        do {
            let (data, res) = try await URLSession.shared.data(from: url, delegate: nil)
            if let response = res as? HTTPURLResponse, response.statusCode != 200 {
                throw NetworkingError.serverResponse(response.statusCode)
            }
            
            let json = try decoder.decode(T.self, from: data)
            return json
        } catch {
            throw error
        }
    }
    
    
    public func fetch<T: Codable>(router: R, decoder: JSONDecoder = JSONDecoder()) async throws -> T where R : Router {
        
        do {
            let request = try makeRequest(route: router)
            let (data, res) = try await URLSession.shared.data(for: request, delegate: nil)
            
            if let response = res as? HTTPURLResponse, response.statusCode != 200 {
                throw NetworkingError.serverResponse(response.statusCode)
            }
            
            let json = try decoder.decode(T.self, from: data)
            return json
        } catch {
            throw error
        }
    }
}