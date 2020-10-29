import Foundation

final class MainVC: NSObject {
    private func validateRequest(document: String,
                                 digest: String,
                                 type: String,
                                 completion: @escaping ((ValidationResponse?) -> ())) {
        let request = ApiRequestForIdentification(document: document,
                                                  digest: digest,
                                                  type: type)
        API.sendRequest(request: request) { result in
            switch result {
            case .success(let data):
                guard let config: ValidationResponse = JSONCodable.decode(fromData: data) else {
                    completion(nil)
                    return
                }
                
                completion(config)
            case .error(let error):
                print("🔴 failed parse ValidationResponse \(error)")
                completion(nil)
            }
        }
    }
}
