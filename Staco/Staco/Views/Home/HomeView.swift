import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel

    @State private var showAddAccommodation = false
    @State private var showFilter = false

    var body: some View {
        NavigationView {
            VStack {
                if accommodationViewModel.isLoading {
                    ProgressView("Loading accommodations...")
                        .padding()
                } else if accommodationViewModel.accommodations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "house")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)

                        Text("No accommodations found")
                            .font(.headline)

                        if accommodationViewModel.isFilterActive {
                            HStack {
                                Text("Filtered results")
                                    .foregroundColor(.gray)
                                    .italic()

                                Spacer()

                                Button("Clear Filters") {
                                    accommodationViewModel.resetFilters()
                                }
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                        } else {
                            Text("Be the first to add an accommodation!")
                                .foregroundColor(.gray)

                            Button("Add Accommodation") {
                                showAddAccommodation = true
                            }
                            .foregroundColor(.blue)
                            .padding(.top, 5)
                        }
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(accommodationViewModel.accommodations) { accommodation in
                                AccommodationCardView(
                                    accommodation: accommodation,
                                    onInterestTap: { completion in
                                        accommodationViewModel.markInterested(in: accommodation)
                                        completion()
                                    }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        accommodationViewModel.loadAccommodations()
                    }
                }
            }
            .navigationTitle("STACO")
            .navigationBarItems(
                leading: Button(action: {
                    authViewModel.logout()
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                },
                trailing: HStack {
                    Button(action: {
                        showFilter = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }

                    Button(action: {
                        showAddAccommodation = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
            )
            .sheet(isPresented: $showAddAccommodation) {
                AddAccommodationView()
                    .environmentObject(accommodationViewModel)
            }
            .sheet(isPresented: $showFilter) {
                FilterView()
                    .environmentObject(accommodationViewModel)
            }
            .alert(isPresented: $accommodationViewModel.showSuccess) {
                Alert(
                    title: Text("Success"),
                    message: Text(accommodationViewModel.successMessage ?? "Operation successful"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $accommodationViewModel.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(accommodationViewModel.errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
