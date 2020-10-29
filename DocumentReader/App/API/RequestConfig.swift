import Foundation
import Alamofire

protocol RequestConfig: URLRequestConvertible {
    var host: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var headers: [String: String] { get }
    var params: Parameters? { get }
    
    func asURLRequest() throws -> URLRequest
}

extension RequestConfig {
    var host: String {
        return API.baseUrl
    }
    
    var headers: [String: String] {
        let headers = ["Content-type": "application/json",
                       "x-api-key": "4fdhRNyzqs6nY2NNRXcIz9kfNSJMg13y2oSepE9d"]
        
        return headers
    }
    
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: host + path) else {
            throw CommonError.customError("failed to create url")
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.timeoutInterval = 45

        if method == .get {
            return try URLEncoding.queryString.encode(urlRequest, with: params)
        } else {
            return try JSONEncoding.default.encode(urlRequest, with: params)
        }
    }
}
