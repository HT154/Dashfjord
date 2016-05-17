//
//  TrailContentView.swift
//  Dashfjord
//
//  Created by Joshua Basch on 10/22/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class TrailContentView: WidthStretchingStackView, DTHTMLParserDelegate {
    
    let inlineElements = NSSet(array: ["a", "b", "strong", "i", "em", "big", "small", "code", "br", "img", "span", "sub", "sup", "strike"])
    let blockElements = NSSet(array: ["h1", "h2", "h3", "h4", "h5", "h6", "blockquote", "div", "figure", "hr", "p", "pre", "ol", "ul", "li"])
    
    var parser: DTHTMLParser!
    
    var elStack: [String] = []
    var attrStack: [[NSObject : AnyObject]?] = []
    var stackStack: [WidthStretchingStackView] = []
    var liCountStack: [Int] = []
    
    var lastEnded = ""
    
    var buildingString = NSMutableAttributedString()
    
    func parseString(string: String, encoding: NSStringEncoding = NSUTF16StringEncoding) {
        parseData(string.dataUsingEncoding(encoding)!, encoding: encoding)
    }
    
    func parseData(data: NSData, encoding: NSStringEncoding = NSUTF16StringEncoding) {
        parser = DTHTMLParser(data: data, encoding: encoding)
        parser.delegate = self
        parser.parse()
    }
    
    // MARK: - DTHTMLParserDelegate Methods
    
    func parser(parser: DTHTMLParser!, didStartElement elementName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        if !isValidElement(elementName) { return }
        
        elStack.append(elementName)
        attrStack.append(attributeDict)
        
        if blockElements.containsObject(elementName) {
            buildingString = NSMutableAttributedString()
            
            switch elementName {
            case "blockquote":
                stackStack.append(WidthStretchingStackView())
            case "ul", "ol":
                let view = WidthStretchingStackView()
                view.spacing = 0
                stackStack.append(view)
                liCountStack.append(0)
            default: break
            }
        } else if elementName == "br" {
            buildingString.appendAttributedString(NSAttributedString(string: "\n"))
        } else if inlineElements.containsObject(elementName) && inlineElements.containsObject(lastEnded) {
            buildingString.appendAttributedString(NSAttributedString(string: " "))
        }
    }
    
    func parser(parser: DTHTMLParser!, didEndElement elementName: String!) {
        if !isValidElement(elementName) { return }
        
        if blockElements.containsObject(elementName) {
            switch elementName {
            case "div", "figure": break
            case "blockquote":
                let view = NSView()
                view.translatesAutoresizingMaskIntoConstraints = false
                
                let cv = ColorView()
                cv.translatesAutoresizingMaskIntoConstraints = false
                cv.color = NSColor(white: (231.0/255), alpha: 1)
                view.addSubview(cv)
                
                let bq = stackStack.popLast()!
                view.addSubview(bq)
                
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[cv]-0-|", options: [], metrics: nil, views: ["cv": cv]))
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[bq]-0-|", options: [], metrics: nil, views: ["bq": bq]))
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[cv(2)]-(-2)-[bq]-20-|", options: [], metrics: nil, views: ["cv": cv, "bq": bq]))
                
                stackStack.last!.addView(view, inGravity: .Center, insetLeft: 20, insetRight: 0)
            case "ol", "ul":
                let view = stackStack.popLast()!
                liCountStack.popLast()
                
                var leftInset: CGFloat = 20
                
                if (elStack as NSArray).indexesOfObjectsPassingTest({ (obj, idx, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                    let str = obj as! String
                    return str == "ul" || str == "ol"
                }).count > 1 {
                    leftInset = 35
                }
                
                stackStack.last!.addView(view, inGravity: .Center, insetLeft: leftInset, insetRight: 0)
            case "li":
                let view = NSView()
                view.translatesAutoresizingMaskIntoConstraints = false
                
                liCountStack.append(liCountStack.last! + 1)
                let b = viewForCurrentList
                
                let v = Utils.createResizingLabel()
                v.attributedStringValue = trim(buildingString)
                
                view.addSubview(b)
                view.addSubview(v)
                
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[b]-0-|", options: [], metrics: nil, views: ["b": b]))
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": v]))
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[b(20)]-0-[v]-0-|", options: [], metrics: nil, views: ["v": v, "b": b]))
                
                stackStack.last!.addView(view, inGravity: .Center, inset: 20)
            case "pre":
                let view = ColorView()
                view.color = NSColor(white: (233.0/255), alpha: 1)
                
                let v = Utils.createResizingLabel()
                v.attributedStringValue = trim(buildingString)
                
                view.addSubview(v)
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[v]-10-|", options: [], metrics: nil, views: ["v": v]))
                NSLayoutConstraint.activateConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[v]-10-|", options: [], metrics: nil, views: ["v": v]))
                
                stackStack.last!.addView(view, inGravity: .Center, inset: 20)
            case "hr":
                let view = HorizontalLineView()
                addView(view, inGravity: .Center, inset: 200)
            default:
                if buildingString.length == 0 { break }
                
                let view = Utils.createResizingLabel()
                view.attributedStringValue = trim(buildingString)
                stackStack.last!.addView(view, inGravity: .Center, inset: 20)
            }
        } else if elementName == "img" {
            let view: TrimScaleImageButton
            
            if let src = attr("src", forElement: "img") as? String {
                if attr("class", forElement: "figure") as? String == "tmblr-full" && !elStack.contains("blockquote") && !elStack.contains("ol") && !elStack.contains("ul") {
                    view = TrimScaleImageButton(autosizeAspect: true, autosizeWidth: false)
                    stackStack.last!.addView(view, inGravity: .Center, inset: 0)
                } else {
                    view = TrimScaleImageButton(autosizeAspect: true, autosizeWidth: true)
                    stackStack.last!.addView(view, inGravity: .Center, inset: 20, flexibleRight: true)
                }
                
                if let href = attr("href", forElement: "a") {
                    view.setLink(NSURL(string: href as! String))
                }
                
                PhotoCache.sharedInstance.loadURL(src, into: view)
            }
        }
        
        lastEnded = elStack.popLast()!
        attrStack.popLast()
    }
    
    func parser(parser: DTHTMLParser!, foundCharacters string: String!) {
        var chars = string
        
        if !elStack.contains("pre") {
            chars = chars.stringByReplacingOccurrencesOfString("\t", withString: "")
            chars = chars.stringByReplacingOccurrencesOfString("\n", withString: "")
            chars = chars.stringByReplacingOccurrencesOfString("\r", withString: "")
            do {
                try chars = NSRegularExpression(pattern: " +", options: []).stringByReplacingMatchesInString(chars, options: [], range: NSMakeRange(0, chars.characters.count), withTemplate: " ")
            } catch {}
        } else {
            while chars.characters.last == "\n" {
                chars = chars.substringToIndex(chars.endIndex.predecessor())
            }
        }
        
        buildingString.appendAttributedString(NSAttributedString(string: chars, attributes: currentAttributes))
        
        lastEnded = ""
    }
    
    func parserDidStartDocument(parser: DTHTMLParser!) {
        stackStack.append(self)
        liCountStack.append(0)
    }
    
    func parserDidEndDocument(parser: DTHTMLParser!) {
        stackStack.last!.addView(VerticalSpacer(height: 2), inGravity: .Center, inset: 0)
    }
    
    // MARK: - Helper functions
    
    private func isValidElement(el: String) -> Bool {
        return inlineElements.containsObject(el) || blockElements.containsObject(el)
    }
    
    private func attr(attrName: NSObject, forElement element: String) -> AnyObject? {
        var elIndex = elStack.endIndex.predecessor()
        
        while elIndex >= 0 {
            if elStack[elIndex] == element {
                if let attr = attrStack[elIndex]?[attrName] {
                    return attr
                }
            }
            
            elIndex = elIndex.predecessor()
        }
        
        return nil
    }
    
    private var viewForCurrentList: NSView {
        let view: NSView
        
        if elStack[elStack.count - 2] == "ul" {
            let v = BulletView()
            
            if (elStack as NSArray).indexesOfObjectsPassingTest({ (obj, idx, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
                let str = obj as! String
                return str == "ul" || str == "ol"
            }).count > 1 {
                v.fill = false
            }
            
            view = v
        } else if elStack[elStack.count - 2] == "ol" {
            let v = Utils.createResizingLabel()
            v.stringValue = "\(liCountStack.last!)."
            v.font = Font.get(size: 14)
            
            view = v
        } else {
            view = BulletView()
        }
        
        return view
    }
    
    private var currentAttributes: [String: AnyObject] {
        get {
            var out: [String: AnyObject] = [:]
            
            var font = Font.Face.Body
            var size: CGFloat = 14
            var weight = Font.Weight.Regular
            var italic = false
            var baseline = 0
            var underline = false
            var strike = false
            
            for el in elStack {
                switch el {
                case "a":
                    underline = true
                case "h1", "h2":
                    font = .Title
                    size = 20
                case "h3", "h4", "h5", "h6":
                    font = .Body
                    size = 14
                    
                    if weight == .Regular {
                        weight = .SemiBold
                    }
                case "b", "strong":
                    weight = .Bold
                case "i", "em":
                    italic = true
                case "code", "pre":
                    font = .Monospace
                case "sup":
                    size -= 2
                    baseline += 1
                case "sub":
                    size -= 2
                    baseline -= 1
                case "big":
                    size = 14
                case "small":
                    size = 12
                case "strike":
                    strike = true
                default: break
                }
            }
            
            out[NSFontAttributeName] = Font.get(font, weight: weight, italic: italic, size: size)
            out[NSForegroundColorAttributeName] = Utils.bodyTextColor
            out[NSSuperscriptAttributeName] = baseline
            out[NSUnderlineStyleAttributeName] = underline ? NSUnderlineStyle.StyleSingle.rawValue : NSUnderlineStyle.StyleNone.rawValue
            out[NSUnderlineColorAttributeName] = Utils.bodyTextColor
            out[NSStrikethroughStyleAttributeName] = strike ? NSUnderlineStyle.StyleSingle.rawValue : NSUnderlineStyle.StyleNone.rawValue
            out[NSStrikethroughColorAttributeName] = Utils.bodyTextColor
            
            if let link = attr("href", forElement: "a") {
                out[NSLinkAttributeName] = NSURL(string: link as! String)
            }
            
            return out
        }
    }
    
    private func trim(str: NSMutableAttributedString) -> NSMutableAttributedString {
        while str.string.characters.last == "\n" {
            str.deleteCharactersInRange(NSMakeRange(str.string.characters.count - 1, 1))
        }
        
        return str
    }
    
}
