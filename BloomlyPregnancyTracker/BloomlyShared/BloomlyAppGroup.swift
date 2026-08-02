import Foundation

enum BloomlyAppGroup {
    static let identifier = "group.com.office.Bloomly-PregnancyTracker"
    static let widgetDataKey = "bloomly.widget.snapshot"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}
