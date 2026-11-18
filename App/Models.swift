import SwiftUI
import Observation

struct Person: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var handle: String
    var bio: String
    var colorHex: UInt32
}

struct Comment: Identifiable {
    var id = UUID()
    var authorID: UUID
    var text: String
    var createdAt: Date
}

struct Post: Identifiable {
    var id = UUID()
    var authorID: UUID
    var text: String
    var art: String? = nil
    var createdAt: Date
    var likedBy: Set<UUID> = []
    var comments: [Comment] = []
}

enum Route: Hashable {
    case post(UUID)
    case user(UUID)
}

struct RouteView: View {
    let route: Route

    var body: some View {
        switch route {
        case .post(let id):
            PostDetailView(postID: id)
        case .user(let id):
            ProfileView(userID: id)
        }
    }
}

extension View {
    func echoDestinations() -> some View {
        navigationDestination(for: Route.self) { route in
            RouteView(route: route)
        }
    }
}

let artSymbols: [String] = [
    "sparkles",
    "mountain.2.fill",
    "leaf.fill",
    "moon.stars.fill",
    "bolt.fill",
    "camera.macro",
    "sun.horizon.fill",
    "figure.run"
]

@Observable
final class SocialStore {
    let currentUserID: UUID
    private(set) var people: [Person]
    private(set) var posts: [Post]
    private(set) var follows: [UUID: Set<UUID>]

    init() {
        let ava = Person(name: "Ava Rivera", handle: "ava.makes", bio: "Product designer. Coffee first, pixels second. Building small things in public.", colorHex: 0xFF8A6B)
        let marcus = Person(name: "Marcus Chen", handle: "marcusc", bio: "Runner, photographer, reluctant chess player.", colorHex: 0x6C8CFF)
        let priya = Person(name: "Priya Nair", handle: "priya.reads", bio: "Book club organizer. Always mid-chapter.", colorHex: 0xB58CFF)
        let leo = Person(name: "Leo Park", handle: "leo.codes", bio: "iOS engineer. Writes about shipping side projects.", colorHex: 0x3CC19A)
        let sofia = Person(name: "Sofia Ruiz", handle: "sofia.sunsets", bio: "Chasing golden hour in every city I visit.", colorHex: 0xFFB84D)

        let now = Date()

        people = [ava, marcus, priya, leo, sofia]
        currentUserID = ava.id
        follows = [
            ava.id: [marcus.id, leo.id],
            marcus.id: [ava.id],
            priya.id: [ava.id, sofia.id],
            sofia.id: [priya.id],
            leo.id: [ava.id, marcus.id]
        ]

        posts = [
            Post(
                authorID: marcus.id,
                text: "Finally finished the sunrise loop around the reservoir. 10k in 49 minutes and my legs are filing a complaint.",
                art: "figure.run",
                createdAt: now.addingTimeInterval(-600),
                likedBy: [ava.id, leo.id],
                comments: [
                    Comment(authorID: ava.id, text: "Incredible pace. Save me a spot for the next one!", createdAt: now.addingTimeInterval(-300))
                ]
            ),
            Post(
                authorID: priya.id,
                text: "Three chapters in and I already know who did it. Nobody believes me yet. Who's reading along this month?",
                art: nil,
                createdAt: now.addingTimeInterval(-1800),
                likedBy: [ava.id],
                comments: []
            ),
            Post(
                authorID: ava.id,
                text: "New onboarding flow is in review. Biggest change: we moved the sign-up wall until after the first moment of delight. Early numbers look promising.",
                art: "sparkles",
                createdAt: now.addingTimeInterval(-5400),
                likedBy: [marcus.id, priya.id, leo.id],
                comments: [
                    Comment(authorID: leo.id, text: "Moving the wall is the right call. People need to feel the product first.", createdAt: now.addingTimeInterval(-4000)),
                    Comment(authorID: marcus.id, text: "Can I see the before and after?", createdAt: now.addingTimeInterval(-3000))
                ]
            ),
            Post(
                authorID: sofia.id,
                text: "Golden hour in Lisbon never disappoints. Tram 28 at 7:12pm, no filter needed.",
                art: "sun.horizon.fill",
                createdAt: now.addingTimeInterval(-9000),
                likedBy: [ava.id, priya.id, marcus.id],
                comments: []
            ),
            Post(
                authorID: leo.id,
                text: "Shipped my first side project to the App Store this week. Took three weekends, two rejections, and one very patient spouse.",
                art: "bolt.fill",
                createdAt: now.addingTimeInterval(-20000),
                likedBy: [ava.id, marcus.id, priya.id, sofia.id],
                comments: [
                    Comment(authorID: ava.id, text: "Congrats! Rejections are part of the ritual now.", createdAt: now.addingTimeInterval(-18000))
                ]
            ),
            Post(
                authorID: ava.id,
                text: "Reminder: the best design feedback comes from watching someone use your app without saying a word.",
                art: nil,
                createdAt: now.addingTimeInterval(-40000),
                likedBy: [leo.id],
                comments: []
            )
        ]
    }

    var me: Person { person(currentUserID) }

    var feed: [Post] {
        posts.sorted { $0.createdAt > $1.createdAt }
    }

    func person(_ id: UUID) -> Person {
        people.first { $0.id == id } ?? Person(name: "Unknown", handle: "unknown", bio: "", colorHex: 0x8E8E93)
    }

    func post(_ id: UUID) -> Post? {
        posts.first { $0.id == id }
    }

    func posts(by userID: UUID) -> [Post] {
        feed.filter { $0.authorID == userID }
    }

    func toggleLike(_ postID: UUID) {
        guard let i = posts.firstIndex(where: { $0.id == postID }) else { return }
        if posts[i].likedBy.contains(currentUserID) {
            posts[i].likedBy.remove(currentUserID)
        } else {
            posts[i].likedBy.insert(currentUserID)
        }
    }

    func addComment(to postID: UUID, text: String) {
        guard let i = posts.firstIndex(where: { $0.id == postID }) else { return }
        posts[i].comments.append(Comment(authorID: currentUserID, text: text, createdAt: Date()))
    }

    func addPost(text: String, art: String?) {
        posts.append(Post(authorID: currentUserID, text: text, art: art, createdAt: Date()))
    }

    func isFollowing(_ userID: UUID) -> Bool {
        follows[currentUserID]?.contains(userID) ?? false
    }

    func toggleFollow(_ userID: UUID) {
        var set = follows[currentUserID] ?? []
        if set.contains(userID) {
            set.remove(userID)
        } else {
            set.insert(userID)
        }
        follows[currentUserID] = set
    }

    func followerCount(_ userID: UUID) -> Int {
        follows.values.filter { $0.contains(userID) }.count
    }

    func followingCount(_ userID: UUID) -> Int {
        follows[userID]?.count ?? 0
    }
}
