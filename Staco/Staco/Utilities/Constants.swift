import SwiftUI

struct Constants {
    // App Colors
    static let primaryColor = Color.blue
    static let secondaryColor = Color.gray
    static let backgroundColor = Color(.systemBackground)
    
    // Text
    static let appName = "STACO"
    static let appTagline = "Student Accommodation Made Easy"
    
    // Validation Errors
    static let requiredFieldError = "This field is required"
    static let invalidEmailError = "Please enter a valid email address"
    static let nonStudentEmailError = "Please use your university email address"
    static let invalidPhoneError = "Please enter a valid phone number"
    static let passwordMismatchError = "Passwords do not match"
    static let weakPasswordError = "Password must be at least 8 characters and include uppercase, lowercase, and numbers"
    
    // Success Messages
    static let accountCreatedSuccess = "Account created successfully! Please verify your email."
    static let accommodationAddedSuccess = "Accommodation successfully created"
    static let interestMarkedSuccess = "Interest marked! The owner will be notified."
    
    // Firebase Collections
    static let usersCollection = "users"
    static let accommodationsCollection = "accommodations"
}
