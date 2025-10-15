import SwiftUI
import PhotosUI
import CoreLocation

struct AddAccommodationView: View {
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showImagePicker = false

    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var isGettingLocation = false
    @State private var locationFetched = false

    var body: some View {
        NavigationView {
            Form {
                // Address Section
                Section(header: Text("Property Location")) {
                    TextField("Full Address", text: $accommodationViewModel.address)
                        .onChange(of: accommodationViewModel.address) { newAddress in
                            if !newAddress.isEmpty {
                                geocodeAddress(newAddress)
                            }
                        }

                    Button(action: {
                        isGettingLocation = true
                        LocationManager.shared.requestLocation { coordinates, address in
                            self.latitude = coordinates.latitude
                            self.longitude = coordinates.longitude
                            if let address = address {
                                accommodationViewModel.address = address
                            }
                            isGettingLocation = false
                            locationFetched = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text(isGettingLocation ? "Getting location..." : "Use Current Location")
                        }
                    }

                    if accommodationViewModel.addressError {
                        Text("Address is required")
                            .foregroundColor(.red)
                    }
                }

                // House Details Section
                Section(header: Text("Property Details")) {
                    Picker("House Details", selection: $accommodationViewModel.houseDetails) {
                        ForEach(HouseDetails.allOptions, id: \.self) { option in
                            Text(option.description).tag(option)
                        }
                    }

                    DatePicker("Available From", selection: $accommodationViewModel.fromDate, displayedComponents: .date)
                    DatePicker("Available To", selection: $accommodationViewModel.toDate, displayedComponents: .date)

                    if accommodationViewModel.dateError {
                        Text("End date must be after start date")
                            .foregroundColor(.red)
                    }

                    Picker("Gender", selection: $accommodationViewModel.gender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }

                    Picker("Room Type", selection: $accommodationViewModel.roomType) {
                        ForEach(RoomType.allCases, id: \.self) { roomType in
                            Text(roomType.rawValue).tag(roomType)
                        }
                    }
                }

                // Cost & Location Section
                Section(header: Text("Cost & Distance")) {
                    HStack {
                        Text("$")
                        TextField("Monthly Rent", text: $accommodationViewModel.rentAmount)
                            .keyboardType(.decimalPad)
                    }

                    if accommodationViewModel.rentError {
                        Text("Please enter a valid rent amount")
                            .foregroundColor(.red)
                    }

                    Picker("Rent Type", selection: $accommodationViewModel.rentType) {
                        ForEach(RentType.allCases, id: \.self) { rentType in
                            Text(rentType.rawValue).tag(rentType)
                        }
                    }

                    HStack {
                        TextField("Distance from University", text: $accommodationViewModel.distanceFromUniversity)
                            .keyboardType(.decimalPad)
                        Text("miles")
                    }

                    if accommodationViewModel.distanceError {
                        Text("Please enter a valid distance")
                            .foregroundColor(.red)
                    }
                }

                // Additional Details Section
                Section(header: Text("Additional Details (Optional)")) {
                    ZStack(alignment: .topLeading) {
                        if accommodationViewModel.amenities.isEmpty {
                            Text("List amenities (e.g. • WiFi\n• Laundry...)")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.horizontal, 4)
                        }
                        TextEditor(text: $accommodationViewModel.amenities)
                            .frame(minHeight: 100)
                    }

                    ZStack(alignment: .topLeading) {
                        if accommodationViewModel.locationConvenience.isEmpty {
                            Text("E.g. • 5 mins to subway\n• Grocery nearby...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.horizontal, 4)
                        }
                        TextEditor(text: $accommodationViewModel.locationConvenience)
                            .frame(minHeight: 100)
                    }
                }

                // Images Section
                Section(header: Text("Photos (Optional)")) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Images")
                            Spacer()
                            Text("\(accommodationViewModel.selectedImages.count)/8")
                                .foregroundColor(.gray)
                        }
                    }

                    if !accommodationViewModel.selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<accommodationViewModel.selectedImages.count, id: \.self) { index in
                                    Image(uiImage: accommodationViewModel.selectedImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            Button(action: {
                                                accommodationViewModel.selectedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .padding(5)
                                            }
                                            .offset(x: 5, y: -5),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .frame(height: 100)
                    }
                }

                // Submit Button Section
                Section {
                    Button(action: {
                        print("Latitude: \(latitude ?? 0), Longitude: \(longitude ?? 0)")
                        accommodationViewModel.addAccommodation(latitude: latitude, longitude: longitude)
                    }) {
                        if accommodationViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Add Accommodation")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(locationFetched ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(accommodationViewModel.isLoading || !locationFetched)
                }
            }
            .navigationTitle("Add Accommodation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .sheet(isPresented: $showImagePicker) {
                CustomImagePicker(onImagesSelected: { images in
                    let remainingSlots = 8 - accommodationViewModel.selectedImages.count
                    let imagesToAdd = Array(images.prefix(remainingSlots))
                    accommodationViewModel.selectedImages.append(contentsOf: imagesToAdd)
                })
            }
            .alert(isPresented: $accommodationViewModel.showSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text(accommodationViewModel.successMessage ?? "Accommodation successfully created"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }

    // ✅ Geocoding method
    private func geocodeAddress(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                print("Geocoded address: \(address)")
                print("Latitude: \(self.latitude ?? 0), Longitude: \(self.longitude ?? 0)")
                locationFetched = true
            } else {
                print("Failed to geocode address: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}

// ✅ CustomImagePicker
struct CustomImagePicker: UIViewControllerRepresentable {
    var onImagesSelected: ([UIImage]) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomImagePicker

        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagesSelected([image])
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
