import Foundation
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isEmailVerified = false
    
    // Add these properties for success messages
    @Published var successMessage: String?
    @Published var showSuccess = false
    
    @Published var verificationCode: String = ""
    @Published var verificationEmail: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("AuthViewModel initializing")
        setupAuthStateListener()
        print("AuthViewModel initialized")
    }
    
    private func setupAuthStateListener() {
        print("Setting up auth state listener")
        NotificationCenter.default.publisher(for: .authStateDidChange)
            .sink { [weak self] _ in
                print("Auth state changed notification received")
                self?.checkAuthState()
            }
            .store(in: &cancellables)
        
        // Call once at startup
        checkAuthState()
    }
    
    func checkAuthState() {
        print("Checking auth state")
        if let user = FirebaseManager.shared.auth.currentUser {
            print("User is logged in: \(user.email ?? "unknown")")
            if user.isEmailVerified {
                print("User email is verified")
                loadUserData(userId: user.uid)
            } else {
                print("User email is NOT verified")
                DispatchQueue.main.async {
                    self.currentUser = nil
                    self.isLoggedIn = false
                }
            }
        } else {
            print("No user is logged in")
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isLoggedIn = false
            }
        }
    }
    
    private func loadUserData(userId: String) {
        isLoading = true
        
        Task {
            do {
                let user = try await FirebaseManager.shared.fetchUser(userId: userId)
                
                await MainActor.run {
                    self.currentUser = user
                    self.isLoggedIn = true
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func login(email: String, password: String) {
        guard !email.isEmpty && !password.isEmpty else {
            setError("Email and password cannot be empty")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let user = try await FirebaseManager.shared.signIn(email: email, password: password)
                
                await MainActor.run {
                    self.currentUser = user
                    self.isLoggedIn = true
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func register(firstName: String, lastName: String, phoneNumber: String, university: String, email: String, password: String, confirmPassword: String) {
        // Validation
        guard !firstName.isEmpty && !lastName.isEmpty && !phoneNumber.isEmpty && !university.isEmpty && !email.isEmpty && !password.isEmpty else {
            setError("All fields are required")
            return
        }
        
        guard ValidationManager.shared.isValidEmail(email) else {
            setError("Please enter a valid email address")
            return
        }
        
        guard ValidationManager.shared.isStudentEmail(email) else {
            setError("Please use your university email address")
            return
        }
        
        guard ValidationManager.shared.isValidPhoneNumber(phoneNumber) else {
            setError("Please enter a valid phone number")
            return
        }
        
        guard ValidationManager.shared.isValidPassword(password) else {
            setError("Password must be at least 8 characters and include uppercase, lowercase, and numbers")
            return
        }
        
        guard password == confirmPassword else {
            setError("Passwords do not match")
            return
        }
        
        isLoading = true
        
        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            university: university,
            email: email
        )
        
        Task {
            do {
                let user = try await FirebaseManager.shared.signUp(user: newUser, password: password)
                
                await MainActor.run {
                    self.verificationEmail = email
                    self.setSuccess("Registration successful. Please check your email for verification link.")
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func verifyEmail(code: String) {
        // In a real app, you would verify the code against one sent to the user's email
        // For this demo, we'll just simulate email verification
        
        isLoading = true
        
        Task {
            do {
                // In a real app, you would call a function to verify the code
                // For now, we'll just simulate success
                try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                
                await MainActor.run {
                    self.isEmailVerified = true
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func resendVerificationEmail(email: String, password: String) {
        isLoading = true
        
        Task {
            do {
                // First sign in without checking verification
                let authResult = try await FirebaseManager.shared.auth.signIn(withEmail: email, password: password)
                
                // Then send verification email
                try await FirebaseManager.shared.resendVerificationEmail()
                
                await MainActor.run {
                    self.setSuccess("Verification email has been resent. Please check your inbox.")
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func logout() {
        isLoading = true
        
        Task {
            do {
                try FirebaseManager.shared.signOut()
                
                await MainActor.run {
                    self.currentUser = nil
                    self.isLoggedIn = false
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func setError(_ message: String) {
        errorMessage = message
        showError = true
        isLoading = false
    }
    
    // Add this method for success messages
    private func setSuccess(_ message: String) {
        successMessage = message
        showSuccess = true
        isLoading = false
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.isLoading = false
        }
    }
}

extension Notification.Name {
    static let authStateDidChange = Notification.Name("authStateDidChange")
}
