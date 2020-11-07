import UIKit
import AVKit

final class ViewController: UIViewController {
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var secondNameLabel: UILabel!
    @IBOutlet private weak var isValidLabel: UILabel!
    
    internal var viewModel: MainVM?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainVM()
        bind(viewModel: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //access camera. Should be more "magic" if user do not give access
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { _ in }
    }
    
    private func validateCardInfo(_ mrz: String) {
        viewModel?.handle(input: .receivedCard(mrz))
    }
    
    private func representInfo(validationResponse: ValidationResponse) {
        nameLabel.text = validationResponse.data.firstName
        secondNameLabel.text = validationResponse.data.lastName
        isValidLabel.text = "\(validationResponse.data.documentValid)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
//        (segue.destination as? CameraVC)?.onMrzDetected = { [weak self] mrz in
//            self?.validateCardInfo(mrz)
//        }
    }
}

extension ViewController: Bindable {
    func bind(viewModel: MainVM?) {
        let outputHandler: MainVM.OutputHandler = { output in
            switch output {
            case .cardInformation(let response):
                self.representInfo(validationResponse: response)
            case .receiveError(let error):
                print(error)
            }
        }
        viewModel?.outputHandler = outputHandler
        self.viewModel = viewModel
    }
}
