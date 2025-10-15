import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), // Default to Boston
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @State private var selectedAccommodation: Accommodation?
    @State private var showDetailView = false
    @State private var zoomLevel: Double = 0.05

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: accommodationViewModel.accommodations) { accommodation in
                MapAnnotation(coordinate: accommodation.coordinate) {
                    VStack {
                        Button(action: {
                            selectedAccommodation = accommodation
                            showDetailView = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 2)

                                Image(systemName: "house.fill")
                                    .foregroundColor(.blue)
                            }
                        }

                        Text("$\(Int(accommodation.rentAmount))")
                            .font(.caption)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(4)
                            .shadow(radius: 1)
                    }
                }
            }

            // Filter indicator
            VStack {
                if accommodationViewModel.isFilterActive {
                    Text("Showing filtered results")
                        .font(.caption)
                        .padding(8)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }

                Spacer()
            }
            .padding(.top, 20)

            // Zoom and Location Controls
            VStack {
                Spacer()

                HStack {
                    // Zoom controls
                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                zoomLevel = max(0.005, zoomLevel - 0.02)
                                updateRegion()
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }

                        Button(action: {
                            withAnimation {
                                zoomLevel = min(0.2, zoomLevel + 0.02)
                                updateRegion()
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 20))
                                .frame(width: 40, height: 40)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.leading, 16)

                    Spacer()

                    // Reset position button
                    Button(action: {
                        resetMapPosition()
                    }) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 24))
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 120) // Increased padding to avoid tab bar
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Accommodations Map")
        .onAppear {
            resetMapPosition()
        }
        .sheet(isPresented: $showDetailView) {
            if let accommodation = selectedAccommodation {
                NavigationView {
                    AccommodationDetailView(
                        accommodation: accommodation,
                        onInterestTap: { completion in
                            accommodationViewModel.markInterested(in: accommodation)
                            completion()
                        }
                    )
                    .navigationBarItems(leading: Button("Close") {
                        showDetailView = false
                    })
                }
            }
        }
    }

    func updateRegion() {
        region = MKCoordinateRegion(
            center: region.center, // Keep the current center
            span: MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
        )
    }

    func resetMapPosition() {
        // If we have accommodations, center on the first one
        if let firstAccommodation = accommodationViewModel.accommodations.first {
            region = MKCoordinateRegion(
                center: firstAccommodation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
            )
        } else {
            // Default view if no accommodations
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), // Boston
                span: MKCoordinateSpan(latitudeDelta: zoomLevel, longitudeDelta: zoomLevel)
            )
        }
    }
}
