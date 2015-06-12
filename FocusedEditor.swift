//
//  FocusedEditor.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/4/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class FocusedEditor: NSTextField {
    
    var backspacePressed = true
    
    func setup(){
        self.backgroundColor = NSColor.clearColor()
        self.bordered = false
        self.alignment = NSTextAlignment.LeftTextAlignment
    }
    
    func biggerFont(){
        let newSize = self.font!.pointSize + CGFloat(2)
        self.font = NSFont(name: Colors().mainFont, size: newSize)
        positionInView(self.superview!)
    }
    
    func smallerFont(){
        let newSize = self.font!.pointSize - CGFloat(2)
        self.font = NSFont(name: Colors().mainFont, size: newSize)
        positionInView(self.superview!)
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
        println("pos in v. Own height is \(heightOfString())")
        self.frame.size.width = view.bounds.width-Colors().emitterPointFromMaxY
        self.frame.size.height = heightOfString()
        self.frame.origin.y = CGRectGetMidY(view.bounds) - (heightOfString()/2)
    }
    
    override func insertBacktab(sender: AnyObject?) {
        return
    }
    
    override func insertLineBreak(sender: AnyObject?) {
        return
    }
    
    override func insertNewline(sender: AnyObject?) {
        return
    }
    
    override func insertNewlineIgnoringFieldEditor(sender: AnyObject?) {
        return
    }
    
    override func insertTab(sender: AnyObject?) {
        return
    }
    
    override func insertTabIgnoringFieldEditor(sender: AnyObject?) {
        return
    }
    
    override func moveBackward(sender: AnyObject?) {
        return
    }
    
    override func moveDown(sender: AnyObject?) {
        return
    }
    
    override func moveLeft(sender: AnyObject?) {
        return
    }
    
    override func moveLeftAndModifySelection(sender: AnyObject?) {
        return
    }
    
    override func moveToBeginningOfLine(sender: AnyObject?) {
        return
    }
    
    
    
    override func deleteBackward(sender: AnyObject?) {
        super.deleteBackward(sender)
        backspacePressed = true
        println("backspace, setting flag")
        return
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
}
