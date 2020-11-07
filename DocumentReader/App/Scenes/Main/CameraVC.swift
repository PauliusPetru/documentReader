import UIKit
import AVKit

final class CameraVC: UIViewController {
    
    @IBOutlet weak private var cameraView: CameraView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var torchButton: UIButton!
    
    internal var viewModel: CameraVM?
    var onMrzDetected: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CameraVM()
        bind(viewModel: viewModel)
        cameraView.delegate = self
    }
    
    private func toogleTorch() {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if device?.hasTorch ?? false {
            try? device?.lockForConfiguration()
            device?.torchMode = .on
        }
    }
}

extension CameraVC: CameraViewDelegate {
    func processed(image: CGImage) {
        viewModel?.handle(input: .scanned(image))
    }
}

extension CameraVC: Bindable {
    
    func bind(viewModel: CameraVM?) {
        let outputHandler: CameraVM.OutputHandler = { output in
            switch output {
            case .processed(let mrz):
                self.onMrzDetected?(mrz)
                asyncOnMain {
                    self.dismiss(animated: true, completion: nil)
                }
            case .turnTorch:
                asyncOnMain {
                    self.toogleTorch()
                }
            }
        }
        viewModel?.outputHandler = outputHandler
        self.viewModel = viewModel
    }
}
