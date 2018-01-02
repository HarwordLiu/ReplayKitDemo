//
//  ScreenRecorder.swift
//  ReplayDemo
//
//  Created by 刘浩 on 2017/12/25.
//  Copyright © 2017年 HarwordLiu. All rights reserved.
//

import Foundation
import ReplayKit
import AVKit



class ScreenRecorder {
    var assetWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    var audioMicInput: AVAssetWriterInput!
    var audioAppInput: AVAssetWriterInput!
    
    let viewOverlay = WindowUtil()
    
    //MARK: Screen Recording
    func startRecording(withFileName fileName: String, recordingHandler:@escaping (Error?)-> Void) {
        if #available(iOS 11.0, *) {
            
            let fileURL = URL(fileURLWithPath: ReplayFileUtil.filePath(fileName))
            assetWriter = try! AVAssetWriter(outputURL: fileURL, fileType:
                AVFileType.mp4)
            let videoOutputSettings: Dictionary<String, Any> = [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoWidthKey : UIScreen.main.bounds.size.width,
                AVVideoHeightKey : UIScreen.main.bounds.size.height
            ]
            
//            AVChannelLayoutKey : Data(bytes: AVChannelLayoutKey, count: MemoryLayout<AudioChannelLayout>.size),  // 声音效果（立体声）
//            AVLinearPCMBitDepthKey : 16,  // 音频的每个样点的位数
//            AVLinearPCMIsNonInterleaved : false,  // 音频采样是否非交错
//            AVLinearPCMIsFloatKey : false,    // 采样信号是否浮点数
//            AVLinearPCMIsBigEndianKey : false // 音频采用高位优先的记录格式
            
            let audioOutputSettings: Dictionary<String, Any> = [
                AVFormatIDKey : kAudioFormatMPEG4AAC_LD,    // 音频格式
                AVSampleRateKey : 44100,    // 采样率
                AVNumberOfChannelsKey : 1    // 通道数 1 || 2
            ]
            
            
            videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
            videoInput.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(videoInput) {
                print("添加视频通道")
                assetWriter.add(videoInput)
            }
            
            
            audioMicInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
            audioMicInput.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(audioMicInput) {
                print("添加app麦克风通道")
                assetWriter.add(audioMicInput)
            }

            audioAppInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
            audioAppInput.expectsMediaDataInRealTime = true
            if assetWriter.canAdd(audioAppInput) {
                print("添加app音频通道")
                assetWriter.add(audioAppInput)
            }
            
            RPScreenRecorder.shared().isMicrophoneEnabled = true
            RPScreenRecorder.shared().startCapture(handler: { (sample, bufferType, error) in

                recordingHandler(error)
                
                if CMSampleBufferDataIsReady(sample)
                {
                    if self.assetWriter.status == AVAssetWriterStatus.unknown
                    {
                        self.assetWriter.startWriting()
                        self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                    }
                
                    if self.assetWriter.status == AVAssetWriterStatus.failed {
                        print("Error occured, status = \(self.assetWriter.status.rawValue), \(self.assetWriter.error!.localizedDescription) \(String(describing: self.assetWriter.error))")
                        return
                    }
                    switch bufferType {
                    case .video:
                        print("video")
                        if self.videoInput.isReadyForMoreMediaData {
                            self.videoInput.append(sample)
                        }
                        break
                    case .audioMic:
                        print("audioMic")
                        if self.audioMicInput.isReadyForMoreMediaData {
                            self.audioMicInput.append(sample)
                        }
                        break
                    case .audioApp:
                        print("audioApp")
                        if self.audioAppInput.isReadyForMoreMediaData {
                            self.audioAppInput.append(sample)
                        }
                        break
                    }
                }
                
            }) { (error) in
                recordingHandler(error)
                //                debugPrint(error)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func stopRecording(handler: @escaping (Error?) -> Void) {
        if #available(iOS 11.0, *) {
            RPScreenRecorder.shared().stopCapture
                {    (error) in
                    handler(error)
                    self.assetWriter.finishWriting
                        {
                            print(ReplayFileUtil.fetchAllReplays())
                            
                    }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
}

