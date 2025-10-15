import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 20) {
                    Text("Welcome to STACO")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    Text("Student Accommodation Made Easy")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.bottom, 40)
                    
                    CustomTextField(placeholder: "Email", text: $email, icon: "envelope", keyboardType: .emailAddress)
                    
                    CustomTextField(placeholder: "Password", text: $password, icon: "lock", isSecure: true)
                    
                    CustomButton(title: "Sign In", action: {
                        authViewModel.login(email: email, password: password)
                    }, isLoading: authViewModel.isLoading)
                    .padding(.top, 10)
                    
                    HStack {
                        Text("New user?")
                            .foregroundColor(.gray)
                        
                        NavigationLink(destination: RegisterView()) {
                            Text("Create account")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
                
                Spacer()
            }
            .alert(isPresented: $authViewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(authViewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
