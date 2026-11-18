import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    static let coral = Color(hex: 0xFF8A6B)
    static let rose = Color(hex: 0xE8456B)
    static let cardRadius: CGFloat = 22

    static let accentGradient = LinearGradient(
        colors: [Theme.coral, Theme.rose],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let background = LinearGradient(
        colors: [Color(uiColor: .systemGroupedBackground), Theme.rose.opacity(0.08)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }
}

extension View {
    func card() -> some View {
        modifier(CardModifier())
    }
}

struct AvatarView: View {
    let person: Person
    var size: CGFloat = 40

    var body: some View {
        Text(String(person.name.prefix(1)))
            .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [Color(hex: person.colorHex), Color(hex: person.colorHex).opacity(0.55)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Circle()
            )
    }
}

struct ArtTile: View {
    let symbol: String

    var body: some View {
        ZStack {
            Theme.accentGradient
            Image(systemName: symbol)
                .font(.system(size: 64, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
