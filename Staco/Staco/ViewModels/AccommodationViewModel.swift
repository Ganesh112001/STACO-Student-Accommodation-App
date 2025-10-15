import Foundation
import SwiftUI
import Combine

class AccommodationViewModel: ObservableObject {
    @Published var accommodations: [Accommodation] = []
    @Published var selectedAccommodation: Accommodation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    @Published var successMessage: String?
    
    // Filter properties
    @Published var selectedHouseDetails: HouseDetails?
    @Published var availableFrom: Date?
    @Published var availableTo: Date?
    @Published var selectedGender: Gender?
    @Published var selectedRoomType: RoomType?
    @Published var minRent: Double?
    @Published var maxRent: Double?
    @Published var maxDistance: Double?
    @Published var isFilterActive = false
    
    // Add accommodation form properties
    @Published var address = ""
    @Published var houseDetails: HouseDetails = HouseDetails(bedrooms: 1, bathrooms: 1)
    @Published var fromDate = Date()
    @Published var toDate = Date().addingTimeInterval(30*24*60*60) // Default 30 days ahead
    @Published var gender: Gender = .mixed
    @Published var roomType: RoomType = .privateRoom
    @Published var rentAmount: String = ""
    @Published var rentType: RentType = .withUtilities
    @Published var distanceFromUniversity: String = ""
    @Published var amenities: String = ""
    @Published var locationConvenience: String = ""
    @Published var selectedImages: [UIImage] = []
    
    // Validation
    @Published var addressError = false
    @Published var houseDetailsError = false
    @Published var dateError = false
    @Published var genderError = false
    @Published var roomTypeError = false
    @Published var rentError = false
    @Published var distanceError = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadAccommodations()
    }
    
    func loadAccommodations() {
        isLoading = true
        
        Task {
            do {
                let accommodations = try await FirebaseManager.shared.fetchAccommodations()
                
                await MainActor.run {
                    self.accommodations = accommodations
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func applyFilters() {
        isLoading = true
        isFilterActive = true
        
        Task {
            do {
                // Create a query with all the selected criteria
                let filteredAccommodations = try await FirebaseManager.shared.fetchFilteredAccommodations(
                    houseDetails: selectedHouseDetails,
                    gender: selectedGender,
                    roomType: selectedRoomType,
                    minRent: minRent,
                    maxRent: maxRent,
                    maxDistance: maxDistance
                )
                
                // Further filter the results by date in memory
                var results = filteredAccommodations
                
                if let availableFrom = availableFrom {
                    results = results.filter { $0.availableFrom >= availableFrom }
                }
                
                if let availableTo = availableTo {
                    results = results.filter { $0.availableTo <= availableTo }
                }
                
                await MainActor.run {
                    print("Filter applied: Found \(results.count) matching accommodations")
                    self.accommodations = results
                    self.isLoading = false
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    func resetFilters() {
        selectedHouseDetails = nil
        availableFrom = nil
        availableTo = nil
        selectedGender = nil
        selectedRoomType = nil
        minRent = nil
        maxRent = nil
        maxDistance = nil
        isFilterActive = false
        
        loadAccommodations()
    }
    
    func addAccommodation(latitude: Double?, longitude: Double?) {
        // Validate required fields
        addressError = address.isEmpty
        houseDetailsError = false
        dateError = fromDate >= toDate
        genderError = false
        roomTypeError = false
        rentError = Double(rentAmount) == nil || rentAmount.isEmpty
        distanceError = Double(distanceFromUniversity) == nil || distanceFromUniversity.isEmpty

        let hasError = addressError || dateError || rentError || distanceError

        if hasError {
            setError("Please fill in all required fields")
            return
        }

        isLoading = true

        guard let currentUser = FirebaseManager.shared.auth.currentUser else {
            setError("You must be logged in to add an accommodation")
            return
        }

        Task {
            do {
                let userDoc = try await FirebaseManager.shared.fetchUser(userId: currentUser.uid)

                let newAccommodation = Accommodation(
                    ownerId: currentUser.uid,
                    ownerName: userDoc.fullName,
                    ownerEmail: userDoc.email,
                    address: address,
                    houseDetails: houseDetails,
                    availableFrom: fromDate,
                    availableTo: toDate,
                    gender: gender,
                    roomType: roomType,
                    rentAmount: Double(rentAmount) ?? 0,
                    rentType: rentType,
                    distanceFromUniversity: Double(distanceFromUniversity) ?? 0,
                    amenities: amenities.isEmpty ? nil : amenities,
                    locationConvenience: locationConvenience.isEmpty ? nil : locationConvenience,
                    imagePaths: [],
                    latitude: latitude,  // ✅ Add this
                    longitude: longitude // ✅ And this
                )

                let accommodationId = try await FirebaseManager.shared.addAccommodation(newAccommodation)

                if !selectedImages.isEmpty {
                    let imagePaths = try await FirebaseManager.shared.uploadImages(images: selectedImages, for: accommodationId)

                    // Update accommodation with uploaded image paths
                    let accommodationRef = FirebaseManager.shared.firestore.collection("accommodations").document(accommodationId)
                    try await accommodationRef.updateData(["imagePaths": imagePaths])
                }

                await MainActor.run {
                    self.clearForm()
                    self.setSuccess("Accommodation successfully created")
                    self.loadAccommodations()
                }
            } catch {
                await handleError(error)
            }
        }
    }

    
    func markInterested(in accommodation: Accommodation) {
        guard let accommodationId = accommodation.id, let currentUser = FirebaseManager.shared.auth.currentUser else {
            setError("Unable to mark interest. Please try again.")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await FirebaseManager.shared.markInterested(accommodationId: accommodationId, userId: currentUser.uid)
                
                // Here you would typically send a notification to the accommodation owner
                
                await MainActor.run {
                    self.setSuccess("Interest marked! The owner will be notified.")
                    self.loadAccommodations()
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    // Update accommodation method
    func updateAccommodation(id: String, updatedAccommodation: Accommodation) {
        isLoading = true
        
        Task {
            do {
                try await FirebaseManager.shared.updateAccommodation(id: id, updatedAccommodation: updatedAccommodation)
                
                await MainActor.run {
                    self.setSuccess("Accommodation successfully updated")
                    self.loadAccommodations()
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    // Delete accommodation method
    func deleteAccommodation(id: String) {
        isLoading = true
        
        Task {
            do {
                try await FirebaseManager.shared.deleteAccommodation(id: id)
                
                await MainActor.run {
                    self.setSuccess("Accommodation successfully deleted")
                    self.loadAccommodations()
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func clearForm() {
        address = ""
        houseDetails = HouseDetails(bedrooms: 1, bathrooms: 1)
        fromDate = Date()
        toDate = Date().addingTimeInterval(30*24*60*60)
        gender = .mixed
        roomType = .privateRoom
        rentAmount = ""
        rentType = .withUtilities
        distanceFromUniversity = ""
        amenities = ""
        locationConvenience = ""
        selectedImages = []
    }
    
    func setError(_ message: String) { // Changed from private to public
        errorMessage = message
        showError = true
        isLoading = false
    }
    
    func setSuccess(_ message: String) { // Changed from private to public
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
