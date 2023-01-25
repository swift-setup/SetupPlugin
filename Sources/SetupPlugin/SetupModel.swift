//
//  File.swift
//
//
//  Created by Qiwei Li on 1/25/23.
//

import Foundation
import PluginInterface

struct DownloadableFile: Identifiable, Equatable, Codable {
    var id = UUID()
    let name: String
    let url: URL
    let downloadPath: String
    
    static func ==(lhs: DownloadableFile, rhs: DownloadableFile) -> Bool {
        return lhs.name == rhs.name
    }
    
    func toFolder() -> String {
        let url = URL(filePath: downloadPath)
        let result = url.deletingLastPathComponent().absoluteString.replacingOccurrences(of: "file:///", with: "")
        return result
    }
    
    enum CodingKeys: CodingKey {
        case name
        case url
        case downloadPath
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
    @Published private(set) var files: [DownloadableFile] = []
    
    var fileUtils: FileUtilsProtocol!
    var nsPanel: NSPanelUtilsProtocol!
    let networkClient: NetworkRequest
    let url = "https://swift-setup.github.io/SetupPlugin/files.json"
    

    init(networkClient: NetworkRequest = NetworkRequestClient()) {
        self.networkClient = networkClient
    }
    
    func setup(fileUtils: FileUtilsProtocol, nsPanel: NSPanelUtilsProtocol) {
        self.fileUtils = fileUtils
        self.nsPanel = nsPanel
    }
    
    @MainActor
    func fetchDownloadList() async throws {
        let data = try await self.networkClient.getRequest(from: URL(string: url)!)
        self.files = try JSONDecoder().decode([DownloadableFile].self, from: data)
    }
    
    func fetchExistingFiles() throws {
        let filesInDir = try fileUtils.list(includes: files.map { $0.toFolder() })
        for file in filesInDir {
            let foundFile = self.files.first { f in
                f.downloadPath == file
            }
            if let foundFile = foundFile {
                self.downloadedFiles.append(foundFile)
            }
        }
    }
    
    @MainActor
    func download() async throws {
        if !downloadedFiles.isEmpty {
            let confirmed = nsPanel.confirm(title: "Files already existed", subtitle: "This will replace the current one", confirmButtonText: "Download!", cancelButtonText: "Cancel", alertStyle: .warning)
            if !confirmed {
                return
            }
        }
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

    internal func downloadFile(file: DownloadableFile) async throws {
        let data = try await self.networkClient.getRequest(from: file.url)
        guard let content = String(data: data, encoding: .utf8) else {
            nsPanel.alert(title: "Cannot read file from remote", subtitle: file.url.absoluteString, okButtonText: "OK", alertStyle: .critical)
            return
        }
        
        try fileUtils.writeFile(at: file.downloadPath, with: content)
    }
}
