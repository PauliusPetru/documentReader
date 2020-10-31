import UIKit
import QKMRZScanner
import QKMRZParser

final class CameraVC: UIViewController, QKMRZScannerViewDelegate {
    @IBOutlet weak var mrzScannerView: QKMRZScannerView!
    
    var onScanSuccess: ((QKMRZScanResult) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mrzScannerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mrzScannerView.startScanning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mrzScannerView.stopScanning()
    }

    func mrzScannerView(_ mrzScannerView: QKMRZScannerView, didFind scanResult: QKMRZScanResult) {
        onScanSuccess?(scanResult)
        dismiss(animated: true, completion: nil)
    }
}
