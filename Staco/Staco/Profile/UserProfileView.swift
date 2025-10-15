import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing = false
    
    // Editable fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var university = ""
    @State private var email = ""
    
    @State private var showSuccess = false
    @State private var successMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Profile header
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("\(firstName) \(lastName)")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(university)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if isEditing {
                                updateProfile()
                            }
                            isEditing.toggle()
                        }) {
                            Text(isEditing ? "Save" : "Edit")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Profile information fields
                    Group {
                        ProfileField(title: "First Name", value: $firstName, isEditing: isEditing)
                        ProfileField(title: "Last Name", value: $lastName, isEditing: isEditing)
                        ProfileField(title: "Phone Number", value: $phoneNumber, isEditing: isEditing)
                        ProfileField(title: "University", value: $university, isEditing: isEditing)
                        ProfileField(title: "Email", value: $email, isEditing: isEditing, isDisabled: true)
                    }
                    
                    Spacer()
                    
                    // Sign out button
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Sign Out")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("My Profile")
            .onAppear {
                loadUserData()
            }
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text(successMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func loadUserData() {
        if let user = authViewModel.currentUser {
            firstName = user.firstName
            lastName = user.lastName
            phoneNumber = user.phoneNumber
            university = user.university
            email = user.email
        }
    }
    
    private func updateProfile() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        let updatedUser = User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            university: university,
            email: email,
            isEmailVerified: true
        )
        
        Task {
            do {
                try await FirebaseManager.shared.updateUser(updatedUser)
                await MainActor.run {
                    authViewModel.currentUser = updatedUser
                    successMessage = "Profile updated successfully"
                    showSuccess = true
                }
            } catch {
                print("Error updating profile: \(error.localizedDescription)")
            }
        }
    }
}

struct ProfileField: View {
    let title: String
    let value: Binding<String>
    let isEditing: Bool
    var isDisabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isEditing && !isDisabled {
                TextField("", text: value)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                Text(value.wrappedValue)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
}
