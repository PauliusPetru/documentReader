import UIKit
import AVKit

final class ViewController: UIViewController {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var secondNameLabel: UILabel!
    @IBOutlet private weak var isValidLabel: UILabel!
    
    private var mainVM: MainVM?

    override func viewDidLoad() {
        super.viewDidLoad()
        mainVM = MainVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //access camera. Should be more "magic" if user do not give access
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { _ in }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainVM = nil
    }
    
    private func validateCardInfo(_ mrz: String) {
        mainVM?.validateRequest(mrz: mrz) { [weak self] response in
            guard let response = response else { return }
            self?.representInfo(validationResponse: response)
        }
    }
    
    private func representInfo(validationResponse: ValidationResponse) {
        nameLabel.text = validationResponse.data.firstName
        secondNameLabel.text = validationResponse.data.lastName
        isValidLabel.text = "\(validationResponse.data.documentValid)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        (segue.destination as? CameraVC)?.onMrzDetected = { [weak self] mrz in
            self?.validateCardInfo(mrz)
        }
    }
}
