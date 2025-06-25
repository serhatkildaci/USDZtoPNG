import Foundation
import SceneKit
import AppKit

/// Service responsible for rendering USDZ files to images
@MainActor
final class RenderingService: ObservableObject {
    
    // MARK: - Public Methods
    
    /// Renders a USDZ file to an NSImage using the provided configuration
    func renderUSdZToImage(from url: URL, configuration: RenderingConfiguration) async throws -> NSImage {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let image = try self.performRenderingSync(url: url, configuration: configuration)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Implementation
    
    private func performRenderingSync(url: URL, configuration: RenderingConfiguration) throws -> NSImage {
        // Load the scene
        let scene = try SCNScene(url: url)
        
        // Setup scene with optimized lighting and camera
        setupScene(scene, configuration: configuration)
        
        // Create renderer with optimized settings
        let renderer = createOptimizedRenderer(scene: scene, configuration: configuration)
        
        // Render the final image
        return renderer.snapshot(
            atTime: 0,
            with: configuration.imageSize,
            antialiasingMode: configuration.antialiasingMode
        )
    }
    
    private func setupScene(_ scene: SCNScene, configuration: RenderingConfiguration) {
        // Calculate scene bounds for optimal camera positioning
        let boundingSphere = scene.rootNode.boundingSphere
        let effectiveRadius = max(Double(boundingSphere.radius), 1.0)
        
        // Setup camera with smart positioning
        setupCamera(in: scene, radius: effectiveRadius, configuration: configuration)
        
        // Configure content positioning and rotation
        setupContent(in: scene, boundingSphere: boundingSphere, configuration: configuration)
        
        // Setup professional lighting
        setupProfessionalLighting(in: scene, radius: effectiveRadius)
    }
    
    private func setupCamera(in scene: SCNScene, radius: Double, configuration: RenderingConfiguration) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = max(1000, radius * 20)
        
        let cameraDistance = radius * configuration.cameraDistanceMultiplier
        cameraNode.position = SCNVector3(0, 0, Float(cameraDistance))
        
        let constraint = SCNLookAtConstraint(target: scene.rootNode)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func setupContent(in scene: SCNScene, boundingSphere: (center: SCNVector3, radius: Float), configuration: RenderingConfiguration) {
        let contentNode = SCNNode()
        
        // Collect and reorganize content nodes
        let contentNodes = scene.rootNode.childNodes.filter { $0.camera == nil && $0.light == nil }
        
        contentNodes.forEach { node in
            node.removeFromParentNode()
            
            node.position = SCNVector3(
                node.position.x - boundingSphere.center.x,
                node.position.y - boundingSphere.center.y,
                node.position.z - boundingSphere.center.z
            )
            
            contentNode.addChildNode(node)
        }
        
        var rotationX: Float = 0
        var rotationY: Float = 0
        var rotationZ: Float = 0
        
        rotationX = Float(configuration.rotationX * .pi / 180.0)
        rotationY = Float(configuration.rotationY * .pi / 180.0)
        rotationZ = Float(configuration.rotationZ * .pi / 180.0)
        if configuration.enableRandomX {
            rotationX = Float.random(in: -Float.pi...Float.pi)
        }
        if configuration.enableRandomY {
            rotationY = Float.random(in: -Float.pi...Float.pi)
        }
        if configuration.enableRandomZ {
            rotationZ = Float.random(in: -Float.pi...Float.pi)
        }
        
        contentNode.eulerAngles = SCNVector3(rotationX, rotationY, rotationZ)
        
        scene.rootNode.addChildNode(contentNode)
    }
    
    private func setupProfessionalLighting(in scene: SCNScene, radius: Double) {
        // Key light (main light source)
        addLight(
            to: scene,
            type: .spot,
            intensity: 1500,
            position: SCNVector3(0, Float(radius), Float(radius * 2)),
            innerAngle: 40,
            outerAngle: 90,
            castsShadow: true
        )
        
        // Fill lights (left and right)
        addLight(
            to: scene,
            type: .spot,
            intensity: 1000,
            position: SCNVector3(Float(-radius * 1.5), Float(radius), Float(radius))
        )
        
        addLight(
            to: scene,
            type: .spot,
            intensity: 1000,
            position: SCNVector3(Float(radius * 1.5), Float(radius), Float(radius))
        )
        
        // Top light
        addLight(
            to: scene,
            type: .spot,
            intensity: 800,
            position: SCNVector3(0, Float(radius * 2), 0)
        )
        
        // Ambient light
        addLight(
            to: scene,
            type: .ambient,
            intensity: 600
        )
        
        // Environment lighting
        scene.lightingEnvironment.contents = NSColor.white
        scene.lightingEnvironment.intensity = 1.5
    }
    
    private func addLight(
        to scene: SCNScene,
        type: SCNLight.LightType,
        intensity: CGFloat,
        position: SCNVector3? = nil,
        innerAngle: CGFloat = 0,
        outerAngle: CGFloat = 0,
        castsShadow: Bool = false
    ) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = type
        lightNode.light?.intensity = intensity
        lightNode.light?.color = NSColor.white
        
        if type == .spot {
            lightNode.light?.spotInnerAngle = innerAngle
            lightNode.light?.spotOuterAngle = outerAngle
        }
        
        lightNode.light?.castsShadow = castsShadow
        
        if let position = position {
            lightNode.position = position
            lightNode.look(at: SCNVector3(0, 0, 0))
        }
        
        scene.rootNode.addChildNode(lightNode)
    }
    
    private func createOptimizedRenderer(scene: SCNScene, configuration: RenderingConfiguration) -> SCNRenderer {
        let renderer = SCNRenderer(device: nil, options: nil)
        renderer.scene = scene
        renderer.autoenablesDefaultLighting = false
        renderer.scene?.background.contents = configuration.backgroundColor
        
        return renderer
    }
} 