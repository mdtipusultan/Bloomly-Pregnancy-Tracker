import SwiftUI
import SwiftData
import PhotosUI

struct BumpJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BumpPhoto.capturedAt, order: .reverse) private var photos: [BumpPhoto]
    @Query private var profiles: [UserProfile]

    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var note = ""
    @State private var showNoteSheet = false
    @State private var pendingImageData: Data?

    private var profile: UserProfile? { profiles.first }
    private var currentWeek: Int {
        profile.map { PregnancyCalculator.currentWeek(profile: $0) } ?? 1
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                addPhotoSection
                if photos.isEmpty {
                    emptyState
                } else {
                    photoGrid
                }
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle("Bump Journal")
        .onChange(of: pickerItem) { _, item in
            Task { await loadPickerItem(item) }
        }
        .sheet(isPresented: $showNoteSheet) {
            noteSheet
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCaptureView { data in
                pendingImageData = data
                showNoteSheet = true
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Week \(currentWeek) Bump")
                .font(.title2.bold())
            Text("Capture your growing bump each week and watch your journey unfold.")
                .font(.subheadline)
                .foregroundStyle(BloomlyTheme.textSecondary)
            if profile?.trackingMode == "pregnant", let entry = profile.flatMap({ PregnancyCalculator.weekEntry(for: $0) }) {
                HStack {
                    Text(BabySizeCatalog.emoji(for: entry.sizeImage))
                        .font(.title)
                    Text(entry.babySize)
                        .font(.caption)
                        .foregroundStyle(BloomlyTheme.sageDark)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }

    private var addPhotoSection: some View {
        HStack(spacing: 12) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Label("Photo Library", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(BloomlyTheme.sageDark)

            Button {
                showCamera = true
            } label: {
                Label("Camera", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(BloomlyTheme.sageDark)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.macro")
                .font(.system(size: 44))
                .foregroundStyle(BloomlyTheme.blushDark)
            Text("No bump photos yet")
                .font(.headline)
            Text("Add your first photo to start your visual journal.")
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .bloomlyCard()
    }

    private var photoGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(photos) { photo in
                BumpPhotoCell(photo: photo) {
                    deletePhoto(photo)
                }
            }
        }
    }

    private var noteSheet: some View {
        NavigationStack {
            Form {
                Section("Week \(currentWeek)") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Save Photo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        note = ""
                        pendingImageData = nil
                        showNoteSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePendingPhoto()
                        showNoteSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func loadPickerItem(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self) else { return }
        pendingImageData = data
        showNoteSheet = true
    }

    private func savePendingPhoto() {
        guard let data = pendingImageData,
              let filename = BumpPhotoStore.saveImage(data) else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        modelContext.insert(BumpPhoto(
            week: currentWeek,
            imageFilename: filename,
            note: trimmedNote.isEmpty ? nil : trimmedNote
        ))
        note = ""
        pendingImageData = nil
        pickerItem = nil
    }

    private func deletePhoto(_ photo: BumpPhoto) {
        BumpPhotoStore.deleteImage(filename: photo.imageFilename)
        modelContext.delete(photo)
    }
}

struct BumpPhotoCell: View {
    let photo: BumpPhoto
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let uiImage = UIImage(contentsOfFile: BumpPhotoStore.url(for: photo.imageFilename).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Week \(photo.week)")
                        .font(.caption.bold())
                    Text(photo.capturedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
            if let note = photo.note, !note.isEmpty {
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .lineLimit(2)
            }
        }
        .bloomlyCard()
    }
}

struct CameraCaptureView: UIViewControllerRepresentable {
    var onCapture: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (Data) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (Data) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.85) {
                onCapture(data)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
