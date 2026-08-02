import SwiftUI

struct PartnerShareView: View {
    let profile: UserProfile
    let entry: WeekGuideEntry
    let week: Int

    @State private var shareMessage = ""
    @State private var renderedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    private var daysUntilDue: Int? { PregnancyCalculator.daysUntilDue(profile: profile) }
    private var emoji: String { BabySizeCatalog.emoji(for: entry.sizeImage) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    shareCard
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personal message")
                            .font(.subheadline.bold())
                        TextField("Can't wait to meet our little one!", text: $shareMessage, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.roundedBorder)
                    }

                    if let image = renderedImage {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview("Bloomly Week \(week)", image: Image(uiImage: image))
                        ) {
                            Label("Share Image", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BloomlyTheme.sageDark)

                        ShareLink(item: shareText) {
                            Label("Share Text Update", systemImage: "text.bubble")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(BloomlyTheme.sageDark)
                    }
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle("Share Update")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { renderCard() }
            .onChange(of: shareMessage) { _, _ in renderCard() }
        }
    }

    private var shareCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Bloomly")
                    .font(.caption.bold())
                    .foregroundStyle(BloomlyTheme.sageDark)
                Spacer()
                Text("Week \(week)")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(BloomlyTheme.sage.opacity(0.25))
                    .clipShape(Capsule())
            }

            Text(emoji)
                .font(.system(size: 72))

            Text(entry.babySize)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(BloomlyTheme.textPrimary)

            HStack(spacing: 20) {
                statBlock("Length", entry.length)
                statBlock("Weight", entry.weight)
            }

            if let days = daysUntilDue {
                Text(days >= 0 ? "\(days) days until due date" : "Due date has passed — any day now!")
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }

            if !shareMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("\"\(shareMessage)\"")
                    .font(.subheadline.italic())
                    .foregroundStyle(BloomlyTheme.blushDark)
                    .multilineTextAlignment(.center)
            }

            if let partner = profile.partnerName, !partner.isEmpty {
                Text("— For \(partner)")
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [BloomlyTheme.cream, BloomlyTheme.blush.opacity(0.35)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: BloomlyTheme.blushDark.opacity(0.15), radius: 12, y: 6)
    }

    private func statBlock(_ title: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var shareText: String {
        var lines = [
            "🌸 Bloomly — Week \(week)",
            entry.babySize,
            "\(entry.length) · \(entry.weight)"
        ]
        if let days = daysUntilDue, days >= 0 {
            lines.append("\(days) days until due date")
        }
        let trimmed = shareMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            lines.append("")
            lines.append(trimmed)
        }
        return lines.joined(separator: "\n")
    }

    private func renderCard() {
        let renderer = ImageRenderer(content: shareCard.frame(width: 340))
        renderer.scale = UIScreen.main.scale
        renderedImage = renderer.uiImage
    }
}

struct PartnerSettingsSection: View {
    @Bindable var profile: UserProfile

    var body: some View {
        Section("Partner Sharing") {
            TextField("Your name (optional)", text: Binding(
                get: { profile.displayName ?? "" },
                set: { profile.displayName = $0.isEmpty ? nil : $0 }
            ))
            TextField("Partner's name (optional)", text: Binding(
                get: { profile.partnerName ?? "" },
                set: { profile.partnerName = $0.isEmpty ? nil : $0 }
            ))
            Text("Used when sharing weekly baby-size updates.")
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
    }
}
