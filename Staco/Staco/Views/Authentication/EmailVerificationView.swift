import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var verificationCode = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Verify Your Email")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Text("We've sent a verification code to \(authViewModel.verificationEmail)")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 30)
            
            CustomTextField(placeholder: "Verification Code", text: $verificationCode, icon: "number", isRequired: true)
            
            CustomButton(title: "Verify Email", action: {
                authViewModel.verifyEmail(code: verificationCode)
            }, isLoading: authViewModel.isLoading)
            .padding(.top, 10)
            
            if authViewModel.isEmailVerified {
                VStack {
                    Text("Email verified successfully!")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.top, 20)
                    
                    Text("You can now sign in with your email and password")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    CustomButton(title: "Go to Login", action: {
                        // Navigate back to login screen
                        presentationMode.wrappedValue.dismiss()
                    }, isPrimary: false)
                    .padding(.top, 20)
                }
            }
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $authViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(authViewModel.errorMessage ?? "An unknown error occurred"),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }
}
