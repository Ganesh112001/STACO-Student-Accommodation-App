import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    let text: Binding<String>
    let icon: String
    let isSecure: Bool
    let isRequired: Bool
    let showError: Bool
    let errorMessage: String
    let keyboardType: UIKeyboardType
    
    init(placeholder: String,
         text: Binding<String>,
         icon: String,
         isSecure: Bool = false,
         isRequired: Bool = false,
         showError: Bool = false,
         errorMessage: String = "This field is required",
         keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder
        self.text = text
        self.icon = icon
        self.isSecure = isSecure
        self.isRequired = isRequired
        self.showError = showError
        self.errorMessage = errorMessage
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(placeholder)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                
                if isSecure {
                    SecureField("", text: text)
                        .keyboardType(keyboardType)
                } else {
                    TextField("", text: text)
                        .keyboardType(keyboardType)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(showError ? Color.red : Color.clear, lineWidth: 1)
            )
            
            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct CustomTextEditor: View {
    let placeholder: String
    let text: Binding<String>
    let isRequired: Bool
    let showError: Bool
    let errorMessage: String
    
    init(placeholder: String,
         text: Binding<String>,
         isRequired: Bool = false,
         showError: Bool = false,
         errorMessage: String = "This field is required") {
        self.placeholder = placeholder
        self.text = text
        self.isRequired = isRequired
        self.showError = showError
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(placeholder)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            
            TextEditor(text: text)
                .frame(minHeight: 100, maxHeight: 150)
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showError ? Color.red : Color.clear, lineWidth: 1)
                )
            
            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
