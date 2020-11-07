import UIKit
import AVFoundation
import Vision

final class CameraVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let requestHandler = VNSequenceRequestHandler()
    private var rectangleDrawing: CAShapeLayer?
    private var documentRectangleObservation: VNRectangleObservation?
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = .resizeAspect
        return preview
    }()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    // MARK: - Instance dependencies
    
    private let resultsHandler: ((String) -> ())? = nil
        
    override func loadView() {
        self.view = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCaptureSession()
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        DispatchQueue.main.async {
            self.rectangleDrawing?.removeFromSuperlayer() // removes old rectangle drawings
        }
        if let documentRectangleObservation = self.documentRectangleObservation {
            self.handleObservedDocument(documentRectangleObservation, in: frame)
        } else if let documentRectangleObservation = self.detectDocument(frame: frame) {
            self.documentRectangleObservation = documentRectangleObservation
        }
    }
    
    // MARK: - Camera setup
    
    private func setupCaptureSession() {
        self.addCameraInput()
        self.addPreviewLayer()
        self.addVideoOutput()
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.default(for: .video),
              let cameraInput = try? AVCaptureDeviceInput(device: device) else { return }
        self.captureSession.addInput(cameraInput)
    }
    
    private func addPreviewLayer() {
        self.view.layer.addSublayer(self.previewLayer)
    }
    
    private func addVideoOutput() {
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):
                                            NSNumber(value: kCVPixelFormatType_32BGRA)] as [String: Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(self.videoOutput)
        guard let connection = self.videoOutput.connection(with: AVMediaType.video),
            connection.isVideoOrientationSupported else { return }
        connection.videoOrientation = .portrait
    }
    
    private func detectDocument(frame: CVImageBuffer) -> VNRectangleObservation? {
        let rectangleDetectionRequest = VNDetectRectanglesRequest()
        let passportAspectRatio: Float = 125/88
        let idCardAspectRatio: Float = 85/53
        rectangleDetectionRequest.minimumAspectRatio = passportAspectRatio * 0.90
        rectangleDetectionRequest.maximumAspectRatio = passportAspectRatio * 1.10
        
        let textDetectionRequest = VNDetectTextRectanglesRequest()
        
        try? self.requestHandler.perform([rectangleDetectionRequest, textDetectionRequest], on: frame)
        
        guard let rectangle = (rectangleDetectionRequest.results as? [VNRectangleObservation])?.first,
            let text = (textDetectionRequest.results as? [VNTextObservation])?.first,
            rectangle.boundingBox.contains(text.boundingBox) else {
                // no credit card rectangle detected
                return nil
        }
        
        return rectangle
    }
    
    private func createRectangleDrawing(_ rectangleObservation: VNRectangleObservation) -> CAShapeLayer {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.previewLayer.frame.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.previewLayer.frame.width,
                                                        y: self.previewLayer.frame.height)
        let rectangleOnScreen = rectangleObservation.boundingBox.applying(scale).applying(transform)
        let boundingBoxPath = CGPath(rect: rectangleOnScreen, transform: nil)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = boundingBoxPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 5
        shapeLayer.borderWidth = 5
        return shapeLayer
    }
    
    private func trackDocumentCard(for observation: VNRectangleObservation,
                                   in frame: CVImageBuffer) -> VNRectangleObservation? {
        
        let request = VNTrackRectangleRequest(rectangleObservation: observation)
        request.trackingLevel = .fast
        
        try? self.requestHandler.perform([request], on: frame)
        
        guard let trackedRectangle = (request.results as? [VNRectangleObservation])?.first else {
            return nil
        }
        return trackedRectangle
    }
    
    private func handleObservedDocument(_ observation: VNRectangleObservation, in frame: CVImageBuffer) {
        if let trackedCardRectangle = self.trackDocumentCard(for: observation, in: frame) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let rectangleDrawing = self.rectangleDrawing else { return }
                rectangleDrawing.removeFromSuperlayer()
                self.rectangleDrawing = self.createRectangleDrawing(trackedCardRectangle)
                self.view.layer.addSublayer(rectangleDrawing)
            }
            DispatchQueue.global(qos: .background).async {
                //TODO:
                if let extractedNumber = self.extractMRZ(frame: frame, rectangle: observation) {
                    DispatchQueue.main.async {
                        print(extractedNumber)
                        self.resultsHandler?(extractedNumber)
                    }
                }
            }
        } else {
            self.documentRectangleObservation = nil
        }
    }
    
    private func extractMRZ(frame: CVImageBuffer, rectangle: VNRectangleObservation) -> String? {
        
        let cardPositionInImage = VNImageRectForNormalizedRect(rectangle.boundingBox,
                                                               CVPixelBufferGetWidth(frame),
                                                               CVPixelBufferGetHeight(frame))
        let ciImage = CIImage(cvImageBuffer: frame)
        let croppedImage = ciImage.cropped(to: cardPositionInImage)
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: croppedImage, options: [:])
        try? stillImageRequestHandler.perform([request])
        
        guard let texts = request.results as? [VNRecognizedTextObservation], !texts.isEmpty else {
            // no text detected
            return nil
        }
        //44 ilgis
        let mrzRecognized = texts
            .flatMap({ $0.topCandidates(10).map({ $0.string }) })
            .map({ $0.trimmingCharacters(in: .whitespaces) })
        print("🟢 \(mrzRecognized)")
        
        let mrzLines = mrzRecognized.filter { $0.count == 44 }
        let isMrzFounded = mrzLines.count == 2
        
        let mrzJoined = mrzLines.joined()
        
        let isMrzValid = isMrzFounded && checkMrz(mrzJoined)
        return isMrzValid ? mrzJoined : nil
    }
    
    private func checkMrz(_ mrz: String) -> Bool {
        guard mrz.count == 88,
              mrz.contains("<<") else {
            return false
        }
        return true
    }
}
