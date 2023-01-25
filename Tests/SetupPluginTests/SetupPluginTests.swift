import XCTest
@testable import SetupPlugin
import PluginInterface

class TestFileUtils: FileUtilsProtocol {
    var currentWorkSpace: URL? = URL(filePath: "/usr/plugin")
    
    var currentWorkSpacePath: String? = "usr/plugin"
    
    func openFile(at path: String) throws -> Data {
        return "Hello".data(using: .utf8)!
    }
    
    func writeFile(at path: URL, with content: String) throws {
        
    }
    
    func delete(at path: String) throws {
        
    }
    
    var writtenContent: String = ""
    var writtenPath: String = ""
    
    func updateCurrentWorkSpace() throws -> URL {
        return URL(string: "https://google.com")!
    }
 
    func list(includes: [String]) throws -> [String] {
        return []
    }
    
    func openFile(at path: URL) throws -> Data {
        return "Hello".data(using: .utf8)!
    }
    
    func writeFile(at path: String, with content: String) throws {
        self.writtenPath = path
        self.writtenContent = content
    }
    
    func createDirs(at path: URL) throws {
        
    }
    
    func delete(at path: URL) throws {
        
    }
    
    
}

class TestNSPanel: NSPanelUtilsProtocol {
    var confirmCounter = 0
    var alertCounter = 0
    
    func confirm(title: String, subtitle: String, confirmButtonText: String?, cancelButtonText: String?, alertStyle: NSAlert.Style?) -> Bool {
        return true
    }
    
    func alert(title: String, subtitle: String, okButtonText: String?, alertStyle: NSAlert.Style?) {
        
    }
}

class MockNetworkClient: NetworkRequest {
    var counter = 0
    
    func getRequest(from: URL) async throws -> Data {
        counter += 1
        return "Hello world".data(using: .utf8)!
    }
}

final class SetupPluginTests: XCTestCase {
    
    
    func testDownloadFile() async throws {
        let fileUtils = TestFileUtils()
        let panelUtils = TestNSPanel()
        let network = MockNetworkClient()
        
        let model = SetupModel(networkClient: network)
        model.setup(fileUtils: fileUtils, nsPanel: panelUtils)
        let file = DownloadableFile(name: "test", url: URL(string: "https://google.com")!, downloadPath: "./test.txt")
        try await model.downloadFile(file: file)
        XCTAssertEqual(fileUtils.writtenContent, "Hello world")
    }
    
    func testDownloadFiles() async throws {
        let fileUtils = TestFileUtils()
        let panelUtils = TestNSPanel()
        let network = MockNetworkClient()
        
        let model = SetupModel(networkClient: network)
        model.setup(fileUtils: fileUtils, nsPanel: panelUtils)
        model.files = [DownloadableFile(name: "test", url: URL(string: "https://google.com")!, downloadPath: "./test.txt")]
        try await model.download()
        XCTAssertGreaterThan(model.downloadedFiles.count, 0)
        XCTAssertEqual(model.downloadedFiles.count, model.files.count)
        XCTAssertEqual(network.counter, model.downloadedFiles.count)
    }
}
