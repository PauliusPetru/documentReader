import Quick
import Nimble
@testable import DocumentReader

class DocumentReaderTests: QuickSpec {
    
    override func spec() {
        
        var vm: CameraVM!
        
        beforeSuite {
            vm = CameraVM()
        }
        
        context("should create image") {
            guard let cgImage = #imageLiteral(resourceName: "black").cgImage else {
                fail("failed convert from uiimage to cgimage")
                return
            }
            it("should receive output to turn on torch") {
                vm.handle(input: .scanned(cgImage))
                vm.outputHandler = { output in
                    expect(output).to(equal(.turnTorch))
                }
            }
        }
    }
}
