import Foundation

enum WidgetDataStore {
    static func save(_ snapshot: WidgetSnapshot) {
        guard let defaults = BloomlyAppGroup.sharedDefaults,
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: BloomlyAppGroup.widgetDataKey)
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = BloomlyAppGroup.sharedDefaults,
              let data = defaults.data(forKey: BloomlyAppGroup.widgetDataKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
