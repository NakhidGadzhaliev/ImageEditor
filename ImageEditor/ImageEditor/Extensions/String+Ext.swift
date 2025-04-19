import Foundation

public extension String {
    static var empty: Self { "" }
    
    var localized: String {
        NSLocalizedString(self, comment: .empty)
    }
}
