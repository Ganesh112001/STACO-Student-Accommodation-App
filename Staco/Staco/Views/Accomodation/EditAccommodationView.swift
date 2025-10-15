import SwiftUI
import PhotosUI

struct EditAccommodationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    
    @State private var accommodation: Accommodation
    
    // Form fields
    @State private var address: String
    @State private var houseDetails: HouseDetails
    @State private var fromDate: Date
    @State private var toDate: Date
    @State private var gender: Gender
    @State private var roomType: RoomType
    @State private var rentAmount: String
    @State private var rentType: RentType
    @State private var distanceFromUniversity: String
    @State private var amenities: String
    @State private var locationConvenience: String
    @State private var selectedImages: [UIImage] = []
    @State private var existingImagePaths: [String] = []
    
    // Validation
    @State private var addressError = false
    @State private var dateError = false
    @State private var rentError = false
    @State private var distanceError = false
    
    @State private var showImagePicker = false
    @State private var showDeleteConfirmation = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(accommodation: Accommodation) {
        self._accommodation = State(initialValue: accommodation)
        
        // Initialize all form fields with accommodation data
        self._address = State(initialValue: accommodation.address)
        self._houseDetails = State(initialValue: accommodation.houseDetails)
        self._fromDate = State(initialValue: accommodation.availableFrom)
        self._toDate = State(initialValue: accommodation.availableTo)
        self._gender = State(initialValue: accommodation.gender)
        self._roomType = State(initialValue: accommodation.roomType)
        self._rentAmount = State(initialValue: String(accommodation.rentAmount))
        self._rentType = State(initialValue: accommodation.rentType)
        self._distanceFromUniversity = State(initialValue: String(accommodation.distanceFromUniversity))
        self._amenities = State(initialValue: accommodation.amenities ?? "")
        self._locationConvenience = State(initialValue: accommodation.locationConvenience ?? "")
        self._existingImagePaths = State(initialValue: accommodation.imagePaths)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        // Address
                        CustomTextField(
                            placeholder: "Full Address",
                            text: $address,
                            icon: "house",
                            isRequired: true,
                            showError: addressError,
                            errorMessage: "Address is required"
                        )
                        
                        // House Details
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("House Details")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("*")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            
                            Picker("House Details", selection: $houseDetails) {
                                ForEach(HouseDetails.allOptions, id: \.self) { option in
                                    Text(option.description).tag(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                        
                        // Availability Dates
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Availability")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("*")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("From")
                                        .font(.subheadline)
                                    
                                    DatePicker("", selection: $fromDate, displayedComponents: .date)
                                        .labelsHidden()
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading) {
                                    Text("To")
                                        .font(.subheadline)
                                    
                                    DatePicker("", selection: $toDate, displayedComponents: .date)
                                        .labelsHidden()
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(dateError ? Color.red : Color.clear, lineWidth: 1)
                            )
                            
                            if dateError {
                                Text("End date must be after start date")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Group {
                        // Gender
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Gender")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("*")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            
                            Picker("Gender", selection: $gender) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical)
                        }
                        .padding(.vertical, 4)
                        
                        // Room Type
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Room Type")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("*")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            
                            Picker("Room Type", selection: $roomType) {
                                ForEach(RoomType.allCases, id: \.self) { roomType in
                                    Text(roomType.rawValue).tag(roomType)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical)
                        }
                        .padding(.vertical, 4)
                        
                        // Rent
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Rent (per month)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("*")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("$")
                                    TextField("", text: $rentAmount)
                                        .keyboardType(.decimalPad)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(rentError ? Color.red : Color.clear, lineWidth: 1)
                                )
                                
                                Picker("Rent Type", selection: $rentType) {
                                    ForEach(RentType.allCases, id: \.self) { rentType in
                                        Text(rentType.rawValue).tag(rentType)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            if rentError {
                                Text("Please enter a valid rent amount")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        // Distance
                        CustomTextField(
                            placeholder: "Distance from University (miles)",
                            text: $distanceFromUniversity,
                            icon: "location",
                            isRequired: true,
                            showError: distanceError,
                            errorMessage: "Please enter a valid distance",
                            keyboardType: .decimalPad
                        )
                    }
                    
                    Group {
                        // Amenities (Optional)
                        CustomTextEditor(
                            placeholder: "Amenities (Optional)",
                            text: $amenities
                        )
                        
                        // Location Convenience (Optional)
                        CustomTextEditor(
                            placeholder: "Location Convenience (Optional)",
                            text: $locationConvenience
                        )
                        
                        // Images (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Images (Optional, max 8)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if existingImagePaths.isEmpty && selectedImages.isEmpty {
                                Button(action: {
                                    showImagePicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Add Images")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        // Display existing images
                                        ForEach(existingImagePaths.indices, id: \.self) { index in
                                            let path = existingImagePaths[index]
                                            if let image = LocalStorageManager.shared.loadImage(name: path) {
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    
                                                    Button(action: {
                                                        existingImagePaths.remove(at: index)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .background(Circle().fill(Color.black.opacity(0.7)))
                                                    }
                                                    .padding(5)
                                                }
                                            }
                                        }
                                        
                                        // Display newly selected images
                                        ForEach(selectedImages.indices, id: \.self) { index in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: selectedImages[index])
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                                Button(action: {
                                                    selectedImages.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Circle().fill(Color.black.opacity(0.7)))
                                                }
                                                .padding(5)
                                            }
                                        }
                                        
                                        if existingImagePaths.count + selectedImages.count < 8 {
                                            Button(action: {
                                                showImagePicker = true
                                            }) {
                                                VStack {
                                                    Image(systemName: "plus")
                                                        .font(.system(size: 30))
                                                    Text("Add More")
                                                        .font(.caption)
                                                }
                                                .frame(width: 100, height: 100)
                                                .background(Color(.systemGray6))
                                                .foregroundColor(.primary)
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    VStack(spacing: 12) {
                        // Update Button
                        CustomButton(title: "Update Accommodation", action: {
                            updateAccommodation()
                        }, isLoading: accommodationViewModel.isLoading)
                        
                        // Delete Button
                        CustomButton(title: "Delete Accommodation", action: {
                            showDeleteConfirmation = true
                        }, isPrimary: false)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationTitle("Edit Accommodation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectionLimit: 8 - (existingImagePaths.count + selectedImages.count)) { images in
                    if existingImagePaths.count + selectedImages.count + images.count <= 8 {
                        selectedImages.append(contentsOf: images)
                    }
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Accommodation"),
                    message: Text("Are you sure you want to delete this accommodation? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteAccommodation()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text(successMessage),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func updateAccommodation() {
        // Validate required fields
        addressError = address.isEmpty
        dateError = fromDate >= toDate
        rentError = Double(rentAmount) == nil || rentAmount.isEmpty
        distanceError = Double(distanceFromUniversity) == nil || distanceFromUniversity.isEmpty
        
        let hasError = addressError || dateError || rentError || distanceError
        
        if hasError {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        guard let id = accommodation.id else {
            errorMessage = "Cannot update: missing accommodation ID"
            showError = true
            return
        }
        
        // Create updated accommodation
        var updatedAccommodation = accommodation
        updatedAccommodation.address = address
        updatedAccommodation.houseDetails = houseDetails
        updatedAccommodation.availableFrom = fromDate
        updatedAccommodation.availableTo = toDate
        updatedAccommodation.gender = gender
        updatedAccommodation.roomType = roomType
        updatedAccommodation.rentAmount = Double(rentAmount) ?? 0
        updatedAccommodation.rentType = rentType
        updatedAccommodation.distanceFromUniversity = Double(distanceFromUniversity) ?? 0
        updatedAccommodation.amenities = amenities.isEmpty ? nil : amenities
        updatedAccommodation.locationConvenience = locationConvenience.isEmpty ? nil : locationConvenience
        updatedAccommodation.imagePaths = existingImagePaths
        
        accommodationViewModel.isLoading = true
        
        // Update accommodation in Firestore
        Task {
            do {
                // Upload new images if any
                if !selectedImages.isEmpty {
                    let newImagePaths = try await FirebaseManager.shared.uploadImages(images: selectedImages, for: id)
                    updatedAccommodation.imagePaths.append(contentsOf: newImagePaths)
                }
                
                try await FirebaseManager.shared.updateAccommodation(id: id, updatedAccommodation: updatedAccommodation)
                
                await MainActor.run {
                    accommodationViewModel.isLoading = false
                    successMessage = "Accommodation successfully updated"
                    showSuccess = true
                    
                    // Refresh accommodations list
                    accommodationViewModel.loadAccommodations()
                }
            } catch {
                await MainActor.run {
                    accommodationViewModel.isLoading = false
                    errorMessage = "Failed to update: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
    
    private func deleteAccommodation() {
        guard let id = accommodation.id else {
            errorMessage = "Cannot delete: missing accommodation ID"
            showError = true
            return
        }
        
        accommodationViewModel.isLoading = true
        
        Task {
            do {
                try await FirebaseManager.shared.deleteAccommodation(id: id)
                
                await MainActor.run {
                    accommodationViewModel.isLoading = false
                    successMessage = "Accommodation successfully deleted"
                    showSuccess = true
                    
                    // Refresh accommodations list
                    accommodationViewModel.loadAccommodations()
                }
            } catch {
                await MainActor.run {
                    accommodationViewModel.isLoading = false
                    errorMessage = "Failed to delete: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// A simplified image picker that uses PHPickerViewController
struct ImagePicker: UIViewControllerRepresentable {
    let selectionLimit: Int
    let onSelect: ([UIImage]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        config.filter = .images
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            let dispatchGroup = DispatchGroup()
            var images = [UIImage]()
            
            for result in results {
                dispatchGroup.enter()
                
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        defer { dispatchGroup.leave() }
                        
                        if let image = image as? UIImage {
                            images.append(image)
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.parent.onSelect(images)
            }
        }
    }
}
