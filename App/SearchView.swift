import SwiftUI

struct SearchView: View {
    @Environment(SocialStore.self) private var store
    @State private var query = ""

    private var trimmed: String {
        query.trimmingCharacters(in: .whitespaces).lowercased()
    }

    private var matchingPeople: [Person] {
        guard !trimmed.isEmpty else { return [] }
        return store.people.filter {
            $0.name.lowercased().contains(trimmed) || $0.handle.lowercased().contains(trimmed)
        }
    }

    private var matchingPosts: [Post] {
        guard !trimmed.isEmpty else { return [] }
        return store.feed.filter { $0.text.lowercased().contains(trimmed) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if trimmed.isEmpty {
                    ContentUnavailableView(
                        "Find people and echoes",
                        systemImage: "magnifyingglass",
                        description: Text("Search by name, handle, or words in a post.")
                    )
                } else if matchingPeople.isEmpty && matchingPosts.isEmpty {
                    ContentUnavailableView.search(text: query)
                } else {
                    resultsList
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "People and echoes")
            .echoDestinations()
        }
    }

    private var resultsList: some View {
        List {
            if !matchingPeople.isEmpty {
                Section("People") {
                    ForEach(matchingPeople) { person in
                        NavigationLink(value: Route.user(person.id)) {
                            HStack(spacing: 12) {
                                AvatarView(person: person, size: 40)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name)
                                        .font(.headline)
                                    Text("@\(person.handle)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(minHeight: 44)
                        }
                    }
                }
            }

            if !matchingPosts.isEmpty {
                Section("Echoes") {
                    ForEach(matchingPosts) { post in
                        NavigationLink(value: Route.post(post.id)) {
                            Text(post.text)
                                .lineLimit(3)
                                .frame(minHeight: 44, alignment: .leading)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
}
