import SwiftUI

struct ComposeView: View {
    @Environment(SocialStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var art: String? = nil
    @State private var posted = false

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 12) {
                    AvatarView(person: store.me, size: 44)
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .font(.title3)
                        .frame(minHeight: 150)
                }
                .card()

                Text("Attach art")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                artPicker

                Spacer(minLength: 0)
            }
            .padding()
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("New Echo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Post") {
                        publish()
                    }
                    .fontWeight(.semibold)
                    .disabled(trimmed.isEmpty)
                }
            }
            .sensoryFeedback(.success, trigger: posted)
        }
    }

    private var artPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(artSymbols, id: \.self) { symbol in
                    Button {
                        art = (art == symbol) ? nil : symbol
                    } label: {
                        Image(systemName: symbol)
                            .font(.title2)
                            .foregroundStyle(art == symbol ? Theme.rose : .secondary)
                            .frame(width: 60, height: 60)
                            .background(
                                art == symbol ? Theme.rose.opacity(0.15) : Color(uiColor: .secondarySystemGroupedBackground),
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private func publish() {
        store.addPost(text: trimmed, art: art)
        posted.toggle()
        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            dismiss()
        }
    }
}
