import Foundation
import Vision

final class CameraVM: NSObject {
    //TODO: rewrite
    private var isProcessing = false
    
    func processMrz(from image: CGImage) -> String? {
        isProcessing = true
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: image)
        
        var strings = [String]()
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            strings = self.recognizeText(from: request, error: error)
        }

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            isProcessing = false
            print("🔴 Unable to perform the requests: \(error).")
        }
        isProcessing = false
        return validateMrz(from: strings)
    }
    
    private func recognizeText(from request: VNRequest, error: Error?) -> [String] {
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
    
    private func validateMrz(from strings: [String]) -> String? {
        guard let stateCode = strings.first(where: { $0.count == 3 }),
        let passportNo = strings.first(where: { $0.count == 8 && $0.isInt }),
        let firstMrzLine = strings.first(where: { $0.count == 44 && $0.contains(stateCode) }),
        let secondMrzLine = strings.first(where: { $0.count == 44 && $0.contains(passportNo) }) else {
            return nil
        }
        return firstMrzLine + secondMrzLine
    }
}
