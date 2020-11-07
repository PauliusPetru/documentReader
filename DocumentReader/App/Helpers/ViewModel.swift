import Foundation

protocol ViewModel {
    associatedtype Output
    associatedtype Input
    typealias OutputHandler = (Output) -> Void
    
    var outputHandler: OutputHandler? { get set }
    
    func handle(input: Input)
}
