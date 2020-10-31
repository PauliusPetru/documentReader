import UIKit
import AVKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //access camera. Should be more "magic" if user do not give access
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { _ in }
    }
}
