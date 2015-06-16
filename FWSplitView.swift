//
//  FWSplitView.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class FWSplitView: NSSplitView {
    var parentView : NSView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       // setPosition(<#position: CGFloat#>, ofDividerAtIndex: <#Int#>)
    }

    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
    }
    
}
