//
//  PostLinkView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/1/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class PostLinkViewController: PostContentViewController {

    let stackView = TrailStackView()
    
    var photoView: TrimScaleImageButton!
    let publisherLabelPhoto = Utils.createLabel(font: Font.get(weight: .Bold, size: 13), textColor: NSColor.whiteColor())
    
    let infoView = ColorView()
    let infoStackView = WidthStretchingStackView()
    let publisherLabelInfo = Utils.createLabel(font: Font.get(weight: .Bold, size: 13))
    let authorLabel = Utils.createLabel(font: Font.get(size: 13), textColor: NSColor(white: (162.0/255), alpha: 1))
    
    let infoButton: NSButton = {
        let button = NSButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.action = #selector(PostLinkViewController.openURL(_:))
        button.bordered = false
        button.imagePosition = .ImageOnly
        (button.cell as? NSButtonCell)?.setButtonType(.MomentaryChangeButton)
        
        return button
    }()
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    required init() {
        super.init()
        
        infoStackView.edgeInsets = NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        infoButton.target = self
        
        infoView.color = NSColor(white: (242.0/255), alpha: 1)
        infoView.setNeedsDisplayInRect(infoView.bounds)
        infoView.addSubview(infoStackView)
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[sv]-0-|", options: [], metrics: nil, views: ["sv": infoStackView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[sv]-0-|", options: [], metrics: nil, views: ["sv": infoStackView]))
        infoView.addSubview(infoButton)
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[ib]-0-|", options: [], metrics: nil, views: ["ib": infoButton]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[ib]-0-|", options: [], metrics: nil, views: ["ib": infoButton]))
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
        NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView": stackView]))
    }
    
    override func configureView() {
        stackView.removeAllViews()
        infoStackView.removeAllViews()
        
        if let photo = post.photos?[0] {
            photoView = Utils.createPostImageView(0, width: CGFloat(Utils.postWidth), aspect: photo.aspectRatio, target: self, action: #selector(PostLinkViewController.openURL(_:)))
            PhotoCache.sharedInstance.loadURL(photo.URLAppropriateForWidth(Utils.postWidth), into: photoView)
            
            let gradient = LinearGradientView()
            gradient.translatesAutoresizingMaskIntoConstraints = false
            photoView.addSubview(gradient)
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[gradient]-0-|", options: [], metrics: nil, views: ["gradient": gradient]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[gradient(\(photo.height / 2))]", options: [], metrics: nil, views: ["gradient": gradient]))
            
            photoView.addSubview(publisherLabelPhoto)
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label]", options: [], metrics: nil, views: ["label": publisherLabelPhoto]))
            NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[label]", options: [], metrics: nil, views: ["label": publisherLabelPhoto]))
            
            if let publisher = post.publisher {
                publisherLabelPhoto.stringValue = publisher
                publisherLabelPhoto.hidden = false
            } else {
                publisherLabelPhoto.hidden = true
            }
            
            stackView.addView(photoView, inGravity: .Center, inset: 0)
        } else {
            if let publisher = post.publisher {
                publisherLabelInfo.stringValue = publisher
                infoStackView.addView(publisherLabelInfo, inGravity: .Center, inset: 20)
            }
        }
        
        let titleLabel = Utils.createResizingLabel()
        titleLabel.selectable = false
        titleLabel.font = Font.get(.Title, weight: .Bold, size: 24)
        infoStackView.addView(titleLabel, inGravity: .Center, inset: 20)
        
        if let title = post.title {
            titleLabel.stringValue = "\(title) ›"
        } else {
            titleLabel.stringValue = "\(post.URL!) ›"
        }
        
        if let excerpt = post.excerpt {
            let excerptLabel = Utils.createResizingLabel()
            excerptLabel.font = Font.get(size: 14)
            excerptLabel.stringValue = excerpt
            
            infoStackView.addView(excerptLabel, inGravity: .Center, inset: 20)
        }
        
        if let author = post.linkAuthor {
            authorLabel.stringValue = "By \(author)"
            infoStackView.addView(authorLabel, inGravity: .Center, inset: 20)
        }
        
        stackView.addView(infoView, inGravity: .Center, inset: 0)
        
        stackView.addTrail(post.trail, includeFirstHorizontalLine: false)
    }
    
    @IBAction func openURL(sender: AnyObject!) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: post.URL!)!)
    }
    
}
