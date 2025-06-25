import SwiftUI

/// Optimized image preview component with modern styling
struct ImagePreviewView: View {
    let image: NSImage
    let fileName: String
    let onExport: () -> Void
    let onAdjustSettings: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ImageContainer(image: image, fileName: fileName)
            ActionButtonsRow(onExport: onExport, onAdjustSettings: onAdjustSettings)
        }
    }
}

// MARK: - Image Container (Extracted to prevent re-renders)

private struct ImageContainer: View {
    let image: NSImage
    let fileName: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 500, maxHeight: 400)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(fileName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

// MARK: - Action Buttons (Extracted to prevent re-renders)

private struct ActionButtonsRow: View {
    let onExport: () -> Void
    let onAdjustSettings: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button("Adjust Settings", action: onAdjustSettings)
                .buttonStyle(.bordered)
                .controlSize(.large)
            
            Button("Export PNG", action: onExport)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
    }
}

#Preview {
    if let sampleImage = NSImage(systemSymbolName: "photo", accessibilityDescription: nil) {
        ImagePreviewView(
            image: sampleImage,
            fileName: "sample-model.usdz"
        ) {
            print("Export tapped")
        } onAdjustSettings: {
            print("Adjust settings tapped")
        }
        .padding()
    }
} 