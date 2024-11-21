import Foundation
import Network

public struct HTTPMethod: Hashable {
    public static let get = HTTPMethod(rawValue: "GET")
    public static let post = HTTPMethod(rawValue: "POST")

    public let rawValue: String
}

struct APIConfig {
    static let baseURL = Bundle.main.infoDictionary?["API_BASE_URL"] as? String ?? "http://localhost:3000"
    static let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String ?? "http://localhost:3000"
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
            switch statusCode {
            case 401:
                return "Unauthorized. Please check your API key."
            case 429:
                return "You have exceeded your monthly request limit."
            default:
                return "HTTP error with status code \(statusCode)."
            }
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
    private let monitor = NWPathMonitor()
    
    
    private init(session: URLSession = .shared) {
        self.session = session
        startNetworkMonitoring()
        
    }
    private func startNetworkMonitoring() {
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    private func handleError<T: Decodable>(_ response: URLResponse?, data: Data?, error: Error?, completion: @escaping CompletionHandler<T>) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NetworkError.noData))
            return
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if httpResponse.statusCode == 429 {
                completion(.failure(NetworkError.httpError(statusCode: httpResponse.statusCode)))
                return
            }
            
            if let data = data,
               let errorResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let errorCode = errorResponse["code"] as? Int,
               let errorInfo = errorResponse["info"] as? String {
                completion(.failure(NetworkError.potentialError(statusCode: errorCode, info: errorInfo)))
                return
            }
            
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
    
    private func request<T: Decodable>(_ endpoint: String, method: HTTPMethod, queryParams: QueryParameters? = nil, body: [String: Any]? = nil, completion: @escaping CompletionHandler<T>) {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status != .satisfied {
                completion(.failure(NetworkError.disconnected))
            }
        }
        
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
        
        guard var urlComponents = URLComponents(string: "https://" + APIConfig.baseURL + endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var queryItems = [URLQueryItem(name: "access_key", value: APIConfig.apiKey)]
        if let queryParams = queryParams {
            queryItems.append(contentsOf: queryParams.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Bearer \(APIConfig.apiKey)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            self.handleError(response, data: data, error: error, completion: completion)
        }
        task.resume()
    }
    
    func get<T: Decodable>(endpoint: String, queryParams: QueryParameters? = nil, completion: @escaping CompletionHandler<T>) {
        request(endpoint, method: .get, queryParams: queryParams, completion: completion)
    }
    
    func post<T: Decodable>(endpoint: String, queryParams: QueryParameters? = nil, body: [String: Any]? = nil, completion: @escaping CompletionHandler<T>) {
        request(endpoint, method: .post, queryParams: queryParams, body: body, completion: completion)
    }
}
