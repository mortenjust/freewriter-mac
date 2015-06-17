//
//  FWTimerView.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class FWTimerView: NSView {
    
    func setup(){
        self.wantsLayer = true
    }
    
    func start(sessionLength:Double, view:NSView){
        self.hidden = false
//        var moveWatch = POPBasicAnimation.linearAnimation()
//        moveWatch.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionX) as! POPAnimatableProperty
//        moveWatch.fromValue = view.bounds.width - self.bounds.width
//        moveWatch.toValue = 1
//        moveWatch.duration = sessionLength
//        self.layer?.pop_addAnimation(moveWatch, forKey: "movex")
    }
    
    func move(y:CGFloat){
        var timerAnim = POPSpringAnimation()
        timerAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        timerAnim.toValue = y
        self.wantsLayer = true
        timerAnim.completionBlock = { (anim, done) -> Void in
            if y != 0 { self.hidden = true }
        }
        self.layer?.pop_addAnimation(timerAnim, forKey: "pos")
    }
    
    func hide(){
        move(-self.bounds.height)
        
    }
    
    func show(){
        move(0)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
}
