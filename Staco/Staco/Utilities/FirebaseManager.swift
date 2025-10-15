import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    
    private init() {
        print("FirebaseManager init() started")
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        
        print("FirebaseManager init() completed")
    }
    
    // Authentication functions
    func signIn(email: String, password: String) async throws -> User {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        
        // Check if email is verified
        if !authResult.user.isEmailVerified {
            throw NSError(domain: "auth", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Email not verified. Please check your email and click the verification link."])
        }
        
        return try await fetchUser(userId: authResult.user.uid)
    }
    func signUp(user: User, password: String) async throws -> User {
        let authResult = try await auth.createUser(withEmail: user.email, password: password)
        
        // Send email verification
        try await authResult.user.sendEmailVerification()
        
        // Save user to Firestore
        var newUser = user
        newUser.id = authResult.user.uid
        
        let userRef = self.firestore.collection("users").document(authResult.user.uid)
        try userRef.setData(from: newUser)
        
        return newUser
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func sendEmailVerification() async throws {
        if let user = auth.currentUser {
            try await user.sendEmailVerification()
        } else {
            throw NSError(domain: "auth", code: 1002, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])
        }
    }
    // Add this to your FirebaseManager
    func resendVerificationEmail() async throws {
        guard let currentUser = auth.currentUser else {
            throw NSError(domain: "auth", code: 1002, userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in."])
        }
        
        try await currentUser.sendEmailVerification()
    }
    
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    func fetchUser(userId: String) async throws -> User {
        let document = try await self.firestore.collection("users").document(userId).getDocument()
        
        if let user = try? document.data(as: User.self) {
            return user
        } else {
            throw NSError(domain: "firestore", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user data."])
        }
    }
    
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "firestore", code: 1005, userInfo: [NSLocalizedDescriptionKey: "User ID is missing"])
        }
        
        let userRef = self.firestore.collection("users").document(userId)
        try userRef.setData(from: user)
    }
    
    // Accommodation functions
    func addAccommodation(_ accommodation: Accommodation) async throws -> String {
        let accommodationRef = self.firestore.collection("accommodations").document()
        try accommodationRef.setData(from: accommodation)
        return accommodationRef.documentID
    }
    
    func fetchAccommodations() async throws -> [Accommodation] {
        let snapshot = try await self.firestore.collection("accommodations")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Accommodation.self)
        }
    }
    
    func fetchFilteredAccommodations(
        houseDetails: HouseDetails? = nil,
        gender: Gender? = nil,
        roomType: RoomType? = nil,
        minRent: Double? = nil,
        maxRent: Double? = nil,
        maxDistance: Double? = nil
    ) async throws -> [Accommodation] {
        
        // First, fetch all accommodations
        let snapshot = try await self.firestore.collection("accommodations").getDocuments()
        
        // Then filter in-memory
        var accommodations = snapshot.documents.compactMap { document in
            try? document.data(as: Accommodation.self)
        }
        
        // Apply all filters in memory
        if let gender = gender {
            accommodations = accommodations.filter { $0.gender == gender }
        }
        
        if let roomType = roomType {
            accommodations = accommodations.filter { $0.roomType == roomType }
        }
        
        if let houseDetails = houseDetails {
            accommodations = accommodations.filter {
                $0.houseDetails.bedrooms == houseDetails.bedrooms &&
                $0.houseDetails.bathrooms == houseDetails.bathrooms
            }
        }
        
        if let minRent = minRent {
            accommodations = accommodations.filter { $0.rentAmount >= minRent }
        }
        
        if let maxRent = maxRent {
            accommodations = accommodations.filter { $0.rentAmount <= maxRent }
        }
        
        if let maxDistance = maxDistance {
            accommodations = accommodations.filter { $0.distanceFromUniversity <= maxDistance }
        }
        
        return accommodations.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func markInterested(accommodationId: String, userId: String) async throws {
        let accommodationRef = self.firestore.collection("accommodations").document(accommodationId)
        
        // Get the accommodation data to access owner's email
        let accommodationDoc = try await accommodationRef.getDocument()
        guard var accommodation = try? accommodationDoc.data(as: Accommodation.self) else {
            throw NSError(domain: "firestore", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch accommodation data."])
        }
        
        // Get the interested user's data
        let interestedUserDoc = try await self.firestore.collection("users").document(userId).getDocument()
        guard let interestedUser = try? interestedUserDoc.data(as: User.self) else {
            throw NSError(domain: "firestore", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user data."])
        }
        
        // Mark as interested
        if !accommodation.interestedUsers.contains(userId) {
            accommodation.interestedUsers.append(userId)
            try await accommodationRef.setData(from: accommodation)
            
            // Create an interest notification document
            let notificationData: [String: Any] = [
                "type": "interest",
                "accommodationId": accommodationId,
                "accommodationAddress": accommodation.address,
                "ownerId": accommodation.ownerId,
                "interestedUserId": userId,
                "interestedUserName": interestedUser.fullName,
                "interestedUserEmail": interestedUser.email,
                "timestamp": FieldValue.serverTimestamp(),
                "isRead": false
            ]
            
            // Add to notifications collection
            try await self.firestore.collection("notifications").addDocument(data: notificationData)
            
            // Send email notification using your server or a service like SendGrid
            // This would typically be handled by a Cloud Function
        }
    }
    
    func fetchUserInterests(userId: String?) async throws -> [String] {
        guard let userId = userId ?? auth.currentUser?.uid else {
            return []
        }
        
        // Query all accommodations where this user is in the interestedUsers array
        let snapshot = try await self.firestore.collection("accommodations")
            .whereField("interestedUsers", arrayContains: userId)
            .getDocuments()
        
        // Extract the accommodation IDs
        return snapshot.documents.compactMap { $0.documentID }
    }
    
    func removeInterest(accommodationId: String, userId: String) async throws {
        let accommodationRef = self.firestore.collection("accommodations").document(accommodationId)
        
        // First get the current accommodation data
        let documentSnapshot = try await accommodationRef.getDocument()
        
        guard var accommodation = try? documentSnapshot.data(as: Accommodation.self) else {
            throw NSError(domain: "firestore", code: 1004, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch accommodation data."])
        }
        
        // Remove the user from interested users if present
        if let index = accommodation.interestedUsers.firstIndex(of: userId) {
            accommodation.interestedUsers.remove(at: index)
            
            // Update the document with the modified interested users array
            try await accommodationRef.updateData(["interestedUsers": accommodation.interestedUsers])
        }
    }
    
    // Image Upload
    func uploadImages(images: [UIImage], for accommodationId: String) async throws -> [String] {
        var paths: [String] = []
        
        for (index, image) in images.enumerated() {
            let imageName = "\(accommodationId)_\(index)"
            if let path = LocalStorageManager.shared.saveImage(image, withName: imageName) {
                paths.append(path)
            }
        }
        
        return paths
    }
    
    func downloadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
    
    func deleteAccommodation(id: String) async throws {
        // First fetch the accommodation to get image paths
        let document = try await self.firestore.collection("accommodations").document(id).getDocument()
        
        if let accommodation = try? document.data(as: Accommodation.self) {
            // Delete local images
            for path in accommodation.imagePaths {
                LocalStorageManager.shared.deleteImage(name: path)
            }
        }
        
        // Delete the document
        try await self.firestore.collection("accommodations").document(id).delete()
    }
    
    // Add the updateAccommodation method
    func updateAccommodation(id: String, updatedAccommodation: Accommodation) async throws {
        let accommodationRef = self.firestore.collection("accommodations").document(id)
        try await accommodationRef.setData(from: updatedAccommodation)
    }
}
