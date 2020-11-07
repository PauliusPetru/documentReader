import Foundation

final class MainVM: ViewModel {
    
    typealias OutputHandler = (Output) -> Void
    
    enum Input {
        case receivedCard(String)
    }
    enum Output {
        case cardInformation(ValidationResponse)
        case receiveError(String)
    }
    
    var outputHandler: OutputHandler?
    
    func handle(input: Input) {
        
        switch input {

        case .receivedCard(let mrz):
            validateRequest(mrz: mrz)
        }
    }
    
    private func validateRequest(mrz: String) {
        let request = ApiRequestForIdentification(document: mrz.toBase64,
                                                  digest: mrz.sha1,
                                                  type: "lt_pass_rev")
        API.sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let response: ValidationResponse = JSONCodable.decode(fromData: data) else {
                    self?.outputHandler?(.receiveError("failed to devode"))
                    return
                }
                self?.outputHandler?(.cardInformation(response))

            case .error(let error):
                print("🔴 failed parse ValidationResponse \(error)")
                self?.outputHandler?(.receiveError(error.description))
            }
        }
    }
}
