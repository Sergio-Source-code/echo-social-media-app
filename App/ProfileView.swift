import SwiftUI

struct ProfileView: View {
    @Environment(SocialStore.self) private var store
    let userID: UUID
    @State private var showCompose = false

    private var person: Person {
        store.person(userID)
    }

    private var isMe: Bool {
        userID == store.currentUserID
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                statsRow
                if !isMe {
                    followButton
                }
                postsSection
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isMe {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCompose = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showCompose) {
            ComposeView()
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            AvatarView(person: person, size: 96)
            Text(person.name)
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("@\(person.handle)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(person.bio)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }

    private var statsRow: some View {
        HStack {
            statItem(value: store.posts(by: userID).count, label: "Echoes")
            statItem(value: store.followerCount(userID), label: "Followers")
            statItem(value: store.followingCount(userID), label: "Following")
        }
        .card()
    }

    private func statItem(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var followButton: some View {
        Button {
            store.toggleFollow(userID)
        } label: {
            Text(store.isFollowing(userID) ? "Following" : "Follow")
                .font(.headline)
                .foregroundStyle(store.isFollowing(userID) ? Theme.rose : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    store.isFollowing(userID) ? Theme.rose.opacity(0.15) : Theme.rose,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: store.isFollowing(userID))
        .animation(.spring(duration: 0.3), value: store.isFollowing(userID))
    }

    @ViewBuilder
    private var postsSection: some View {
        if store.posts(by: userID).isEmpty {
            ContentUnavailableView {
                Label("No echoes yet", systemImage: "text.bubble")
            } description: {
                Text(isMe ? "Your posts will appear here." : "\(person.name) hasn't posted yet.")
            } actions: {
                if isMe {
                    Button("Write an echo") {
                        showCompose = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.rose)
                }
            }
            .padding(.top, 24)
        } else {
            LazyVStack(spacing: 16) {
                ForEach(store.posts(by: userID)) { post in
                    PostCard(post: post)
                }
            }
        }
    }
}
