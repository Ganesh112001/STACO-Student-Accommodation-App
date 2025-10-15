import Foundation
import FirebaseFirestore
import CoreLocation

enum Gender: String, Codable, CaseIterable {
    case allGirls = "All Girls"
    case allBoys = "All Boys"
    case mixed = "Mixed Gender"
    
    var icon: String {
        switch self {
        case .allGirls: return "person.circle"
        case .allBoys: return "person.circle.fill"
        case .mixed: return "person.2.circle"
        }   
    }
}

enum RoomType: String, Codable, CaseIterable {
    case shared = "Shared Room"
    case privateRoom = "Private Room"  // Changed from 'private' to 'privateRoom'
    
    var icon: String {
        switch self {
        case .shared: return "bed.double"
        case .privateRoom: return "bed.single"  // Changed from 'private' to 'privateRoom'
        }
    }
}

enum RentType: String, Codable, CaseIterable {
    case withUtilities = "Rent with Utilities"
    case withoutUtilities = "Rent without Utilities"
    
    var icon: String {
        switch self {
        case .withUtilities: return "bolt.circle"
        case .withoutUtilities: return "minus.circle"
        }
    }
}

struct HouseDetails: Codable, Hashable {
    var bedrooms: Int
    var bathrooms: Int
    
    var description: String {
        return "\(bedrooms) bed \(bathrooms) bath"
    }
    
    static var allOptions: [HouseDetails] {
        [
            HouseDetails(bedrooms: 1, bathrooms: 1),
            HouseDetails(bedrooms: 2, bathrooms: 1),
            HouseDetails(bedrooms: 3, bathrooms: 1),
            HouseDetails(bedrooms: 4, bathrooms: 1),
            HouseDetails(bedrooms: 1, bathrooms: 2),
            HouseDetails(bedrooms: 2, bathrooms: 2),
            HouseDetails(bedrooms: 3, bathrooms: 2),
            HouseDetails(bedrooms: 4, bathrooms: 2),
            HouseDetails(bedrooms: 2, bathrooms: 3),
            HouseDetails(bedrooms: 3, bathrooms: 3),
            HouseDetails(bedrooms: 4, bathrooms: 3)
        ]
    }
}

struct Accommodation: Identifiable, Codable {
    @DocumentID var id: String?
    var ownerId: String
    var ownerName: String
    var ownerEmail: String
    
    var address: String
    var houseDetails: HouseDetails
    var availableFrom: Date
    var availableTo: Date
    var gender: Gender
    var roomType: RoomType
    var rentAmount: Double
    var rentType: RentType
    var distanceFromUniversity: Double
    
    var amenities: String?
    var locationConvenience: String?
    var imagePaths: [String] = []
    
    // New properties for map coordinates
    var latitude: Double?
    var longitude: Double?
    
    var interestedUsers: [String] = []
    var createdAt: Date = Date()
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "\(formatter.string(from: availableFrom)) - \(formatter.string(from: availableTo))"
    }
    
    var formattedRent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let rentString = formatter.string(from: NSNumber(value: rentAmount)) ?? "$\(rentAmount)"
        return "\(rentString)/month (\(rentType.rawValue))"
    }
    
    var formattedDistance: String {
        return String(format: "%.1f miles from university", distanceFromUniversity)
    }
    
    // Computed property for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? 42.3601, // Default to Boston
            longitude: longitude ?? -71.0589
        )
    }
}
