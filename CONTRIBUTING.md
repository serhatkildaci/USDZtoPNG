# Contributing to USDZtoPNG

Thank you for your interest in contributing to USDZtoPNG! We welcome contributions from the community.

## 🚀 Getting Started

### Prerequisites
- **macOS 14.0 (Sonoma)** or later
- **Xcode 15.0+** with Swift 6.0 support
- Basic knowledge of SwiftUI and 3D rendering concepts

### Setting Up Development Environment
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/USDZtoPNG.git
   cd USDZtoPNG
   ```
3. Open the project in Xcode:
   ```bash
   open USDZtoPNG.xcodeproj
   ```
4. Build and run the project (`⌘R`)

## 📝 How to Contribute

### Reporting Issues
- Use the [GitHub Issues](../../issues) page
- Provide clear reproduction steps
- Include system information (macOS version, Xcode version)
- Attach sample USDZ files if relevant

### Submitting Changes
1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes following our guidelines:**
   - Follow Swift coding conventions
   - Add comments for complex logic
   - Update documentation if needed
   - Test your changes thoroughly

3. **Commit with clear messages:**
   ```bash
   git commit -m "Add: Enhanced rotation controls for Z-axis"
   ```

4. **Push and create a Pull Request:**
   ```bash
   git push origin feature/your-feature-name
   ```

### Code Style Guidelines
- Use **MVVM architecture** pattern
- Follow **SwiftUI best practices**
- Use `@MainActor` for UI-related code
- Prefer `async/await` over completion handlers
- Extract complex views into smaller components
- Add MARK comments for organization

### Testing
- Test on multiple macOS versions when possible
- Verify with various USDZ file types and sizes
- Check memory usage with large files
- Test all rotation and camera controls

## 🎯 Areas We'd Love Help With

### High Priority
- **Performance optimizations** for large USDZ files
- **Additional export formats** (JPEG, TIFF with quality settings)
- **Batch processing improvements** (progress details, cancel individual files)
- **Error handling enhancements** (better user feedback)

### Medium Priority
- **UI/UX improvements** (dark mode optimization, accessibility)
- **Camera controls expansion** (FOV, orthographic projection)
- **Lighting presets** (outdoor, studio, custom setups)
- **Animation support** (extract frames from animated USDZ)

### Documentation & Community
- **Tutorial videos** or **blog posts**
- **Example USDZ files** for testing
- **Performance benchmarks**
- **Localization** (multiple language support)

## 🐛 Bug Reports

When reporting bugs, please include:
- Steps to reproduce the issue
- Expected vs actual behavior
- Console logs (if any errors appear)
- Sample USDZ file (if the issue is file-specific)
- Screenshots or screen recordings

## 💡 Feature Requests

We're always open to new ideas! When suggesting features:
- Explain the use case and benefits
- Consider how it fits with existing functionality
- Provide mockups or detailed descriptions when helpful

## 📚 Development Resources

### Architecture Overview
- **Models/**: Data structures (USdZFile, RenderingConfiguration)
- **ViewModels/**: Business logic (ConverterViewModel)
- **Services/**: Core functionality (RenderingService)
- **Views/**: UI components (SwiftUI views)

### Key Technologies
- **SceneKit** for 3D rendering
- **SwiftUI** for modern UI
- **UniformTypeIdentifiers** for file handling
- **Async/await** for concurrency

## 📞 Questions?

- **General questions**: Open a [Discussion](../../discussions)
- **Bug reports**: Create an [Issue](../../issues)
- **Feature requests**: Start with a [Discussion](../../discussions)

---

**Thank you for helping make USDZtoPNG better!** 🎉 