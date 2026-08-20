import SwiftUI

struct BabySizeIcon: View {
    let sizeImage: String
    var fontSize: CGFloat = 56

    private var assetName: String {
        BabySizeCatalog.assetName(for: sizeImage)
    }

    private var displayScale: CGFloat {
        sizeImage == "small_pumpkin" ? 0.78 : 1.0
    }

    var body: some View {
        Image(assetName)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: fontSize * 1.15 * displayScale, height: fontSize * 1.15 * displayScale)
    }
}
