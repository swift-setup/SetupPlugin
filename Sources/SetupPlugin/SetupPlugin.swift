import PluginInterface
import SwiftUI

struct SetupPlugin: PluginInterfaceProtocol {
    var manifest: ProjectManifest = ProjectManifest(displayName: "Setup plugin", bundleIdentifier: "com.sirilee.SetupPlugin", author: "sirily11", shortDescription: "Will setup the required files for your plugin creation", repository: "https://github.com/swift-setup/SetupPlugin", keywords: ["setup", "swift-ui"])
    
    
    let fileUtils: FileUtilsProtocol
    let nsPanelUtils: NSPanelUtilsProtocol

    
    var id = UUID()
    
    var view: some View {
       SetupView(fileUtils: fileUtils, nsPanel: nsPanelUtils)
    }
}


@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(SetupPluginBuilder()).toOpaque()
}

public final class SetupPluginBuilder: PluginBuilder {
    public override func build(fileUtils: FileUtilsProtocol, nsPanelUtils: NSPanelUtilsProtocol) -> any PluginInterfaceProtocol {
        SetupPlugin(fileUtils: fileUtils, nsPanelUtils: nsPanelUtils)
    }
}
