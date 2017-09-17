//
//  AudioPlayerManager.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/6/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class AudioPlayerManager: NSObject {
    
    static let sharedInstance = AudioPlayerManager()
    
    static let ProgressUpdated = "AudioPlayerManagerProgressUpdated"
    static let StateChanged = "AudioPlayerManagerProgressUpdated"
    var audioStreamer: AudioStreamer?
    
    var currentPost: Post? {
        didSet {
            tearDownStreamer()
            
            guard let urlString = currentPost?.audioURL else {
                currentPost = nil
                return
            }
            
            guard let url = URL(string: urlString) else {
                currentPost = nil
                return
            }
            
            buildStreamer(url)
        }
    }
    
    var currentPlayer: AudioPlayerView? {
        willSet {
            invalidateDurationCheckTimer()
            currentPlayer?.playing = false
            currentPlayer?.duration = 1
            currentPlayer?.progress = 0
        }
        
        didSet {
            playbackStateChanged(nil)
            
            guard let a = audioStreamer else { return }
            
            currentPlayer?.duration = a.duration
            currentPlayer?.progress = a.progress
            
            createDurationCheckTimer()
        }
    }
    
    func install(_ post: Post, player: AudioPlayerView) {
        if currentPost != post {
            currentPost = post
        }
        
        if currentPlayer != player {
            currentPlayer = player
        }
    }
    
    func installPlayer(_ player: AudioPlayerView) {
        if currentPlayer != player {
            currentPlayer = player
        }
    }
    
    func play() {
        guard let a = audioStreamer else { return }
        
        a.start()
        createDurationCheckTimer()
    }
    
    func pause() {
        guard let a = audioStreamer else { return }
        
        a.pause()
        invalidateDurationCheckTimer()
    }
    
    private func tearDownStreamer() {
        guard let a = audioStreamer else { return }
        
        if a.isPlaying {
            a.stop()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ASStatusChanged, object: a)
        audioStreamer = nil
        
    }
    
    private func buildStreamer(_ URL: Foundation.URL) {
        if audioStreamer != nil {
            return
        }
        
        audioStreamer = AudioStreamer(url: URL)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayerManager.playbackStateChanged(_:)), name: NSNotification.Name.ASStatusChanged, object: audioStreamer)
    }
    
    func playbackStateChanged(_ n: Notification!) {
        guard let a = audioStreamer else { return }
        
        if a.isWaiting {
            currentPlayer?.playing = false
        } else if a.isPlaying {
            currentPlayer?.playing = true
        } else if a.isPaused {
            currentPlayer?.playing = false
        }
    }
    
    let durationCheckInterval: TimeInterval = 0.1
    var durationCheckTimer: Timer?
    
    func createDurationCheckTimer() {
        if durationCheckTimer == nil {
            durationCheckTimer = Timer.scheduledTimer(timeInterval: durationCheckInterval, target: self, selector: #selector(AudioPlayerManager.fireDurationCheckTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func invalidateDurationCheckTimer() {
        if durationCheckTimer != nil {
            durationCheckTimer!.invalidate()
            durationCheckTimer = nil
        }
    }
    
    func fireDurationCheckTimer(_ timer: Timer?) {
        guard let a = audioStreamer else { return }
        
        currentPlayer?.duration = a.duration
        currentPlayer?.progress = a.progress
    }
}
