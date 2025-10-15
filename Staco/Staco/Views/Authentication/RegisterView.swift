import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var university = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var navigateToVerification = false
    @State private var navigateToLogin = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                CustomTextField(placeholder: "First Name", text: $firstName, icon: "person", isRequired: true)
                
                CustomTextField(placeholder: "Last Name", text: $lastName, icon: "person", isRequired: true)
                
                CustomTextField(placeholder: "Phone Number", text: $phoneNumber, icon: "phone", isRequired: true, keyboardType: .phonePad)
                
                CustomTextField(placeholder: "University", text: $university, icon: "building.columns", isRequired: true)
                
                CustomTextField(placeholder: "Email", text: $email, icon: "envelope", isRequired: true, keyboardType: .emailAddress)
                
                CustomTextField(placeholder: "Password", text: $password, icon: "lock", isSecure: true, isRequired: true)
                
                CustomTextField(placeholder: "Confirm Password", text: $confirmPassword, icon: "lock", isSecure: true, isRequired: true)
                
                CustomButton(title: "Create Account", action: {
                    registerUser()
                }, isLoading: authViewModel.isLoading)
                .padding(.top, 10)
                
                NavigationLink(
                    destination: EmailVerificationView(),
                    isActive: $navigateToVerification,
                    label: { EmptyView() }
                )
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Already have an account? Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .alert(isPresented: $authViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(authViewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Success"),
                message: Text(successMessage),
                dismissButton: .default(Text("OK")) {
                    // Navigate back to login screen
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .navigationBarTitle("", displayMode: .inline)
        .onChange(of: authViewModel.isEmailVerified) { isVerified in
            if isVerified {
                showSuccessAndDismiss()
            }
        }
    }
    
    private func registerUser() {
        authViewModel.register(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            university: university,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
        
        // Check if registration was successful (no immediate errors)
        if !authViewModel.showError {
            // In a real app, you may want to wait for the email verification
            // For now, we'll show success and dismiss after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showSuccessAndDismiss()
            }
        }
    }
    
    private func showSuccessAndDismiss() {
        successMessage = "Account created successfully! Please check your email for verification."
        showSuccess = true
    }
}
