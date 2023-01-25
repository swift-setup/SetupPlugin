//
//  File.swift
//
//
//  Created by Qiwei Li on 1/25/23.
//

import Foundation
import PluginInterface

struct DownloadableFile: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: URL
    let downloadPath: String
    
    static func ==(lhs: DownloadableFile, rhs: DownloadableFile) -> Bool {
        return lhs.name == rhs.name
    }
}

protocol NetworkRequest {
    func getRequest(from: URL) async throws -> Data
}

struct NetworkRequestClient: NetworkRequest {
    func getRequest(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

class SetupModel: ObservableObject {
    @Published var downloadedFiles: [DownloadableFile] = []
    var fileUtils: FileUtilsProtocol!
    var nsPanel: NSPanelUtilsProtocol!
    let networkClient: NetworkRequest
    let files: [DownloadableFile] = [
        DownloadableFile(name: "Package Helper", url: URL(string: "https://swift-setup.github.io/scripts/package-plugin/package.py")!, downloadPath: "package.py"),
    ]

    init(networkClient: NetworkRequest = NetworkRequestClient()) {
        self.networkClient = networkClient
    }
    
    func setup(fileUtils: FileUtilsProtocol, nsPanel: NSPanelUtilsProtocol) {
        self.fileUtils = fileUtils
        self.nsPanel = nsPanel
    }
    
    func download() async throws {
        downloadedFiles = []
        guard let _ = fileUtils.currentWorkSpace else {
            nsPanel.alert(title: "No workspace selected", subtitle: "please open a workspace", okButtonText: "OK!", alertStyle: .critical)
            return
        }
        
        for file in files {
            try await downloadFile(file: file)
            downloadedFiles.append(file)
        }
    }

    func downloadFile(file: DownloadableFile) async throws {
        let data = try await self.networkClient.getRequest(from: file.url)
        guard let content = String(data: data, encoding: .utf8) else {
            nsPanel.alert(title: "Cannot read file from remote", subtitle: file.url.absoluteString, okButtonText: "OK", alertStyle: .critical)
            return
        }
        
        try fileUtils.writeFile(at: file.downloadPath, with: content)
    }
}
