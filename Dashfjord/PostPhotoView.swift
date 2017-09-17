//
//  PostPhotoView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/26/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostPhotoViewController: PostContentViewController {
    
    let stackView = TrailStackView()
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        
        var photoCounter = 0
        
        for row in post.photosetLayout {
            let width: CGFloat = (Utils.postWidth - 4 * CGFloat(row - 1)) / CGFloat(row)
            let photoRowView: NSView
            
            switch row {
            case 1:
                let photo1 = post.photos![photoCounter]; photoCounter += 1
                
                let aspect = photo1.aspectRatio
                
                let photoView1 = Utils.createPostImageView(photoCounter - 1, width: width, aspect: aspect, target: self, action: #selector(PostPhotoViewController.clickPhotoButton(_:)))
                PhotoCache.sharedInstance.loadURL(photo1.URLAppropriateForWidth(Utils.postWidth), into: photoView1)
                
                photoRowView = photoView1
            case 2:
                let photo1 = post.photos![photoCounter]; photoCounter += 1
                let photo2 = post.photos![photoCounter]; photoCounter += 1
                
                let aspect = max(photo1.aspectRatio, photo2.aspectRatio)
                
                let photoView1 = Utils.createPostImageView(photoCounter - 2, width: width, aspect: aspect, target: self, action: #selector(PostPhotoViewController.clickPhotoButton(_:)))
                PhotoCache.sharedInstance.loadURL(photo1.URLAppropriateForWidth(width), into: photoView1)
                
                let photoView2 = Utils.createPostImageView(photoCounter - 1, width: width, aspect: aspect, target: self, action: #selector(PostPhotoViewController.clickPhotoButton(_:)))
                PhotoCache.sharedInstance.loadURL(photo2.URLAppropriateForWidth(width), into: photoView2)
                
                photoRowView = NSView()
                photoRowView.translatesAutoresizingMaskIntoConstraints = false
                
                photoRowView.addSubview(photoView1)
                photoRowView.addSubview(photoView2)
                
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[photo1]-0-|", options: [], metrics: nil, views: ["photo1": photoView1]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[photo2]-0-|", options: [], metrics: nil, views: ["photo2": photoView2]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[photo1]-4-[photo2]-0-|", options: [], metrics: nil, views: ["photo1": photoView1, "photo2": photoView2]))
            case 3:
                let photo1 = post.photos![photoCounter]; photoCounter += 1
                let photo2 = post.photos![photoCounter]; photoCounter += 1
                let photo3 = post.photos![photoCounter]; photoCounter += 1
                
                let aspect = max(photo1.aspectRatio, photo2.aspectRatio, photo3.aspectRatio)
                
                let photoView1 = Utils.createPostImageView(photoCounter - 3, width: width, aspect: aspect, target: self, action: #selector(PostPhotoViewController.clickPhotoButton(_:)))
                PhotoCache.sharedInstance.loadURL(photo1.URLAppropriateForWidth(width), into: photoView1)
                
                let photoView2 = Utils.createPostImageView(photoCounter - 2, width: width, aspect: aspect, target: self, action: #selector(PostPhotoViewController.clickPhotoButton(_:)))
                PhotoCache.sharedInstance.loadURL(photo2.URLAppropriateForWidth(width), into: photoView2)
                
                let photoView3 = Utils.createPostImageView(photoCounter - 1, width: width, aspect: aspect, target: self, action: #selector(PostPhotoViewController.clickPhotoButton(_:)))
                PhotoCache.sharedInstance.loadURL(photo3.URLAppropriateForWidth(width), into: photoView3)
                
                photoRowView = NSView()
                photoRowView.translatesAutoresizingMaskIntoConstraints = false
                
                photoRowView.addSubview(photoView1)
                photoRowView.addSubview(photoView2)
                photoRowView.addSubview(photoView3)
                
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[photo1]-0-|", options: [], metrics: nil, views: ["photo1": photoView1]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[photo2]-0-|", options: [], metrics: nil, views: ["photo2": photoView2]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[photo3]-0-|", options: [], metrics: nil, views: ["photo3": photoView3]))
                NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[photo1]-4-[photo2]-4-[photo3]-0-|", options: [], metrics: nil, views: ["photo1": photoView1, "photo2": photoView2, "photo3": photoView3]))
            default:
                photoRowView = NSView()
            }
            
            stackView.addView(photoRowView, in: .center)
            
            if photoCounter != post.photos!.count {
                stackView.addView(VerticalSpacer(height: 4), in: .center)
            } else {
                stackView.addView(VerticalSpacer(height: 5), in: .center)
            }
        }
        
        if post!.trail.count > 0 {
            stackView.addTrail(post!.trail, includeFirstHorizontalLine: false)
        } else {
            stackView.addView(VerticalSpacer(height: 4), in: .center)
        }
    }
    
    @IBAction func clickPhotoButton(_ sender: TrimScaleImageButton!) {
        let wc = view.window!.contentViewController!.storyboard!.instantiateController(withIdentifier: "enlargedPhotosWindow") as! NSWindowController
        (wc.window! as! WAYWindow).titleBarView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        let vc = (wc.window!.contentViewController! as! EnlargedPhotosViewController).pageController
        
        vc?.transitionStyle = .horizontalStrip
        vc?.delegate = vc
        vc?.objectsToShow = post.photos!
        vc?.indexToSelect = sender.tag
        
        let windowPoint = sender.superview!.convert(sender.frame.origin, to: nil)
        let newRect = view.window!.convertToScreen(NSMakeRect(windowPoint.x, windowPoint.y, sender.bounds.size.width, sender.bounds.size.height))
        
        wc.window!.makeKeyAndOrderFront(nil)
        wc.window!.setFrame(newRect, display: false, animate: false)
        wc.window!.toggleFullScreen(nil)
    }
    
}
