import SwiftUI

struct PostDetailView: View {
    @Environment(SocialStore.self) private var store
    let postID: UUID
    @State private var draft = ""
    @FocusState private var focused: Bool

    private var commentCount: Int {
        store.post(postID)?.comments.count ?? 0
    }

    var body: some View {
        ScrollView {
            if let post = store.post(postID) {
                VStack(alignment: .leading, spacing: 16) {
                    PostCard(post: post)
                    repliesSection(post)
                }
                .padding()
            } else {
                ContentUnavailableView("Echo not found", systemImage: "questionmark.circle")
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Echo")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            composer
        }
    }

    private func repliesSection(_ post: Post) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Replies")
                .font(.headline)
                .padding(.leading, 4)

            if post.comments.isEmpty {
                Text("No replies yet. Start the conversation below.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }

            ForEach(post.comments) { comment in
                CommentRow(comment: comment)
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Reply to this echo", text: $draft, axis: .vertical)
                .lineLimit(1...4)
                .focused($focused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())

            Button {
                let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                store.addComment(to: postID, text: text)
                draft = ""
                focused = false
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.accentGradient)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: commentCount)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

struct CommentRow: View {
    @Environment(SocialStore.self) private var store
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarView(person: store.person(comment.authorID), size: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(store.person(comment.authorID).name)
                        .font(.subheadline.weight(.semibold))
                    Text(comment.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(comment.text)
                    .font(.subheadline)
            }
            Spacer(minLength: 0)
        }
        .card()
    }
}
