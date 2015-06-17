//
//  FWStashEditor.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol FWStashEditorDelegate : NSTextViewDelegate {
    func stashEditorDidChange()
}

class FWStashEditor: NSTextView {

    let colors = Colors()
    var stashEditorDelegate : FWStashEditorDelegate!
    
    required init?(coder: NSCoder) { // init via storyboard
        super.init(coder: coder)
        typingAttributes = colors.savedAtts
        backgroundColor = colors.editorBackground
        insertionPointColor = NSColor.blackColor()
        self.wantsLayer = true
        }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    override func didChangeText() {
        stashEditorDelegate.stashEditorDidChange()
    }
    
    
}
