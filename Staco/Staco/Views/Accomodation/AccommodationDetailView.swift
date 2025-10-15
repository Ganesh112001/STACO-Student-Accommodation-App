import SwiftUI

struct AccommodationDetailView: View {
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    @Environment(\..presentationMode) var presentationMode
    
    let accommodation: Accommodation
    let onInterestTap: (@escaping () -> Void) -> Void

    @State private var showDeleteConfirmation = false
    @State private var showInterestSuccessAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Images
                ImageCarouselView(imagePaths: accommodation.imagePaths)
                    .frame(height: 250)
                    .padding(.top, 10)
                
                // Address and basic info
                VStack(alignment: .leading, spacing: 10) {
                    Text(accommodation.address)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(accommodation.houseDetails.description)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(accommodation.formattedRent)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Details in sections
                Group {
                    DetailSection(
                        title: "Availability",
                        icon: "calendar",
                        content: accommodation.dateRangeText
                    )
                    
                    DetailSection(
                        title: "Gender",
                        icon: accommodation.gender.icon,
                        content: accommodation.gender.rawValue
                    )
                    
                    DetailSection(
                        title: "Room Type",
                        icon: accommodation.roomType.icon,
                        content: accommodation.roomType.rawValue
                    )
                    
                    DetailSection(
                        title: "Location",
                        icon: "location",
                        content: accommodation.formattedDistance
                    )
                }
                .padding(.horizontal)
                
                Divider()
                
                // Optional details
                Group {
                    if let amenities = accommodation.amenities, !amenities.isEmpty {
                        DetailSection(
                            title: "Amenities",
                            icon: "star",
                            content: amenities
                        )
                        Divider()
                    }
                    
                    if let convenience = accommodation.locationConvenience, !convenience.isEmpty {
                        DetailSection(
                            title: "Location Convenience",
                            icon: "mappin.and.ellipse",
                            content: convenience
                        )
                        Divider()
                    }
                }
                .padding(.horizontal)
                
                // Contact info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Listed by")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(.blue)
                        Text(accommodation.ownerName)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.blue)
                        Text(accommodation.ownerEmail)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Edit/Delete buttons if user is the owner
                if accommodation.ownerId == FirebaseManager.shared.auth.currentUser?.uid {
                    HStack {
                        NavigationLink(destination: EditAccommodationView(accommodation: accommodation)) {
                            Text("Edit")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                } else {
                    // Interest button (only show if user is not the owner)
                    CustomButton(title: "I'm Interested", action: {
                        onInterestTap {
                            showInterestSuccessAlert = true
                        }
                    })
                    .padding()

                }
            }
        }
        .navigationTitle("Accommodation Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Accommodation"),
                message: Text("Are you sure you want to delete this accommodation? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    if let id = accommodation.id {
                        accommodationViewModel.deleteAccommodation(id: id)
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Success", isPresented: $showInterestSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Interest added successfully!")
        }
    }
}

struct DetailSection: View {
    let title: String
    let icon: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.body)
                .padding(.leading, 25)
        }
        .padding(.vertical, 5)
    }
}
