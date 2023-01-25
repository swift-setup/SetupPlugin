//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/25/23.
//

import SwiftUI
import PluginInterface


struct SetupView: View {
    @StateObject var model: SetupModel = SetupModel()
    @State var isDownloading = false
    @State var workspace: URL?
    var disabledDownload: Bool {
        get {
            if workspace == nil {
                return true
            }
            return false
        }
    }

    let fileUtils: FileUtilsProtocol
    let nsPanel:  NSPanelUtilsProtocol
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Current workspace:")
                Spacer()
                if let workspace = fileUtils.currentWorkSpace {
                    Text(workspace.absoluteString)
                }
                Button("Open workspace") {
                    pickWorkspace()
                }
            }
            
            Text("Files to be added")
            Table(model.files) {
                TableColumn("Name", value: \.name)
                TableColumn("File Name", value: \.downloadPath)
                TableColumn("Downloaded") { file in
                    DownloadedIndicator(downloaded: model.downloadedFiles, file: file)
                }
            }
            HStack {
                Spacer()
                Button {
                    Task {
                        await download()
                    }
                } label: {
                    if isDownloading {
                        ProgressView()
                    } else {
                        Text("Start downloading")
                    }
                }
                .disabled(disabledDownload)
            }
        }
        .onAppear {
            model.setup(fileUtils: fileUtils, nsPanel: nsPanel)
            workspace = fileUtils.currentWorkSpace
        }
        .padding()
    }
    
    func pickWorkspace() {
        do {
            let workspaceUrl = try fileUtils.updateCurrentWorkSpace()
            workspace = workspaceUrl
        } catch {
            nsPanel.alert(title: "Cannot pick the workspace", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
    
    func download() async {
        isDownloading = true
        do {
            try await model.download()
        } catch {
            nsPanel.alert(title: "Cannot download the file", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
        isDownloading = false
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView(
            fileUtils: MockFileUtils(), nsPanel: MockNSPanel()
        )
        .environmentObject(SetupModel())
    }
}
