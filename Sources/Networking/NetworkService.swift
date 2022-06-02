import Foundation
import Combine

public class NetworkService<R: Router>: Requestable {
    
    public init() {}

    
    public func fetch<T: Codable>(router: R, decoder: JSONDecoder = JSONDecoder(), compilation: @escaping (Result<T?, Error>) -> Void) where R: Router {
        do {
            let request = try makeRequest(route: router)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let res = response as? HTTPURLResponse, res.statusCode != 200 {
                    compilation(.failure(NetworkingError.serverResponse(res.statusCode)))
                }
                
                guard let data = data else {
                    compilation(.failure(NetworkingError.dataNotFound))
                    return
                }
                
                if router.method == .delete || router.method == .post {
                    compilation(.success(nil))
                }
                
                do {
                    let json = try decoder.decode(T.self, from: data)
                    compilation(.success(json))
                } catch {
                    compilation(.failure(error))
                }
                
            }.resume()
            
        } catch {
            compilation(.failure(error))
        }
    }
    
    
    public func fetch<T: Codable>(router: R, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T?, Error> where R: Router {
        
        do {
            let request = try makeRequest(route: router)
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data: Data, res: URLResponse) in
                    if let response = res as? HTTPURLResponse, !(200...210).contains(response.statusCode) {
                        throw NetworkingError.serverResponse(response.statusCode)
                    }
                    if router.method == .delete || router.method == .post {
                        return nil
                    }
                    return try decoder.decode(T.self, from: data)
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    
    public func fetch<T: Codable>(router: R, decoder: JSONDecoder = JSONDecoder()) async throws -> T? where R: Router {
        
        do {
            let request = try makeRequest(route: router)
            let (data, res) = try await URLSession.shared.data(for: request, delegate: nil)
            
            if let response = res as? HTTPURLResponse, !(200...210).contains(response.statusCode) {
                throw NetworkingError.serverResponse(response.statusCode)
            }
            
            if router.method == .delete || router.method == .post {
                return nil
            }

            let json = try decoder.decode(T.self, from: data)
            return json
        } catch {
            throw error
        }
    }
    
}
