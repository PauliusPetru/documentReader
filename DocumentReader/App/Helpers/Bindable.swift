import Foundation

protocol Bindable {
    associatedtype ViewModel
    
    var viewModel: ViewModel? { get }
    
    func bind(viewModel: ViewModel?)
}
