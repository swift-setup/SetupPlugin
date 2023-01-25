//
//  File.swift
//  
//
//  Created by Qiwei Li on 1/25/23.
//

import Foundation
import PluginInterface
import AppKit

class MockFileUtils: FileUtilsProtocol {
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
 
    func list() throws -> [String] {
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

class MockNSPanel: NSPanelUtilsProtocol {
    func confirm(title: String, subtitle: String, confirmButtonText: String?, cancelButtonText: String?, alertStyle: NSAlert.Style?) -> Bool {
        return true
    }
    
    func alert(title: String, subtitle: String, okButtonText: String?, alertStyle: NSAlert.Style?) {
        
    }
}
