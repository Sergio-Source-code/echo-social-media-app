import SwiftUI

struct PostCard: View {
    @Environment(SocialStore.self) private var store
    let post: Post

    private var isLiked: Bool {
        post.likedBy.contains(store.currentUserID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            NavigationLink(value: Route.post(post.id)) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let art = post.art {
                        ArtTile(symbol: art)
                    }
                }
            }
            .buttonStyle(.plain)

            actionRow
        }
        .card()
    }

    private var header: some View {
        HStack(spacing: 10) {
            NavigationLink(value: Route.user(post.authorID)) {
                AvatarView(person: store.person(post.authorID), size: 40)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(store.person(post.authorID).name)
                    .font(.subheadline.weight(.semibold))
                Text("@\(store.person(post.authorID).handle) · \(post.createdAt, style: .relative)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 28) {
            Button {
                store.toggleLike(post.id)
            } label: {
                Label("\(post.likedBy.count)", systemImage: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? Theme.rose : .secondary)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact, trigger: isLiked)

            NavigationLink(value: Route.post(post.id)) {
                Label("\(post.comments.count)", systemImage: "bubble.right")
                    .foregroundStyle(.secondary)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .font(.subheadline.weight(.medium))
        .animation(.spring(duration: 0.3), value: isLiked)
    }
}
