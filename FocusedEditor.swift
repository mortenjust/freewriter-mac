//
//  FocusedEditor.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/4/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

protocol FocusedEditorWritingDelegate {
    func focusedEditorUserTypedReallyFast()
    func focusedEditorUserLostFocus()
    func focusedEditorTextChangedTo(newString:String)
    func focusedEditorSessionPointChanged(byPoints:Double)
}

class FocusedEditor: NSTextField, NSTextFieldDelegate {
    var backspacePressed = true
    var focusedFontSize : CGFloat!
    let colors = Colors()
    var jumpHowHigh:CGFloat = 0
    var jumpHowHighTimer:NSTimer!
    var lostFocusTimer:NSTimer!
    var writingDelegate : FocusedEditorWritingDelegate!
    var parentView:NSView!
    
    func setup(){
        self.backgroundColor = NSColor.clearColor()
        self.bordered = false
        self.alignment = NSTextAlignment.LeftTextAlignment
        self.font = NSFont(name: colors.focusedFont, size: colors.fontSize)
        self.delegate = self
        setPlaceholder("Start writing")
    }
    
    func setPlaceholder(text : String){
        placeholderAttributedString = NSAttributedString(string: text, attributes: colors.focusedEditorPlaceholderAtts)
    }
    
    func biggerFont(){
        let newSize = self.font!.pointSize + CGFloat(2)
        self.font = NSFont(name: colors.focusedFont, size: newSize)
        positionInView(self.superview!)
        NSUserDefaults.standardUserDefaults().setFloat(Float(newSize), forKey: "fontSize")
    }
    
    func smallerFont(){
        let newSize = self.font!.pointSize - CGFloat(2)
        self.font = NSFont(name: colors.focusedFont, size: newSize)
        positionInView(self.superview!)
        NSUserDefaults.standardUserDefaults().setFloat(Float(newSize), forKey: "fontSize")        
    }
    
    func heightOfString() -> CGFloat {
        let atts = self.attributedStringValue.attributesAtIndex(0, effectiveRange: nil)
        let size:NSSize = NSString(string: self.stringValue).sizeWithAttributes(atts)
        return size.height
    }
    
    func sizeOfString() -> NSSize {
        let atts = self.attributedStringValue.attributesAtIndex(0, effectiveRange: nil)
        let size:NSSize = NSString(string: self.stringValue).sizeWithAttributes(atts)
        return size
    }
    
    func positionInView(view:NSView){
        self.frame.size.width = view.bounds.width-Colors().emitterPointFromMaxY
        self.frame.size.height = heightOfString()
        self.frame.origin.y = CGRectGetMidY(view.bounds) - (heightOfString()/2)
    }
    
    func resetJumpHowHigh(){
        jumpHowHigh = 0
    }
    
    func animate(view:NSView){
        
        if (self.layer?.pop_animationForKey("MoveUpOnType") != nil || self.backspacePressed == true){
        } else {
            self.writingDelegate.focusedEditorUserTypedReallyFast()

            if bounds.origin.y < view.bounds.height-10 {
                jumpHowHigh += 0.5
            }

            // make it hard for the text to reach the top of the window
            let adjustedJump = min(pow(CGFloat(jumpHowHigh), 0.7), 5*log(CGFloat(jumpHowHigh)))
            let jumpTo = CGRectGetMidY(view.bounds) - (self.bounds.height/2) + adjustedJump
            
            var animUp = MJPOPSpring(view: self, propertyName: kPOPLayerPositionY, toValue: jumpTo, springBounciness: 0.01, springSpeed: 13.8, dynamicsTension: 71.6, dynamicsFriction: 8.7, dynamicsMass: 2.4, animationName: "jumpUpWhenWriting", runNow: true)
            animUp.removedOnCompletion = true
            animUp.completionBlock = {(one, two) -> Void in // start the decay
            
                if let lft = self.lostFocusTimer {
                    lft.invalidate() // no, full focus, don't trigger
                    }
                
                // reset the extra jump if the user has been inactive for this long
                let inactiveTimeOut:Double = 0.8
                if let j = self.jumpHowHighTimer {
                    self.jumpHowHighTimer.invalidate()
                    }
                self.jumpHowHighTimer = NSTimer.scheduledTimerWithTimeInterval(inactiveTimeOut, target: self, selector: "resetJumpHowHigh", userInfo: nil, repeats: false)
                
                self.layer?.pop_removeAllAnimations()

                MJPOPSpring(view: self, propertyName: kPOPLayerPositionY, toValue: 20, delay:0.1, repeatForever: false, springBounciness: 0.01, springSpeed: 13.8, dynamicsTension: 19.9, dynamicsFriction: 20, dynamicsMass: 16.6, animationName: "animateTextDown", runNow: true)
                MJPOPBasic(view: self, propertyName: kPOPLayerOpacity, toValue: 0.16, easing: MJEasing.easeInOut, duration: 1, delay: 0.1)
                
                self.lostFocusTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "userLostFocus", userInfo: nil, repeats: false)
                
            } // completionblock
            
            runMJAnim(self, animUp, "MoveUpOnType")
            MJPOPBasic(view: self, propertyName: kPOPLayerOpacity, toValue: 1, easing: MJEasing.easeOut, duration: 0.2, delay: 0)
        }
    }


    
    
    func userLostFocus(){
        writingDelegate.focusedEditorUserLostFocus()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    
    func control(control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
        
        
        if commandSelector == Selector("insertLineBreak:") ||
            commandSelector == Selector("insertNewline:") ||
            commandSelector == Selector("insertTab:") ||
            commandSelector == Selector("moveBackward:") ||
            commandSelector == Selector("moveDown:") ||
            commandSelector == Selector("moveForward:") ||
            commandSelector == Selector("moveLeft:") ||
            commandSelector == Selector("moveRight:") ||
            commandSelector == Selector("pageDown:") ||
            commandSelector == Selector("deleteWordBackward:") ||
            commandSelector == Selector("pageUp:") ||
            commandSelector == Selector("moveWordLeftAndModifySelection:") ||
            commandSelector == Selector("moveLeftAndModifySelection:") ||
            commandSelector == Selector("moveToLeftEndOfLineAndModifySelection:") ||
            //            commandSelector == Selector("moveWordLeftAndModifySelection:") ||
            //            commandSelector == Selector("moveWordLeftAndModifySelection:") ||
            //            commandSelector == Selector("moveWordLeftAndModifySelection:") ||
            //            commandSelector == Selector("moveWordLeftAndModifySelection:") ||
            commandSelector == Selector("selectWord:") {
                return true
        }
        
        if commandSelector == Selector("deleteBackward:") ||
            commandSelector == Selector("deleteWordBackward:") {
                self.backspacePressed = true
                writingDelegate.focusedEditorSessionPointChanged(-1)
        }
        return false
    }
    
    override func controlTextDidChange(obj: NSNotification) {
        self.animate(parentView)
        backspacePressed = false
        writingDelegate.focusedEditorTextChangedTo(self.stringValue)
    }
    
}
