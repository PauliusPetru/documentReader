import Foundation

final class MainVM: NSObject {
    func validateRequest(mrz: String, completion: @escaping ((ValidationResponse?) -> ())) {
        let request = ApiRequestForIdentification(document: mrz.toBase64,
                                                  digest: mrz.sha1,
                                                  type: "lt_pass_rev")
        API.sendRequest(request: request) { result in
            switch result {
            case .success(let data):
                guard let response: ValidationResponse = JSONCodable.decode(fromData: data) else {
                    completion(nil)
                    return
                }
                
                completion(response)
            case .error(let error):
                print("🔴 failed parse ValidationResponse \(error)")
                completion(nil)
            }
        }
    }
}
