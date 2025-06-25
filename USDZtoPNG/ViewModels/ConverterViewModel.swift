import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AppKit

/// Main view model for the USDZ to PNG converter following MVVM architecture
@MainActor
final class ConverterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var files: [USdZFile] = []
    @Published var currentFile: USdZFile?
    @Published var renderingConfiguration = RenderingConfiguration.default
    @Published var exportConfiguration = ExportConfiguration()
    
    // UI State
    @Published var isProcessing = false
    @Published var isBulkProcessing = false
    @Published var isShowingSettings = false
    @Published var isDragTarget = false
    
    // Progress tracking
    @Published var processingProgress: Double = 0
    @Published var currentProcessingFile: String = ""
    
    // Error handling
    @Published var errorMessage: String?
    @Published var isShowingError = false
    
    // MARK: - Dependencies
    
    private let renderingService = RenderingService()
    private let fileManager = FileManager.default
    
    // MARK: - Computed Properties
    
    var hasFiles: Bool {
        !files.isEmpty
    }
    
    var completedFiles: [USdZFile] {
        files.filter { $0.state == .completed }
    }
    
    var processingStats: (completed: Int, total: Int) {
        (completedFiles.count, files.count)
    }
    
    // MARK: - Public Methods
    
    /// Imports a single USDZ file
    func importSingleFile() {
        let panel = createOpenPanel(allowsMultiple: false)
        
        if panel.runModal() == .OK, let url = panel.url {
            addFiles([url])
        }
    }
    
    /// Imports multiple USDZ files
    func importMultipleFiles() {
        let panel = createOpenPanel(allowsMultiple: true)
        
        if panel.runModal() == .OK, !panel.urls.isEmpty {
            addFiles(panel.urls)
        }
    }
    
    /// Handles dropped files from drag and drop
    func handleDroppedItems(_ providers: [NSItemProvider]) async {
        let urls = await extractURLsFromProviders(providers)
        addFiles(urls)
    }
    
    /// Processes a single file
    func processSingleFile(_ file: USdZFile) async {
        await processFile(file)
    }
    
    /// Starts bulk processing of all files
    func startBulkProcessing() async {
        guard !files.isEmpty else { return }
        
        // Select output directory
        guard let outputDirectory = selectOutputDirectory() else { return }
        
        exportConfiguration.outputDirectory = outputDirectory
        isBulkProcessing = true
        isProcessing = true
        processingProgress = 0
        
        await processBulkFiles()
        
        isBulkProcessing = false
        isProcessing = false
        showBulkCompletionAlert()
    }
    
    /// Cancels bulk processing
    func cancelBulkProcessing() {
        isBulkProcessing = false
        isProcessing = false
        
        // Reset files that are still processing
        for index in files.indices {
            if files[index].state == .processing {
                files[index].state = .pending
            }
        }
    }
    
    /// Exports a single rendered image
    func exportSingleImage(_ file: USdZFile) {
        guard let image = file.renderedImage else { return }
        
        let savePanel = createSavePanel(suggestedName: "\(file.fileName).png")
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            Task { @MainActor in
                do {
                    try await exportImage(image, to: url)
                } catch {
                    await showError("Failed to export image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Clears all files
    func clearAllFiles() {
        files.removeAll()
        currentFile = nil
    }
    
    /// Removes a specific file
    func removeFile(_ file: USdZFile) {
        files.removeAll { $0.id == file.id }
        if currentFile?.id == file.id {
            currentFile = files.first
        }
    }
    
    /// Updates rendering configuration and re-renders current file if needed
    func updateRenderingConfiguration(_ configuration: RenderingConfiguration) {
        renderingConfiguration = configuration
        
        if let current = currentFile, current.state == .completed {
            Task { @MainActor in
                await processSingleFile(current)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func addFiles(_ urls: [URL]) {
        let usdzURLs = urls.filter { $0.pathExtension.lowercased() == "usdz" }
        
        let newFiles = usdzURLs.map { USdZFile(url: $0) }
        files.append(contentsOf: newFiles)
        
        if currentFile == nil {
            currentFile = files.first
        }
        
        if newFiles.count == 1 {
            Task { @MainActor in
                await processSingleFile(newFiles[0])
            }
        }
    }
    
    private func processFile(_ file: USdZFile) async {
        guard let fileIndex = files.firstIndex(where: { $0.id == file.id }) else { return }
        
        files[fileIndex].state = .processing
        currentProcessingFile = file.fileName
        
        do {
            let image = try await renderingService.renderUSdZToImage(
                from: file.url,
                configuration: renderingConfiguration
            )
            
            files[fileIndex].renderedImage = image
            files[fileIndex].state = .completed
            
            // Update current file if this is the one being viewed
            if currentFile?.id == file.id {
                currentFile = files[fileIndex]
            }
            
        } catch {
            files[fileIndex].state = .failed
            files[fileIndex].errorMessage = error.localizedDescription
            
            await showError("Failed to process \(file.fileName): \(error.localizedDescription)")
        }
        
        currentProcessingFile = ""
    }
    
    private func processBulkFiles() async {
        guard let outputDirectory = exportConfiguration.outputDirectory else { return }
        
        let totalFiles = files.count
        var processedCount = 0
        
        for file in files {
            guard isBulkProcessing else { break }
            
            await processFile(file)
            
            // Export if successful
            if let image = files.first(where: { $0.id == file.id })?.renderedImage {
                let outputURL = outputDirectory.appendingPathComponent("\(file.fileName).png")
                
                do {
                    try await exportImage(image, to: outputURL)
                } catch {
                    print("Failed to export \(file.fileName): \(error.localizedDescription)")
                }
            }
            
            processedCount += 1
            processingProgress = Double(processedCount) / Double(totalFiles)
        }
    }
    
    private func exportImage(_ image: NSImage, to url: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    guard let tiffData = image.tiffRepresentation,
                          let bitmapImage = NSBitmapImageRep(data: tiffData),
                          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
                        throw ExportError.imageConversionFailed
                    }
                    
                    try pngData.write(to: url)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func extractURLsFromProviders(_ providers: [NSItemProvider]) async -> [URL] {
        var urls: [URL] = []
        
        for provider in providers {
            if let url = await extractURL(from: provider) {
                urls.append(url)
            }
        }
        
        return urls
    }
    
    private func extractURL(from provider: NSItemProvider) async -> URL? {
        return await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.item.identifier, options: nil) { item, _ in
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil),
                   url.pathExtension.lowercased() == "usdz" {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func createOpenPanel(allowsMultiple: Bool) -> NSOpenPanel {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = allowsMultiple
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [UTType(filenameExtension: "usdz") ?? .item]
        panel.message = allowsMultiple ? "Select USDZ files to convert" : "Select a USDZ file to convert"
        return panel
    }
    
    private func selectOutputDirectory() -> URL? {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "Select output directory for PNG files"
        panel.prompt = "Select"
        
        return panel.runModal() == .OK ? panel.url : nil
    }
    
    private func createSavePanel(suggestedName: String) -> NSSavePanel {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = suggestedName
        return savePanel
    }
    
    private func showBulkCompletionAlert() {
        let stats = processingStats
        let alert = NSAlert()
        alert.messageText = "Bulk Processing Complete"
        alert.informativeText = "Successfully processed \(stats.completed) of \(stats.total) files."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showError(_ message: String) async {
        errorMessage = message
        isShowingError = true
    }
}

// MARK: - Supporting Types

enum ExportError: LocalizedError {
    case imageConversionFailed
    case fileWriteFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to the selected format"
        case .fileWriteFailed:
            return "Failed to write file to disk"
        }
    }
} 