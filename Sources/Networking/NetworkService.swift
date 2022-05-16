import Foundation
import Combine

public class NetworkService<R: Router>: Requestable {
    
    public init() {}

    
    public func fetch(router: R, decoder: JSONDecoder = JSONDecoder(), compilation: @escaping (Result<Codable, Error>) -> Void) where R: Router {
        do {
            let request = try makeRequest(route: router)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let res = response as? HTTPURLResponse, res.statusCode != 200 {
                    return compilation(.failure(NetworkingError.serverResponse(res.statusCode)))
                }
                
                guard let data = data else {
                    return compilation(.failure(NetworkingError.dataNotFound))
                }
                
                do {
                    let json = try decoder.decode(router.type.self, from: data)
                    compilation(.success(json))
                } catch {
                    return compilation(.failure(error))
                }
                
            }.resume()
            
        } catch {
            return compilation(.failure(error))
        }
    }
    
    
    public func fetch(router: R, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<R.T, Error> where R: Router {
        
        do {
            let request = try makeRequest(route: router)
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data: Data, res: URLResponse) in
                    if let response = res as? HTTPURLResponse, !(200...210).contains(response.statusCode) {
                        throw NetworkingError.serverResponse(response.statusCode)
                    }
                    return data
                }
                .decode(type: router.type.self, decoder: decoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    
    public func fetch(router: R, decoder: JSONDecoder = JSONDecoder()) async throws -> Codable where R: Router {
        
        do {
            let request = try makeRequest(route: router)
            let (data, res) = try await URLSession.shared.data(for: request, delegate: nil)
            
            if let response = res as? HTTPURLResponse, !(200...210).contains(response.statusCode) {
                throw NetworkingError.serverResponse(response.statusCode)
            }
            
            let json = try decoder.decode(router.type.self, from: data)
            return json
        } catch {
            throw error
        }
    }
}
