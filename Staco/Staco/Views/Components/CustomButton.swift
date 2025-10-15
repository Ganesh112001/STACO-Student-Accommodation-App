import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    let isPrimary: Bool
    let isLoading: Bool
    
    init(title: String, action: @escaping () -> Void, isPrimary: Bool = true, isLoading: Bool = false) {
        self.title = title
        self.action = action
        self.isPrimary = isPrimary
        self.isLoading = isLoading
    }
    
    var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: isPrimary ? .white : .blue))
                        .padding(.trailing, 5)
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isPrimary ? Color.blue : Color.white)
            .foregroundColor(isPrimary ? Color.white : Color.blue)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isPrimary ? Color.clear : Color.blue, lineWidth: 1)
            )
        }
        .disabled(isLoading)
    }
}
