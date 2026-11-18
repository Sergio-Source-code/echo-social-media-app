import SwiftUI

struct ContentView: View {
    @State private var store = SocialStore()

    var body: some View {
        TabView {
            FeedView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack {
                ProfileView(userID: store.currentUserID)
                    .echoDestinations()
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .environment(store)
        .tint(Theme.rose)
    }
}
