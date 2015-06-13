//
//  UserInstruction.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/12/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class UserInstruction: NSTextField {
    var colors = Colors()
    
    func show(focusedEditor f:FocusedEditor, view v:NSView, instruction i : String){
        let frame = CGRectMake(-200, f.frame.origin.y + f.heightOfString(), 200, 30)
        println(frame)
        var instructionLabel = NSTextView(frame: frame)
        instructionLabel.backgroundColor = NSColor.clearColor()
        instructionLabel.typingAttributes = colors.normalAtts
        instructionLabel.font = NSFont(name: colors.focusedFont, size: 13)
        instructionLabel.string = i
        v.addSubview(instructionLabel)
        instructionLabel.editable = false
        
        let instructionAnim = MJPOPBasic(view: instructionLabel, propertyName: kPOPLayerPositionX, toValue: 0, easing: MJEasing.easeOut, repeatCount:0, duration: 1, delay: 0, autoreverses: false, runNow: false, animationName: "animateOut")
        instructionAnim.completionBlock = { (one, two) -> Void in
            
            let animateOut = MJPOPBasic(view: instructionLabel, propertyName: kPOPLayerPositionX, toValue: -200, easing: .easeInOut, duration: 1, delay: 2, autoreverses: false, repeatCount: 0, repeatForever: false, runNow: true, animationName: "animateOut")
        }
        
        runMJAnim(instructionLabel, instructionAnim, "animateOut")
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
