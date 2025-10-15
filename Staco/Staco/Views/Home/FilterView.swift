import SwiftUI

struct FilterView: View {
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // House Details
                    VStack(alignment: .leading, spacing: 10) {
                        Text("House Details")
                            .font(.headline)
                        
                        Picker("House Details", selection: $accommodationViewModel.selectedHouseDetails) {
                            Text("Any").tag(nil as HouseDetails?)
                            ForEach(HouseDetails.allOptions, id: \.self) { option in
                                Text(option.description).tag(option as HouseDetails?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Availability
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Availability")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("From")
                                    .font(.subheadline)
                                
                                DatePicker("", selection: Binding(
                                    get: { accommodationViewModel.availableFrom ?? Date() },
                                    set: { accommodationViewModel.availableFrom = $0 }
                                ), displayedComponents: .date)
                                .labelsHidden()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("To")
                                    .font(.subheadline)
                                
                                DatePicker("", selection: Binding(
                                    get: { accommodationViewModel.availableTo ?? Date().addingTimeInterval(30*24*60*60) },
                                    set: { accommodationViewModel.availableTo = $0 }
                                ), displayedComponents: .date)
                                .labelsHidden()
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        
                        Button("Clear Dates") {
                            accommodationViewModel.availableFrom = nil
                            accommodationViewModel.availableTo = nil
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                    
                    // Gender
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Gender")
                            .font(.headline)
                        
                        Picker("Gender", selection: $accommodationViewModel.selectedGender) {
                            Text("Any").tag(nil as Gender?)
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender as Gender?)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Room Type
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Room Type")
                            .font(.headline)
                        
                        Picker("Room Type", selection: $accommodationViewModel.selectedRoomType) {
                            Text("Any").tag(nil as RoomType?)
                            ForEach(RoomType.allCases, id: \.self) { roomType in
                                Text(roomType.rawValue).tag(roomType as RoomType?)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Rent Range
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Rent Range (per month)")
                            .font(.headline)
                        
                        HStack {
                            Text("$\(Int(accommodationViewModel.minRent ?? 0))")
                            
                            Slider(
                                value: Binding(
                                    get: { accommodationViewModel.minRent ?? 0 },
                                    set: { accommodationViewModel.minRent = $0 }
                                ),
                                in: 0...3000,
                                step: 100
                            )
                            
                            Text("$\(Int(accommodationViewModel.maxRent ?? 3000))")
                        }
                        .padding(.horizontal)
                        
                        Slider(
                            value: Binding(
                                get: { accommodationViewModel.maxRent ?? 3000 },
                                set: { accommodationViewModel.maxRent = $0 }
                            ),
                            in: (accommodationViewModel.minRent ?? 0)...3000,
                            step: 100
                        )
                        .padding(.horizontal)
                        
                        Button("Clear Rent Range") {
                            accommodationViewModel.minRent = nil
                            accommodationViewModel.maxRent = nil
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                    
                    // Distance
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Maximum Distance from University (miles)")
                            .font(.headline)
                        
                        HStack {
                            Slider(
                                value: Binding(
                                    get: { accommodationViewModel.maxDistance ?? 10 },
                                    set: { accommodationViewModel.maxDistance = $0 }
                                ),
                                in: 0...20,
                                step: 0.5
                            )
                            
                            Text("\(String(format: "%.1f", accommodationViewModel.maxDistance ?? 10)) miles")
                        }
                        .padding(.horizontal)
                        
                        Button("Clear Distance") {
                            accommodationViewModel.maxDistance = nil
                        }
                        .font(.footnote)
                        .foregroundColor(.blue)
                    }
                    
                    HStack {
                        CustomButton(title: "Apply Filters", action: {
                            accommodationViewModel.applyFilters()
                            presentationMode.wrappedValue.dismiss()
                        })
                        .padding(.vertical)
                        
                        CustomButton(title: "Reset", action: {
                            accommodationViewModel.resetFilters()
                            presentationMode.wrappedValue.dismiss()
                        }, isPrimary: false)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Filter Options")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
