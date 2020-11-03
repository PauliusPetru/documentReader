import UIKit

final class CameraVC: UIViewController {
    
    @IBOutlet weak private var cameraView: CameraView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    
    private var cameraVM: CameraVM?
    var onMrzDetected: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraVM = CameraVM()
        cameraView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraVM = nil
    }
    
    private func handleScanned(image: CGImage) {
        let textsArray = cameraVM?.generateText(from: image)
        //would be great to have greater validation :D
        let MRZtexts = textsArray?.filter { $0.contains("<<") } ?? []
        guard MRZtexts.count == 2 else { return }
        onMrzDetected?(MRZtexts.joined())
        dismiss(animated: true, completion: nil)
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
        handleScanned(image: image)
    }
}
