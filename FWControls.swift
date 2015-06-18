//
//  FWControls.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/17/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class FWControls: NSView {

    @IBOutlet var biggerTextButton : NSButton!
    var appearTimer : NSTimer!
    var firstTime = true
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    override func mouseDown(theEvent: NSEvent) {
        appear()
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        appear()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        appearThenDisappear()
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        appear()
    }
    

    
    func appearThenDisappear(){
        self.wantsLayer = true
        
        if appearTimer == nil {
            println("appear then disappear")
            appear()
            appearTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "disappear", userInfo: nil, repeats: false)
            }
        self.needsLayout = true
    }
    
    func appear(){
        println("a \(self.alphaValue)")
        self.layer?.opacity = 0.2
        println("b \(self.alphaValue)")
        println("appear was called, but had no effect, which was weard  ")
       // MJPOPBasic(view: self, propertyName: kPOPLayerOpacity, toValue: 1, easing: MJEasing.easeOut, duration: 0.2, runNow: false)
    }
    
    
    func disappear(){
        appearTimer = nil
        firstTime = false
        MJPOPBasic(view: self, propertyName: kPOPLayerOpacity, toValue: 0.2, easing: MJEasing.easeOut, duration: 0.5)    }
}
