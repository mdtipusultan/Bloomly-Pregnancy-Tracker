import Foundation
import WidgetKit

enum WidgetDataSync {
    static func sync(profile: UserProfile?) {
        guard let profile, profile.trackingMode == "pregnant" else {
            WidgetDataStore.save(.placeholder)
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        let week = PregnancyCalculator.currentWeek(profile: profile)
        let entry = ContentLoader.loadWeekGuide().first { $0.week == week }
        let snapshot = WidgetSnapshot(
            week: week,
            babySizeText: entry?.babySize ?? "Growing every day",
            sizeImage: entry?.sizeImage ?? "unknown",
            length: entry?.length ?? "—",
            weight: entry?.weight ?? "—",
            daysUntilDue: PregnancyCalculator.daysUntilDue(profile: profile),
            progress: PregnancyCalculator.progress(profile: profile),
            trackingMode: profile.trackingMode,
            updatedAt: .now
        )
        WidgetDataStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
