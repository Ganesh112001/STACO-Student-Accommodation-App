import SwiftUI

struct AccommodationCardView: View {
    let accommodation: Accommodation
    let onInterestTap: (@escaping () -> Void) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack {
            // Collapsed Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(accommodation.address)
                            .font(.headline)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: {
                        onInterestTap {
                            // You could add a success indicator here if needed
                        }
                    }) {
                        Text("I'm Interested")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
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

                HStack {
                    Spacer()

                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.blue)
                            .padding(5)
                    }

                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

            // Expanded Details
            if isExpanded {
                NavigationLink(destination: AccommodationDetailView(accommodation: accommodation, onInterestTap: onInterestTap)) {
                    Text("View Full Details")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 5)
                }
            }
        }
    }
}
