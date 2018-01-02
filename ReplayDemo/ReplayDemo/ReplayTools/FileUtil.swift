//
//  FileUtil.swift
//  ReplayDemo
//
//  Created by 刘浩 on 2017/12/25.
//  Copyright © 2017年 HarwordLiu. All rights reserved.
//

import Foundation

class ReplayFileUtil {
    internal class func createReplaysFolder() {
        // path to documents directory
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryPath {
            // create the custom folder path
            let replayDirectoryPath = documentDirectoryPath.appending("/Replays")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: replayDirectoryPath) {
                do {
                    try fileManager.createDirectory(atPath: replayDirectoryPath,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("Error creating Replays folder in documents dir: \(error)")
                }
            }
        }
    }
    
    internal class func filePath(_ fileName: String) -> String {
        createReplaysFolder()
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String = "\(documentsDirectory)/Replays/\(fileName).mp4"
        return filePath
    }
    
    internal class func fetchAllReplays() -> Array<URL> {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let replayPath = documentsDirectory?.appendingPathComponent("/Replays")
        let directoryContents = try! FileManager.default.contentsOfDirectory(at: replayPath!, includingPropertiesForKeys: nil, options: [])
        return directoryContents
    }
    
}



