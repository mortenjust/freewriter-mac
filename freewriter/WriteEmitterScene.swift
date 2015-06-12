//
//  WriteEmitterScene.swift
//  freewriter
//
//  Created by Morten Just Petersen on 6/4/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SpriteKit



class WriteEmitterScene: SKScene {
    var emitter = SKEmitterNode()

    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.clearColor()
        var emitterPath = NSBundle.mainBundle().pathForResource("SimpleParticle", ofType: "sks")
        emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(emitterPath!) as! SKEmitterNode

        scaleMode = .AspectFill
        backgroundColor = SKColor.clearColor()
        
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        let maxX = CGRectGetMaxX(self.frame)
        emitter.position = CGPointMake(maxX-Colors().emitterPointFromMaxY, midY)

        self.addChild(emitter)
    }
    
    func repositionInView(view:NSView){
        let midX = CGRectGetMidX(self.frame)
        let midY = CGRectGetMidY(self.frame)
        let maxX = CGRectGetMaxX(self.frame)
        emitter.position = CGPointMake(maxX-Colors().emitterPointFromMaxY, midY)
    }
    
    
}
