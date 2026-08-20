import SwiftUI

struct PartnerShareView: View {
    let profile: UserProfile
    let entry: WeekGuideEntry
    let week: Int

    @State private var shareMessage = ""
    @State private var renderedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageManager.self) private var languageManager

    private var daysUntilDue: Int? { PregnancyCalculator.daysUntilDue(profile: profile) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    shareCard
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.partnerPersonalMessage)
                            .font(.subheadline.bold())
                        TextField(L10n.partnerMessagePlaceholder, text: $shareMessage, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.roundedBorder)
                    }

                    if let image = renderedImage {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview(L10n.partnerSharePreview(week), image: Image(uiImage: image))
                        ) {
                            Label(L10n.partnerShareImage, systemImage: "photo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BloomlyTheme.sageDark)

                        ShareLink(item: shareText) {
                            Label(L10n.partnerShareText, systemImage: "text.bubble")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(BloomlyTheme.sageDark)
                    }
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle(L10n.partnerShareTitle)
            .bloomlyThemedNavigation()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.commonDone) { dismiss() }
                }
            }
            .onAppear { renderCard() }
            .onChange(of: shareMessage) { _, _ in renderCard() }
        }
        .bloomlyLanguageAware()
        .id(languageManager.selectedLanguageID)
    }

    private var shareCard: some View {
        VStack(spacing: 20) {
            HStack {
                Text(L10n.appName)
                    .font(.caption.bold())
                    .foregroundStyle(BloomlyTheme.sageDark)
                Spacer()
                Text(L10n.weekNumber(week))
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(BloomlyTheme.sage.opacity(0.25))
                    .clipShape(Capsule())
            }

            BabySizeIcon(sizeImage: entry.sizeImage, fontSize: 72)

            Text(entry.localizedBabySize)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(BloomlyTheme.textPrimary)

            HStack(spacing: 20) {
                statBlock(L10n.weekGuideLength, entry.length)
                statBlock(L10n.weekGuideWeight, entry.weight)
            }

            if let days = daysUntilDue {
                Text(days >= 0 ? L10n.daysUntilDue(days) : L10n.partnerDueDatePassed)
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
                Text(L10n.partnerForName(partner))
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
            L10n.partnerShareLine(week),
            entry.localizedBabySize,
            "\(entry.length) · \(entry.weight)"
        ]
        if let days = daysUntilDue, days >= 0 {
            lines.append(L10n.daysUntilDue(days))
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

struct PartnerSettingsFields: View {
    @Bindable var profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(L10n.profilePartnerSharing)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BloomlyTheme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            TextField(L10n.profileYourName, text: Binding(
                get: { profile.displayName ?? "" },
                set: { profile.displayName = $0.isEmpty ? nil : $0 }
            ))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            BloomlyGroupedDivider()

            TextField(L10n.profilePartnerName, text: Binding(
                get: { profile.partnerName ?? "" },
                set: { profile.partnerName = $0.isEmpty ? nil : $0 }
            ))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Text(L10n.profilePartnerHint)
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

            BloomlyGroupedDivider()
        }
    }
}
