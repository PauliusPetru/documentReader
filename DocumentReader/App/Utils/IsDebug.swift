import Foundation

var isDebug: Bool {
    #if DEBUG
    return true
    #else
    return false
    #endif
}
