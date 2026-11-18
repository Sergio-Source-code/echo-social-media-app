import SwiftUI

struct FeedView: View {
    @Environment(SocialStore.self) private var store
    @State private var showCompose = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(store.feed) { post in
                        PostCard(post: post)
                    }
                }
                .padding()
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Echo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCompose = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showCompose) {
                ComposeView()
            }
            .echoDestinations()
        }
    }
}
