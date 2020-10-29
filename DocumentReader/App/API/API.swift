import Foundation
import Alamofire

struct API {
    enum Result {
        case success(Data)
        case error(Data)
    }
    
    static var baseUrl = "https://api.identiway.com/"
    
    static func sendRequest(request: RequestConfig, completionHandler: @escaping (Result) -> ()) {
        AF.request(request).validate().responseData { responseData in
            switch responseData.result {
            case .success(let data):
                completionHandler(.success(data))
            case .failure(let error):
                //TODO: some fancy error handling
                print("🔴 \(error.localizedDescription)")
            }
        }
    }
}
