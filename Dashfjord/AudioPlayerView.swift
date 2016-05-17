//
//  AudioPlayerView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/5/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class AudioPlayerView: NSView {
    
    let backgroundColor = NSColor(calibratedRed: (148.0/255), green: (102.0/255), blue: (179.0/255), alpha: 1)
    let progressColor = NSColor(calibratedRed: (106.0/255), green: (65.0/255), blue: (135.0/255), alpha: 1)
    
    var duration: Double = 1
    var progress: Double = 0 {
        didSet { setNeedsDisplayInRect(bounds) }
    }
    
    var post: Post! {
        didSet {
            if post != nil {
//                if AudioPlayerManager.sharedInstance.currentPost == post {
//                    AudioPlayerManager.sharedInstance.installPlayer(self)
//                }
                
                configureView()
            }
        }
    }
    
    var playPauseButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.action = #selector(AudioPlayerView.playPauseButton(_:))
        button.image = NSImage(named: "play")
        button.bordered = false
        button.imagePosition = .ImageOnly
        (button.cell as? NSButtonCell)?.imageScaling = .ScaleProportionallyUpOrDown
        (button.cell as? NSButtonCell)?.setButtonType(NSButtonType.MomentaryChangeButton)
        NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: button, attribute: .Height, multiplier: 1, constant: 0).active = true
        
        return button
    }()
    
    var infoField: NSTextField = {
        let field = Utils.createResizingLabel()
        field.drawsBackground = false
        
        return field
    }()
    
    var albumArtImageView: NSImageView = {
        let view = NSImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = NSImage(named: "note")
        NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0).active = true
        
        return view
    }()
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init(frame: NSZeroRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(playPauseButton)
        addSubview(infoField)
        addSubview(albumArtImageView)
        
        playPauseButton.target = self
        
        let buttonSize = 32
        let imageSize = 80
        let imageInset = 8
        let buttonInset = imageInset + (imageSize - buttonSize) / 2
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(buttonInset)-[playPauseButton(\(buttonSize))]-\(buttonInset)-[infoField]-\(imageInset)-[albumArtImageView(\(imageSize))]-\(imageInset)-|", options: [], metrics: nil, views: ["playPauseButton": playPauseButton, "infoField": infoField, "albumArtImageView": albumArtImageView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(buttonInset)-[playPauseButton]-\(buttonInset)-|", options: [], metrics: nil, views: ["playPauseButton": playPauseButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(imageInset)-[albumArtImageView]-\(imageInset)-|", options: [], metrics: nil, views: ["albumArtImageView": albumArtImageView]))
        NSLayoutConstraint(item: infoField, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0).active = true
    }
    
    func configureView() {
        var infoString = post.trackName!
        
        if post.artist != nil {
            infoString += "\n" + post.artist!
            
            if post.album != nil {
                infoString += " - " + post.album!
            }
        } else if post.album != nil {
            infoString += "\n" + post.album!
        }
        
        let attInfo = NSMutableAttributedString(string: infoString, attributes: [NSForegroundColorAttributeName: NSColor(white: 1, alpha: 1)])
        attInfo.addAttribute(NSFontAttributeName, value: Font.get(weight: .Bold, size: 14), range: NSMakeRange(0, post.trackName!.characters.count))
        attInfo.addAttribute(NSForegroundColorAttributeName, value: NSColor.whiteColor(), range: NSMakeRange(0, post.trackName!.characters.count))
        
        infoField.attributedStringValue = attInfo
        
        if let albumArt = post.albumArt {
            PhotoCache.sharedInstance.loadURL(albumArt, into: albumArtImageView)
        }
    }
    
    var playing = false {
        didSet {
            if !playing {
                playPauseButton.image = NSImage(named: "play")
            } else {
                playPauseButton.image = NSImage(named: "pause")
            }
        }
    }
    
    @IBAction func playPauseButton(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: post.postURL)!)
//        if playing {
//            AudioPlayerManager.sharedInstance.pause()
//        } else {
//            AudioPlayerManager.sharedInstance.install(post, player: self)
//            AudioPlayerManager.sharedInstance.play()
//        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        backgroundColor.set()
        NSBezierPath(rect: bounds).fill()
        
        if duration != 0 {
            var progressRect = bounds
            progressRect.size.width *= CGFloat(progress / duration)
            
            progressColor.set()
            NSBezierPath(rect: progressRect).fill()
        }
    }
}
