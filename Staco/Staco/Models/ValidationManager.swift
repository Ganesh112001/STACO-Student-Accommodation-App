import Foundation

class ValidationManager {
    static let shared = ValidationManager()
    
    private init() {}
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isStudentEmail(_ email: String) -> Bool {
        // This is a simplified check - in a real app, you might have a more robust validation
        // or check against a database of known student email domains
        let studentDomains = [".edu", ".ac.uk", ".edu.au", ".ac.nz"]
        return studentDomains.contains { email.lowercased().contains($0) }
    }
    
    func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, including an uppercase letter, lowercase letter, and number
        return password.count >= 8 &&
            password.range(of: ".*[A-Z].*", options: .regularExpression) != nil &&
            password.range(of: ".*[a-z].*", options: .regularExpression) != nil &&
            password.range(of: ".*[0-9].*", options: .regularExpression) != nil
    }
}
