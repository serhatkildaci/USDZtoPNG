import SwiftUI

/// Modern settings view with improved UX and performance
struct SettingsView: View {
    @Binding var configuration: RenderingConfiguration
    let onDismiss: () -> Void
    let onApply: (RenderingConfiguration) -> Void
    
    @State private var localConfiguration: RenderingConfiguration
    
    init(
        configuration: Binding<RenderingConfiguration>,
        onDismiss: @escaping () -> Void,
        onApply: @escaping (RenderingConfiguration) -> Void
    ) {
        self._configuration = configuration
        self.onDismiss = onDismiss
        self.onApply = onApply
        self._localConfiguration = State(initialValue: configuration.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            SettingsHeader(onDismiss: onDismiss)
            
            ScrollView {
                VStack(spacing: 20) {
                    CameraSection(configuration: $localConfiguration)
                    RotationSection(configuration: $localConfiguration)
                    RenderingSection(configuration: $localConfiguration)
                }
                .padding(.horizontal)
            }
            
            ActionButtons(
                onCancel: onDismiss,
                onApply: { 
                    onApply(localConfiguration)
                    onDismiss()
                }
            )
        }
        .padding()
        .frame(width: 450, height: 650)
        .background(.regularMaterial)
    }
}

// MARK: - Settings Header

private struct SettingsHeader: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Text("Rendering Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Camera Section

private struct CameraSection: View {
    @Binding var configuration: RenderingConfiguration
    
    var body: some View {
        SettingsSection(title: "Camera") {
            VStack(spacing: 16) {
                SettingsRow(title: "Distance") {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Closer")
                                .font(.caption)
                            Spacer()
                            Text("Further")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        
                        Slider(
                            value: $configuration.cameraDistanceMultiplier,
                            in: 1.0...10.0,
                            step: 0.5
                        )
                        .controlSize(.large)
                    }
                }
            }
        }
    }
}

// MARK: - Rotation Section

private struct RotationSection: View {
    @Binding var configuration: RenderingConfiguration
    
    var body: some View {
        SettingsSection(title: "Rotation") {
            VStack(spacing: 16) {
                // X Rotation
                VStack(spacing: 8) {
                    HStack {
                        Text("X Rotation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(configuration.rotationX))°")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Toggle("Random X", isOn: $configuration.enableRandomX)
                            .toggleStyle(.switch)
                    }
                    
                    Slider(
                        value: $configuration.rotationX,
                        in: -180...180,
                        step: 1
                    )
                    .disabled(configuration.enableRandomX)
                    .opacity(configuration.enableRandomX ? 0.5 : 1.0)
                }
                
                Divider()
                
                // Y Rotation
                VStack(spacing: 8) {
                    HStack {
                        Text("Y Rotation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(configuration.rotationY))°")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Toggle("Random Y", isOn: $configuration.enableRandomY)
                            .toggleStyle(.switch)
                    }
                    
                    Slider(
                        value: $configuration.rotationY,
                        in: -180...180,
                        step: 1
                    )
                    .disabled(configuration.enableRandomY)
                    .opacity(configuration.enableRandomY ? 0.5 : 1.0)
                }
                
                Divider()
                
                // Z Rotation
                VStack(spacing: 8) {
                    HStack {
                        Text("Z Rotation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(Int(configuration.rotationZ))°")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Toggle("Random Z", isOn: $configuration.enableRandomZ)
                            .toggleStyle(.switch)
                    }
                    
                    Slider(
                        value: $configuration.rotationZ,
                        in: -180...180,
                        step: 1
                    )
                    .disabled(configuration.enableRandomZ)
                    .opacity(configuration.enableRandomZ ? 0.5 : 1.0)
                }
                
                // Reset button
                HStack {
                    Spacer()
                    Button("Reset All") {
                        configuration.rotationX = 0
                        configuration.rotationY = 0
                        configuration.rotationZ = 0
                        configuration.enableRandomX = false
                        configuration.enableRandomY = false
                        configuration.enableRandomZ = false
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }
}

// MARK: - Rendering Section

private struct RenderingSection: View {
    @Binding var configuration: RenderingConfiguration
    
    var body: some View {
        SettingsSection(title: "Quality") {
            VStack(spacing: 16) {
                SettingsRow(title: "Image Size") {
                    Picker("Size", selection: .constant("1200x1200")) {
                        Text("1200x1200").tag("1200x1200")
                        Text("2400x2400").tag("2400x2400")
                        Text("Custom").tag("custom")
                    }
                    .pickerStyle(.menu)
                }
                
                SettingsRow(title: "Anti-aliasing") {
                    Picker("Quality", selection: .constant("4x")) {
                        Text("None").tag("none")
                        Text("2x").tag("2x")
                        Text("4x").tag("4x")
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}

// MARK: - Settings Section Container

private struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }
}

// MARK: - Settings Row

private struct SettingsRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            content
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - Action Buttons

private struct ActionButtons: View {
    let onCancel: () -> Void
    let onApply: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button("Cancel", action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.large)
            
            Button("Apply Settings", action: onApply)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
    }
}

#Preview {
    SettingsView(
        configuration: .constant(.default),
        onDismiss: {},
        onApply: { _ in }
    )
} 