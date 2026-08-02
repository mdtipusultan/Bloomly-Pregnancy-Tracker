import Foundation
import SwiftData

@Model
final class BumpPhoto {
    var week: Int
    var capturedAt: Date
    var imageFilename: String
    var note: String?

    init(week: Int, capturedAt: Date = .now, imageFilename: String, note: String? = nil) {
        self.week = week
        self.capturedAt = capturedAt
        self.imageFilename = imageFilename
        self.note = note
    }
}

enum BumpPhotoStore {
    private static var directory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("BumpPhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    static func saveImage(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = directory.appendingPathComponent(filename)
        guard (try? data.write(to: url)) != nil else { return nil }
        return filename
    }

    static func url(for filename: String) -> URL {
        directory.appendingPathComponent(filename)
    }

    static func deleteImage(filename: String) {
        try? FileManager.default.removeItem(at: url(for: filename))
    }
}
