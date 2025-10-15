import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var university: String
    var email: String
    var isEmailVerified: Bool = false
    var createdAt: Date = Date()
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
