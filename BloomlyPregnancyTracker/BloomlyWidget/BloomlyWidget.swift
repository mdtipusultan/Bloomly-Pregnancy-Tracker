import WidgetKit
import SwiftUI

struct BloomlyWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct BloomlyWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BloomlyWidgetEntry {
        BloomlyWidgetEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (BloomlyWidgetEntry) -> Void) {
        let snapshot = WidgetDataStore.load() ?? .placeholder
        completion(BloomlyWidgetEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BloomlyWidgetEntry>) -> Void) {
        let snapshot = WidgetDataStore.load() ?? .placeholder
        let entry = BloomlyWidgetEntry(date: .now, snapshot: snapshot)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now.addingTimeInterval(21600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct BloomlyWidgetEntryView: View {
    var entry: BloomlyWidgetEntry
    @Environment(\.widgetFamily) private var family

    private var snapshot: WidgetSnapshot { entry.snapshot }
    private var emoji: String { BabySizeCatalog.emoji(for: snapshot.sizeImage) }

    var body: some View {
        switch family {
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Week \(snapshot.week)")
                    .font(.headline)
                Spacer()
                Text(emoji)
                    .font(.title2)
            }
            Text(BabySizeCatalog.shortName(for: snapshot.sizeImage))
                .font(.caption.bold())
                .lineLimit(1)
            if let days = snapshot.daysUntilDue, days >= 0 {
                Text("\(days) days to go")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: snapshot.progress)
                .tint(BabySizeCatalog.trimesterAccent(for: snapshot.week))
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.97, blue: 0.94), Color(red: 0.96, green: 0.82, blue: 0.84).opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 52))
            VStack(alignment: .leading, spacing: 6) {
                Text("Week \(snapshot.week)")
                    .font(.title3.bold())
                Text(snapshot.babySizeText)
                    .font(.caption)
                    .lineLimit(2)
                HStack {
                    Text(snapshot.length)
                    Text("·")
                    Text(snapshot.weight)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                if let days = snapshot.daysUntilDue, days >= 0 {
                    Text("\(days) days until due date")
                        .font(.caption2.bold())
                        .foregroundStyle(BabySizeCatalog.trimesterAccent(for: snapshot.week))
                }
                ProgressView(value: snapshot.progress)
                    .tint(BabySizeCatalog.trimesterAccent(for: snapshot.week))
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.97, blue: 0.94), Color(red: 0.96, green: 0.82, blue: 0.84).opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct BloomlyWidget: Widget {
    let kind = "BloomlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BloomlyWidgetProvider()) { entry in
            BloomlyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pregnancy Week")
        .description("See your current week, baby size, and countdown.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct BloomlyWidgetBundle: WidgetBundle {
    var body: some Widget {
        BloomlyWidget()
    }
}
