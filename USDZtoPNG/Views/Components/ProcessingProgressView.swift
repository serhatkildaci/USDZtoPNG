import SwiftUI

/// Modern processing progress view with enhanced UX
struct ProcessingProgressView: View {
    let progress: Double
    let currentFile: String
    let processedCount: Int
    let totalCount: Int
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressHeader()
            ProgressDetails(
                progress: progress,
                currentFile: currentFile,
                processedCount: processedCount,
                totalCount: totalCount
            )
            CancelButton(onCancel: onCancel)
        }
        .padding(24)
        .background(backgroundCard)
        .frame(maxWidth: 500)
    }
    
    private var backgroundCard: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Progress Header

private struct ProgressHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "gear.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(45))
            
            Text("Processing Files")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Progress Details

private struct ProgressDetails: View {
    let progress: Double
    let currentFile: String
    let processedCount: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .scaleEffect(y: 1.5)
                .animation(.easeInOut, value: progress)
            
            VStack(spacing: 8) {
                Text("Processing \(processedCount) of \(totalCount) files")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if !currentFile.isEmpty {
                    Text(currentFile)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

// MARK: - Cancel Button

private struct CancelButton: View {
    let onCancel: () -> Void
    
    var body: some View {
        Button("Cancel Processing", action: onCancel)
            .buttonStyle(.bordered)
            .controlSize(.large)
            .foregroundStyle(.red)
    }
}

#Preview {
    ProcessingProgressView(
        progress: 0.65,
        currentFile: "sample-model-with-long-name.usdz",
        processedCount: 13,
        totalCount: 20
    ) {
        print("Cancel tapped")
    }
    .padding()
} 