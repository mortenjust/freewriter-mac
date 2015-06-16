//
//  FWStashEditor.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class FWStashEditor: NSTextView {
    
    var parentView : NSView!
    let colors = Colors()
    
    required init?(coder: NSCoder) { // init via storyboard
        super.init(coder: coder)
        typingAttributes = colors.savedAtts
        backgroundColor = colors.editorBackground
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
    func positionInParentView(){
        self.frame = parentView.bounds
    }
    
}
