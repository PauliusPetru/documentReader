import Foundation
import Vision

final class CameraVM: NSObject {
    
    private var isProcessing = false

    override init() {
        super.init()
    }
    
    func generateText(from image: CGImage) -> [String] {
        isProcessing = true
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: image)
        
        var strings = [String]()
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            strings = self.recognizeTextHandler(request: request, error: error)
        }

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            isProcessing = false
            print("🔴 Unable to perform the requests: \(error).")
        }
        isProcessing = false
        return strings
    }
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) -> [String] {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return []
        }
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        return recognizedStrings
    }
}
