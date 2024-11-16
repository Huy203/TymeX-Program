import Foundation
import Network

public struct HTTPMethod: Hashable {
    public static let get = HTTPMethod(rawValue: "GET")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    public static let delete = HTTPMethod(rawValue: "DELETE")

    public let rawValue: String
}

struct APIConfig {
    static let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:3000"
    static let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String ?? ""
}

public enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(statusCode: Int)
    case disconnected
    case potentialError(statusCode: Int, info: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError(let error):
            return error.localizedDescription
        case .httpError(let statusCode):
            if statusCode == 401 {
                return "Unauthorized. Please check your API key."
            }
            return "HTTP error with status code \(statusCode)."
        case .disconnected:
            return "No internet connection."
        case .potentialError(_, let info):
            return info
        }
    }
}

typealias QueryParameters = [String: String]
typealias CompletionHandler<T> = (Result<T, Error>) -> Void

class API {
    static let shared = API()
    private let session: URLSession
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    private func request<T: Decodable>(_ endpoint: String, method: HTTPMethod, queryParams: QueryParameters? = nil, body: [String: Any]? = nil, completion: @escaping CompletionHandler<T>) {
        
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                completion(.failure(NetworkError.disconnected))
            }
        }

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
        
        guard var urlComponents = URLComponents(string: APIConfig.baseURL + endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Add query parameters
        var queryItems = [URLQueryItem(name: "access_key", value: APIConfig.apiKey)]
        if let queryParams = queryParams {
            queryItems.append(contentsOf: queryParams.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Header
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Bearer \(APIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
           request.httpBody = try? JSONSerialization.data(withJSONObject: body)
           request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
             if let error = error {
                 completion(.failure(error))
                 return
             }
             
             guard let httpResponse = response as? HTTPURLResponse else {
                 completion(.failure(NetworkError.noData))
                 return
             }
            
            if let data = data,
               let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let errorCode = errorResponse["code"] as? Int,
               let errorInfo = errorResponse["info"] as? String {
                completion(.failure(NetworkError.potentialError(statusCode: errorCode, info: errorInfo)))
                return
            }
             
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
             
             guard let data = data else {
                 completion(.failure(NetworkError.noData))
                 return
             }
             
             do {
                 let decoded = try JSONDecoder().decode(T.self, from: data)
                 completion(.success(decoded))
             } catch {
                 completion(.failure(NetworkError.decodingError(error)))
             }
         }
        task.resume()
    }

    func get<T: Decodable>(endpoint: String, queryParams: QueryParameters? = nil, completion: @escaping CompletionHandler<T>) {
        request(endpoint, method: HTTPMethod.get, queryParams: queryParams, completion: completion)
    }

    func post<T: Decodable>(endpoint: String, queryParams: QueryParameters? = nil, body: [String: Any]? = nil, completion: @escaping CompletionHandler<T>) {
        request(endpoint, method: HTTPMethod.post, queryParams: queryParams, completion: completion)
    }

    func put<T: Decodable>(endpoint: String, queryParams: QueryParameters? = nil, body: [String: Any]? = nil, completion: @escaping CompletionHandler<T>) {
        request(endpoint, method: HTTPMethod.put, queryParams: queryParams, completion: completion)
    }

    func delete<T: Decodable>(endpoint: String, queryParams: QueryParameters? = nil, completion: @escaping CompletionHandler<T>) {
        request(endpoint, method: HTTPMethod.delete, queryParams: queryParams, completion: completion)
    }
}
