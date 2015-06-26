//
//  FWButtonCell.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/16/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class FWButtonCell: NSButtonCell {
    let colors = Colors()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        bordered = false
        backgroundColor = NSColor.clearColor()
        alignment = NSTextAlignment.CenterTextAlignment
        attributedTitle = NSAttributedString(string: "Continue writing", attributes: colors.sessionReviewAtts)
    }
    
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        super.drawBezelWithFrame(frame, inView: controlView)
        println("draw bezel with frame")
    }


}
