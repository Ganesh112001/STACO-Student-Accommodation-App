import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if favoritesViewModel.isLoading {
                    ProgressView("Loading your interests...")
                } else if favoritesViewModel.interestedAccommodations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("No Interests Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Accommodations you mark as 'Interested' will appear here")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favoritesViewModel.interestedAccommodations) { accommodation in
                                FavoriteAccommodationCard(
                                    accommodation: accommodation,
                                    onRemove: {
                                        favoritesViewModel.removeInterest(in: accommodation)
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await favoritesViewModel.loadInterestedAccommodations()
                    }
                }
            }
            .navigationTitle("My Interests")
            .onAppear {
                guard let userId = authViewModel.currentUser?.id else { return }
                favoritesViewModel.loadInterestedAccommodations(for: userId)
            }
            .alert(isPresented: $favoritesViewModel.showMessage) {
                Alert(
                    title: Text(favoritesViewModel.isError ? "Error" : "Success"),
                    message: Text(favoritesViewModel.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

class FavoritesViewModel: ObservableObject {
    @Published var interestedAccommodations: [Accommodation] = []
    @Published var isLoading = false
    @Published var showMessage = false
    @Published var message = ""
    @Published var isError = false
    
    func loadInterestedAccommodations(for userId: String? = nil) {
        isLoading = true
        
        Task {
            do {
                let accommodations = try await FirebaseManager.shared.fetchAccommodations()
                let userInterests = try await FirebaseManager.shared.fetchUserInterests(userId: userId)
                
                await MainActor.run {
                    // Filter accommodations where the user is in the interestedUsers array
                    self.interestedAccommodations = accommodations.filter { accommodation in
                        return userInterests.contains(accommodation.id ?? "")
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.message = "Failed to load interests: \(error.localizedDescription)"
                    self.isError = true
                    self.showMessage = true
                }
            }
        }
    }
    
    func removeInterest(in accommodation: Accommodation) {
        guard let accommodationId = accommodation.id,
              let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            message = "Unable to remove interest. Please try again."
            isError = true
            showMessage = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await FirebaseManager.shared.removeInterest(accommodationId: accommodationId, userId: userId)
                
                await MainActor.run {
                    if let index = self.interestedAccommodations.firstIndex(where: { $0.id == accommodationId }) {
                        self.interestedAccommodations.remove(at: index)
                    }
                    self.isLoading = false
                    self.message = "Interest removed successfully"
                    self.isError = false
                    self.showMessage = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.message = "Failed to remove interest: \(error.localizedDescription)"
                    self.isError = true
                    self.showMessage = true
                }
            }
        }
    }
}

struct FavoriteAccommodationCard: View {
    let accommodation: Accommodation
    let onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text(accommodation.address)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: {
                    onRemove()
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            
            Divider()
            
            // Main info in grid layout
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                // House Details
                HStack {
                    Image(systemName: "house")
                        .foregroundColor(.blue)
                    Text(accommodation.houseDetails.description)
                        .font(.subheadline)
                }
                
                // Gender
                HStack {
                    Image(systemName: accommodation.gender.icon)
                        .foregroundColor(.blue)
                    Text(accommodation.gender.rawValue)
                        .font(.subheadline)
                }
                
                // Date Range
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text(accommodation.dateRangeText)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                
                // Room Type
                HStack {
                    Image(systemName: accommodation.roomType.icon)
                        .foregroundColor(.blue)
                    Text(accommodation.roomType.rawValue)
                        .font(.subheadline)
                }
                
                // Rent
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.blue)
                    Text(accommodation.formattedRent)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                
                // Distance
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                    Text(accommodation.formattedDistance)
                        .font(.subheadline)
                }
            }
            
            NavigationLink(destination: AccommodationDetailView(
                accommodation: accommodation,
                onInterestTap: { completion in
                    completion()
                }
            )) {
                Text("View Details")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
