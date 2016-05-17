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
            
            guard let url = NSURL(string: urlString) else {
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
    
    func install(post: Post, player: AudioPlayerView) {
        if currentPost != post {
            currentPost = post
        }
        
        if currentPlayer != player {
            currentPlayer = player
        }
    }
    
    func installPlayer(player: AudioPlayerView) {
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
        
        if a.playing {
            a.stop()
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ASStatusChangedNotification, object: a)
        audioStreamer = nil
        
    }
    
    private func buildStreamer(URL: NSURL) {
        if audioStreamer != nil {
            return
        }
        
        audioStreamer = AudioStreamer(URL: URL)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AudioPlayerManager.playbackStateChanged(_:)), name: ASStatusChangedNotification, object: audioStreamer)
    }
    
    func playbackStateChanged(n: NSNotification!) {
        guard let a = audioStreamer else { return }
        
        if a.waiting {
            currentPlayer?.playing = false
        } else if a.playing {
            currentPlayer?.playing = true
        } else if a.paused {
            currentPlayer?.playing = false
        }
    }
    
    let durationCheckInterval: NSTimeInterval = 0.1
    var durationCheckTimer: NSTimer?
    
    func createDurationCheckTimer() {
        if durationCheckTimer == nil {
            durationCheckTimer = NSTimer.scheduledTimerWithTimeInterval(durationCheckInterval, target: self, selector: #selector(AudioPlayerManager.fireDurationCheckTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func invalidateDurationCheckTimer() {
        if durationCheckTimer != nil {
            durationCheckTimer!.invalidate()
            durationCheckTimer = nil
        }
    }
    
    func fireDurationCheckTimer(timer: NSTimer?) {
        guard let a = audioStreamer else { return }
        
        currentPlayer?.duration = a.duration
        currentPlayer?.progress = a.progress
    }
}
