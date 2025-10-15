import SwiftUI

struct ImageCarouselView: View {
    let imagePaths: [String]  // Changed from imageURLs
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack {
            if imagePaths.isEmpty {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(imagePaths.indices, id: \.self) { index in
                        if let image = LocalStorageManager.shared.loadImage(name: imagePaths[index]) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                        } else {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 250)
                
                // Image indicator
                HStack {
                    ForEach(imagePaths.indices, id: \.self) { index in
                        Circle()
                            .fill(selectedIndex == index ? Color.blue : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}
