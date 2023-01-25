//
//  SwiftUIView.swift
//  
//
//  Created by Qiwei Li on 1/25/23.
//

import SwiftUI

struct DownloadedIndicator: View {
    let downloaded: [DownloadableFile]
    let file: DownloadableFile
    
    var body: some View {
        if let _ = downloaded.first(where: { f in
            f == file
        }) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color.green)
        } else {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color.red)
        }
    }
}

struct DownloadedIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DownloadedIndicator(
            downloaded: [DownloadableFile(name: "a", url: .init(filePath: "/usr"), downloadPath: "./package")], file: DownloadableFile(name: "a", url: .init(filePath: "/usr"), downloadPath: "./package")
        )
        DownloadedIndicator(
            downloaded: [DownloadableFile(name: "b", url: .init(filePath: "/usr"), downloadPath: "./package")], file: DownloadableFile(name: "a", url: .init(filePath: "/usr"), downloadPath: "./package")
        )
    }
}
