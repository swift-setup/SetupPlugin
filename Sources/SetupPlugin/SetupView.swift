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
    @State var workspace: URL? = nil
    @State var isDownloading = false
    var disabledDownload: Bool {
        get {
            if fileUtils.currentWorkSpace == nil {
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
                if let workspace = workspace {
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
        }
        .task {
            await initialize()
        }
        .padding()
    }
    
    func initialize() async {
        do {
            try await model.fetchDownloadList()
        } catch {
            nsPanel.alert(title: "Cannot pick the workspace", subtitle: error.localizedDescription, okButtonText: "OK", alertStyle: .critical)
        }
    }
    
    @MainActor
    func pickWorkspace() {
        do {
            workspace = try fileUtils.updateCurrentWorkSpace()
            try model.fetchExistingFiles()
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
