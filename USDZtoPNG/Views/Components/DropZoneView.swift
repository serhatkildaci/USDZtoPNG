import SwiftUI
import UniformTypeIdentifiers

/// Modern drop zone component optimized for performance
struct DropZoneView: View {
    let isTargeted: Bool
    let onDrop: ([NSItemProvider]) async -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(borderColor, lineWidth: 2)
                        .animation(.easeInOut(duration: 0.2), value: isTargeted)
                )
            
            ContentLayer()
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isTargeted)
        .onDrop(of: [UTType.item.identifier], isTargeted: .constant(false)) { providers, _ in
            Task { @MainActor in
                await onDrop(providers)
            }
            return true
        }
    }
    
    // MARK: - Computed Properties
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: isTargeted ? 
                [.blue.opacity(0.1), .blue.opacity(0.05)] : 
                [.gray.opacity(0.05), .gray.opacity(0.02)]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderColor: Color {
        isTargeted ? .blue : .gray.opacity(0.3)
    }
}

// MARK: - Content Layer (Extracted to prevent re-renders)

private struct ContentLayer: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Drop USDZ files here")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
            
            Text("or click to browse")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    DropZoneView(isTargeted: false) { _ in }
        .padding()
} 