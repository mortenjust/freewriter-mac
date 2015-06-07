//
//  MJanim.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/2/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

enum MJEasing {
    case linear, easeIn, easeOut, easeInOut
}

func runMJAnim(view:NSView, animation: POPAnimation, animationName:String){
    view.layer?.pop_addAnimation(animation, forKey: animationName)
}


class MJPOPBasic: POPBasicAnimation {
    init(view: NSView,
        propertyName : String? = nil,
        toValue _toValue : AnyObject? = nil,
        easing _easing : MJEasing? = nil,
        duration _duration : CFTimeInterval? = nil,
        delay _delay : CFTimeInterval? = nil,
        autoreverses _autoreverses : Bool? = nil,
        repeatCount _repeatCount : Int? = nil,
        repeatForever _repeatForever : Bool? = nil,
        runNow : Bool = true,
        animationName : String = "Animation"
        ) {
            super.init()
            if propertyName != nil {
                self.property = POPAnimatableProperty.propertyWithName(propertyName) as! POPAnimatableProperty
                }
            self.toValue = _toValue != nil ? _toValue! : self.toValue
            self.duration = _duration != nil ? _duration! : self.duration
            self.autoreverses = _autoreverses != nil ? _autoreverses! : self.autoreverses
            self.repeatCount = _autoreverses != nil ? _repeatCount! : self.repeatCount
            self.repeatForever = _repeatForever != nil ? _repeatForever! : self.repeatForever
            
            if _delay != nil {
                self.beginTime = CACurrentMediaTime() + _delay!
            }
            
            if _easing != nil {
                switch _easing! {
                case .easeIn:
                    self.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                case .easeInOut:
                    self.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                case .easeOut:
                    self.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                case .linear:
                    self.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                }
            }
            
            if runNow {
                runMJAnim(view, self, animationName)
            }
    }
}

class MJPOPSpring: POPSpringAnimation {
    init(view:NSView,
        propertyName : String? = nil,
        toValue _toValue : AnyObject? = nil,
            repeatForever _repeatForever:Bool? = nil,
            repeatCount _repeatCount: Int? = nil,
            springBounciness _springBounciness: CGFloat? = nil,
            springSpeed _springSpeed : CGFloat? = nil,
            dynamicsTension _dynamicsTension: CGFloat? = nil,
            dynamicsFriction _dynamicsFriction: CGFloat? = nil,
            dynamicsMass _dynamicsMass: CGFloat? = nil,
            animationName : String = "animation",
            runNow : Bool = true
        ) {
            super.init()
            
            if propertyName != nil {
                self.property = POPAnimatableProperty.propertyWithName(propertyName) as! POPAnimatableProperty
                }
            
            self.toValue = _toValue != nil ? _toValue! : self.toValue
            self.repeatCount = _repeatCount != nil ? _repeatCount! : self.repeatCount
            self.repeatForever = _repeatForever != nil ? _repeatForever! : self.repeatForever
            self.springBounciness = _springBounciness != nil ? _springBounciness! : self.springBounciness
            self.springSpeed = _springSpeed != nil ? _springSpeed! : self.springSpeed
            self.dynamicsTension = _dynamicsTension != nil ? _dynamicsTension! : self.dynamicsTension
            self.dynamicsFriction = _dynamicsFriction != nil ? _dynamicsFriction! : self.dynamicsFriction
            self.dynamicsMass = _dynamicsMass != nil ? _dynamicsMass! : self.dynamicsMass
            
            if !view.wantsLayer { view.wantsLayer = true }
            
            if runNow {
                runMJAnim(view, self, animationName)
                }
    }
}
