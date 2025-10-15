import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var accommodationViewModel: AccommodationViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(authViewModel)
                .environmentObject(accommodationViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            FavoritesView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("My Interests", systemImage: "heart.fill")
                }
            
            MapView()
                .environmentObject(accommodationViewModel)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
            
            UserProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
