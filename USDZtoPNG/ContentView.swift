import SwiftUI
import SceneKit
import UniformTypeIdentifiers
import AppKit

/// Main application view following modern MVVM architecture
struct ContentView: View {
    
    // MARK: - View Model (Using @StateObject per SwiftUI best practices)
    
    @StateObject private var viewModel = ConverterViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderSection()
                
                Divider()
                    .padding(.horizontal)
                
                MainContentArea()
                    .environmentObject(viewModel)
                
                Divider()
                    .padding(.horizontal)
                
                BottomToolbar()
                    .environmentObject(viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .sheet(isPresented: $viewModel.isShowingSettings) {
            SettingsView(
                configuration: $viewModel.renderingConfiguration,
                onDismiss: { viewModel.isShowingSettings = false },
                onApply: viewModel.updateRenderingConfiguration
            )
            .environmentObject(viewModel)
        }
        .alert("Error", isPresented: $viewModel.isShowingError) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .onDrop(of: [UTType.item.identifier], isTargeted: $viewModel.isDragTarget) { providers, _ in
            Task { @MainActor in
                await viewModel.handleDroppedItems(providers)
            }
            return true
        }
    }
}

// MARK: - Header Section

private struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("USDZ to PNG Converter")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("Convert 3D models to high-quality images")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Main Content Area

private struct MainContentArea: View {
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isBulkProcessing {
                BulkProcessingView()
                    .environmentObject(viewModel)
            } else if let currentFile = viewModel.currentFile,
                      let image = currentFile.renderedImage {
                ImagePreviewView(
                    image: image,
                    fileName: currentFile.fileName,
                    onExport: { viewModel.exportSingleImage(currentFile) },
                    onAdjustSettings: { viewModel.isShowingSettings = true }
                )
            } else {
                EmptyStateView()
                    .environmentObject(viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
}

// MARK: - Bulk Processing View

private struct BulkProcessingView: View {
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        ProcessingProgressView(
            progress: viewModel.processingProgress,
            currentFile: viewModel.currentProcessingFile,
            processedCount: viewModel.processingStats.completed,
            totalCount: viewModel.processingStats.total,
            onCancel: viewModel.cancelBulkProcessing
        )
    }
}

// MARK: - Empty State View

private struct EmptyStateView: View {
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            DropZoneView(
                isTargeted: viewModel.isDragTarget,
                onDrop: viewModel.handleDroppedItems
            )
            
            if viewModel.hasFiles {
                FileListSection()
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: - File List Section

private struct FileListSection: View {
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Files (\(viewModel.files.count))")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.files) { file in
                        FileRowView(file: file)
                    }
                }
            }
            .frame(maxHeight: 200)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

// MARK: - File Row View

private struct FileRowView: View {
    let file: USdZFile
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            StatusIndicator(state: file.state)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(file.state.displayText)
                    .font(.caption)
                    .foregroundStyle(file.state.color)
            }
            
            Spacer()
            
            FileActions(file: file)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(file.id == viewModel.currentFile?.id ? .blue.opacity(0.1) : .clear)
        )
        .onTapGesture {
            viewModel.currentFile = file
        }
    }
}

// MARK: - Status Indicator

private struct StatusIndicator: View {
    let state: USdZFile.ProcessingState
    
    var body: some View {
        Group {
            switch state {
            case .pending:
                Image(systemName: "clock")
            case .processing:
                Image(systemName: "gear")
                    .rotationEffect(.degrees(45))
            case .completed:
                Image(systemName: "checkmark.circle.fill")
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
            }
        }
        .foregroundStyle(state.color)
        .font(.title3)
    }
}

// MARK: - File Actions

private struct FileActions: View {
    let file: USdZFile
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            if file.state == .pending {
                Button {
                    Task { @MainActor in
                        await viewModel.processSingleFile(file)
                    }
                } label: {
                    Image(systemName: "play.circle")
                        .font(.title3)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            
            Button {
                viewModel.removeFile(file)
            } label: {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Bottom Toolbar

private struct BottomToolbar: View {
    @EnvironmentObject private var viewModel: ConverterViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Button("Import File") {
                viewModel.importSingleFile()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.isProcessing)
            
            Button("Import Multiple") {
                viewModel.importMultipleFiles()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(viewModel.isProcessing)
            
            Spacer()
            
            if viewModel.hasFiles && !viewModel.isBulkProcessing {
                Button("Process All") {
                    Task { @MainActor in
                        await viewModel.startBulkProcessing()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isProcessing)
                
                Button("Clear All") {
                    viewModel.clearAllFiles()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(viewModel.isProcessing)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .frame(width: 900, height: 700)
} 