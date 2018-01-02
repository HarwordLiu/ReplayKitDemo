//
//  ViewController.swift
//  ReplayDemo
//
//  Created by 刘浩 on 2017/12/25.
//  Copyright © 2017年 HarwordLiu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let player: AVPlayer = AVPlayer(playerItem: nil)
    
    var videoUrl: URL?
    
    let playerItem: AVPlayerItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: "video", ofType: "mp4")!))

    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initRightNavItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVideoPlay()
    }
    
    func initRightNavItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(clickShared))
    }
    
    func startVideoPlay() {
        player.replaceCurrentItem(with: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = containerView.bounds
        containerView.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    @objc func playbackFinished() {
        player.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let timeInterval = NSDate().timeIntervalSinceNow
        ScreenRecordCoordinator.shared().startRecording(withFileName: "replay-\(timeInterval)", recordingHandler: { (error) in
            DispatchQueue.once(token: "recordiing", block: {
                self.player.play()
            })
            
        }) { (error) in
            print("Recording Complete")
            self.player.pause()
            self.videoUrl = URL(fileURLWithPath: ReplayFileUtil.filePath("replay-\(timeInterval)"))
//            PhotoAlbumUtil.saveVideoInAlbum(videoUrl: URL(fileURLWithPath: ReplayFileUtil.filePath("replay-\(timeInterval)")), albumName: "屏幕录制", completion: { (result) in
//            })
        }
        
        
    }
    
    @objc func clickShared() {
        if self.videoUrl != nil {
            let sharedVC = UIActivityViewController(activityItems: [self.videoUrl!], applicationActivities: nil)
            sharedVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
//            sharedVC.popoverPresentationController?.sourceView = self.view
            sharedVC.modalPresentationStyle = .none
            sharedVC.preferredContentSize = CGSize(width: 300, height: 300)
            self.present(sharedVC, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

