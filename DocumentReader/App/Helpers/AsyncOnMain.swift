import Foundation

func asyncOnMain(closure: @escaping ()->()) {
    DispatchQueue.main.async {
        closure()
    }
}
