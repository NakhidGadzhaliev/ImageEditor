import Foundation

struct Validator {
    static func isValidEmail(_ email: String) -> Bool {
        return email.contains("@")
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
}
