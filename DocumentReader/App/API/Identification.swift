import Foundation
import Alamofire

struct ApiRequestForIdentification: RequestConfig {
    var method = HTTPMethod.post
    var path = "docs/validate"
    var params: Parameters?
    
    //TODO: Type should be enum maybe :thinking_face:
    init(document: String, digest: String, type: String) {
        params = ["document": document,
                  "digest": digest,
                  "type": type]
    }
}
