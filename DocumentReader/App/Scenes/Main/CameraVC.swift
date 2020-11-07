import UIKit

final class CameraVC: UIViewController {
    
    @IBOutlet weak private var cameraView: CameraView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!

    internal var viewModel: CameraVM?
    var onMrzDetected: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CameraVM()
        bind(viewModel: viewModel)
        cameraView.delegate = self
    }
    
    //TODO: Here should be all the magic about better image recognising
    //convert to grayscale and calculate is it have more then half of it black
    //if yes suggest to turn on flash light //flashLightButton.isHidden = false
    //Would be nice to create some fancy torch level automatic calculation
    //if flashlightIsOn
    //if more than half pixels are white - shut down level of flashLight torch
    //if more then half pixels are black - increase level of flashLight torch
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
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        viewModel?.outputHandler = outputHandler
        self.viewModel = viewModel
    }
}
