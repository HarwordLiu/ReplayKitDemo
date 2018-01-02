//
//  ScreenRecordCoordinator.swift
//  ReplayDemo
//
//  Created by 刘浩 on 2017/12/25.
//  Copyright © 2017年 HarwordLiu. All rights reserved.
//

import Foundation

private let instance: ScreenRecordCoordinator = ScreenRecordCoordinator()

class ScreenRecordCoordinator: NSObject {
    
    open class func shared() -> ScreenRecordCoordinator {
        return instance
    }
    
    let viewOverlay = WindowUtil()
    let screenRecorder = ScreenRecorder()
    var recordCompleted:((Error?) ->Void)?
    
    override init() {
        super.init()
        
        viewOverlay.onStopClick = {
            self.stopRecording()
        }
    }
    
    func startRecording(withFileName fileName: String, recordingHandler: @escaping (Error?) -> Void,onCompletion: @escaping (Error?)->Void) {
        self.viewOverlay.show()
        screenRecorder.startRecording(withFileName: fileName) { (error) in
            recordingHandler(error)
            self.recordCompleted = onCompletion
        }
    }
    
    func stopRecording() {
        screenRecorder.stopRecording { (error) in
            self.viewOverlay.hide()
            self.recordCompleted?(error)
        }
    }
    
    class func listAllReplays() -> Array<URL> {
        return ReplayFileUtil.fetchAllReplays()
    }
    
    
}

