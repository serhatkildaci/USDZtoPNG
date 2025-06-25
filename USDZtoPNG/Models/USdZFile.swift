import Foundation
import SwiftUI
import SceneKit
import UniformTypeIdentifiers

// MARK: - Core Models

/// Represents a USDZ file with its processing state
struct USdZFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    var state: ProcessingState = .pending
    var renderedImage: NSImage?
    var errorMessage: String?
    
    var fileName: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    enum ProcessingState: CaseIterable {
        case pending
        case processing
        case completed
        case failed
        
        var displayText: String {
            switch self {
            case .pending: return "Pending"
            case .processing: return "Processing..."
            case .completed: return "Completed"
            case .failed: return "Failed"
            }
        }
        
        var color: Color {
            switch self {
            case .pending: return .secondary
            case .processing: return .blue
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
}

/// Configuration for 3D rendering
struct RenderingConfiguration {
    var cameraDistanceMultiplier: Double = 2.5
    var imageSize: CGSize = CGSize(width: 1200, height: 1200)
    var backgroundColor: NSColor = .white
    var antialiasingMode: SCNAntialiasingMode = .multisampling4X
    
    // Rotation Configuration
    var rotationX: Double = 0.0  // -180 to 180 degrees
    var rotationY: Double = 0.0  // -180 to 180 degrees
    var rotationZ: Double = 0.0  // -180 to 180 degrees
    
    var enableRandomX: Bool = false
    var enableRandomY: Bool = false
    var enableRandomZ: Bool = false
    
    static let `default` = RenderingConfiguration()
}

/// Export configuration
struct ExportConfiguration {
    var outputDirectory: URL?
    var fileFormat: ExportFormat = .png
    var compressionQuality: Double = 1.0
    
    enum ExportFormat: String, CaseIterable {
        case png = "png"
        case jpeg = "jpg"
        case tiff = "tiff"
        
        var displayName: String {
            switch self {
            case .png: return "PNG"
            case .jpeg: return "JPEG"
            case .tiff: return "TIFF"
            }
        }
        
        var utType: UTType {
            switch self {
            case .png: return .png
            case .jpeg: return .jpeg
            case .tiff: return .tiff
            }
        }
    }
} 