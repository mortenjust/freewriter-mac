//
//  Colors.swift
//  freewriter
//
//  Created by Morten Just Petersen on 5/27/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

struct Colors {
    let textForeground = NSColor(red:1, green:1, blue:1, alpha:0.7)
    let focusedEditorForeground = NSColor(red:1, green:1, blue:1, alpha:0.3)
    
    let mainTextColor = NSColor(red:1, green:1, blue:1, alpha:0.7)
    
    let reviewEditorBackground = NSColor(red:0.039, green:0.020, blue:0.239, alpha:0)
//    let editorBackground = NSColor(red:0.047, green:0.031, blue:0.306, alpha:0.7)
    let editorBackground = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
    let stashEditorBackground = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)

    let savedTextForeground = NSColor(red:0, green:0, blue:0, alpha:0.8)
    let sessionEditorForeground = NSColor(red:1, green:1, blue:1, alpha:0.8)
    let stashEditorForeground = NSColor(red:0, green:0, blue:0, alpha:0.8)
    
    let insertionPoint = NSColor(red:1, green:0.341, blue:0.133, alpha:1)
    
    let reviewMessageBackground = NSColor.whiteColor()
    
    let selectedText = NSColor.blackColor()
    let selectedBackground = NSColor.whiteColor()
    
    let emitterPointFromMaxY:CGFloat = 50
    
    let mainFont = "Avenir Next"
    let focusedFont = "Helvetica Neue Thin"
    
    var fontSize : CGFloat = 44
    var focusedDefaultFontSize : CGFloat = 44.0
    var savedTextFontSize : CGFloat = 16.0
    var normalAtts: [String : NSObject]!
    var savedAtts: [String : NSObject]!
    var sessionReviewAtts: [String : NSObject]!
    var stashEditorAtts: [String : NSObject]!
    var fontButtonAtts: [String : NSObject]!
    var focusedEditorPlaceholderAtts: [String : NSObject]!

    init() {
        
        let savedFontSize = NSUserDefaults.standardUserDefaults().floatForKey("fontSize")
        println("saved fontSize: \(savedFontSize)")

        if savedFontSize != 0.0 {
            fontSize = CGFloat(savedFontSize)
        }
        normalAtts = [NSForegroundColorAttributeName : textForeground, NSFontAttributeName : NSFont(name: focusedFont, size: fontSize)!]
        savedAtts = [NSForegroundColorAttributeName : savedTextForeground, NSFontAttributeName : NSFont(name: mainFont, size: savedTextFontSize)!]

        focusedEditorPlaceholderAtts = [NSForegroundColorAttributeName : focusedEditorForeground, NSFontAttributeName : NSFont(name: focusedFont, size: fontSize)!]
        
        // the saved text
        stashEditorAtts = [NSForegroundColorAttributeName : stashEditorForeground, NSFontAttributeName : NSFont(name: mainFont, size: savedTextFontSize)!]
        
        // the session text
        sessionReviewAtts = [NSForegroundColorAttributeName : sessionEditorForeground, NSFontAttributeName : NSFont(name: mainFont, size: savedTextFontSize)!]

        fontButtonAtts = [NSForegroundColorAttributeName : NSColor.whiteColor(), NSFontAttributeName : NSFont(name: mainFont, size: 17)!]
        
    }
  }
