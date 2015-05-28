//
//  ViewController.swift
//  freewriter
//
//  Created by Morten Just Petersen on 5/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSAnimationDelegate {
    @IBOutlet weak var reviewMessage: NSView!
    @IBOutlet weak var innerMessage: NSView!
    @IBOutlet var mainText: NSTextView!
    let sessionLength:Double = 5 * 60
    var progressTimer : NSTimer!
    var savedText = String()
    var isReviewing = false
    
    @IBOutlet weak var editorScrollView: NSScrollView!
    
    @IBAction func freeWriteSelected(sender:NSMenuItem){
        println("was fw just pressed?")
        startNewSession(first: false)
    }
    
    @IBAction func reviseSelected(sender:NSMenuItem){
        println("was revise")
        startReviewMode()
    }
    
    @IBAction func saveDocument(sender:AnyObject){
        println("save document, aight")
    }
    
    @IBAction func doneReviewPressed(sender: NSButton) {
        println("done pressed")
        startNewSession()
    }
    
    func textViewDidChangeSelection(notification: NSNotification) {
        if !isReviewing { return }
        let range = mainText.selectedRange()
        if range.length != 0 {
            let string = mainText.string!
            let substring = NSString(string: string).substringWithRange(range)
            println(substring)
//            mainText.textStorage?.applyFontTraits(NSFontTraitMask.BoldFontMask, range: range)
            mainText.setTextColor(NSColor.whiteColor(), range: range)
            mainText.setSelectedRange(NSMakeRange(0, 0))
            savedText = "\(savedText) \(substring)"
        }
    }
    
    func fadeView(view:NSView, toValue:CGFloat){
        println("fadeView")
        
        var anim = POPBasicAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerOpacity) as! POPAnimatableProperty
        anim.toValue = toValue
        anim.duration = 0.5
        view.wantsLayer = true
        view.layer?.pop_addAnimation(anim, forKey: "opacity")
    }
    
    func startProgressBar(){
        println("startProgressbar")
        
        var moveAnim = POPBasicAnimation()
        moveAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        moveAnim.toValue = -innerMessage.bounds.height
        innerMessage.layer?.pop_addAnimation(moveAnim, forKey: "positiony")
        
        fadeView(reviewMessage, toValue: 0.2)
        
        var anim = POPBasicAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerScaleX) as! POPAnimatableProperty
        anim.toValue = 0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        anim.duration = self.sessionLength
        reviewMessage.layer?.pop_addAnimation(anim, forKey: "scaleX")
    }
    
    func startNewSession(first:Bool=false){
        println("startNewSession")
        if first {
            mainText.becomeFirstResponder()
        } else {
            progressTimer.invalidate()
        }
        isReviewing = false
        var normalAtts = [NSForegroundColorAttributeName : NSColor(calibratedRed:0.608, green:0.646, blue:0.696, alpha:1), NSFontAttributeName : NSFont(name: "Helvetica", size: 18)!]
        var savedAtts = [NSForegroundColorAttributeName : NSColor(calibratedRed:0.608, green:0.646, blue:0.696, alpha:0.5), NSFontAttributeName : NSFont(name: "Helvetica", size: 18)!]
        var attrString = NSMutableAttributedString(string: savedText, attributes: savedAtts)
        mainText.textStorage?.setAttributedString(attrString)
        mainText.typingAttributes = normalAtts
        mainText.moveToEndOfDocument(nil)
        mainText.editable = true
        mainText.drawsBackground = true
        mainText.insertionPointColor = NSColor(deviceRed:1, green:0.933, blue:0.820, alpha:1)
        var countdownAnimation = POPBasicAnimation()
        
        startProgressBar()
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(sessionLength, target: self, selector: "startReviewMode", userInfo: nil, repeats: true)
    }

    func startReviewMode(){
        println("startReviewMode")
        reviewMessage.layer?.pop_removeAllAnimations()
        showReviewMessage()
        progressTimer.invalidate()
        isReviewing = true
        mainText.selectable = true
        mainText.selectionGranularity = NSSelectionGranularity.SelectByWord
        mainText.editable = false
    }
    
    func showReviewMessage(){
        println("showReviewMessage")
        reviewMessage.wantsLayer = true
        var anim = POPSpringAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerScaleX) as! POPAnimatableProperty
        anim.toValue = 1
        anim.dynamicsFriction = 100
        anim.springBounciness = 0
        anim.springSpeed = 0
        anim.completionBlock = { (anim, done) -> Void in
        }
        reviewMessage.layer?.pop_addAnimation(anim, forKey: "position")
        reviewMessage.becomeFirstResponder()
        self.view.needsLayout = true
        fadeView(reviewMessage, toValue: 100)
        
        var moveAnim = POPBasicAnimation.easeInAnimation()
        moveAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        moveAnim.toValue = 0
        moveAnim.beginTime = CACurrentMediaTime() + 0.0
        self.innerMessage.layer?.pop_addAnimation(moveAnim, forKey: "positiony")

        var mamin = POPBasicAnimation.easeInAnimation()
        
    }
    
    func showInnerMessage(){

    }

    override func viewDidLoad() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(deviceHue:0.609, saturation:0.812, brightness:0.251, alpha:1).CGColor
        reviewMessage.wantsLayer = true
        reviewMessage.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        for windowItem in NSApplication.sharedApplication().windows {
            let window = windowItem as! NSWindow
            window.movableByWindowBackground = true
            window.titleVisibility = NSWindowTitleVisibility.Hidden
            window.titlebarAppearsTransparent = true;
            window.styleMask |= NSFullSizeContentViewWindowMask;
            window.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
        }
        super.viewDidLoad()
        mainText.delegate = self
        startNewSession(first:true)
    }

    override func viewDidLayout() {
        positionReviewMessageInView()
        positionEditorInView()
    }

    
    func positionReviewMessageInView(){
            reviewMessage.frame.origin.y = 0
            reviewMessage.frame.size.width = self.view.bounds.width
            let midPoint = reviewMessage.bounds.width/2
            innerMessage.frame.origin.x = midPoint-(innerMessage.bounds.width/2) // center=center, the nsway, omg
    }
    
    func positionEditorInView(){
        let midPoint = self.view.bounds.width/2
        editorScrollView.frame.origin.x = midPoint - (editorScrollView.bounds.width/2)
        editorScrollView.frame.origin.y = 0 + reviewMessage.bounds.height
        editorScrollView.frame.size.height = self.view.bounds.height-20-reviewMessage.bounds.height //
        mainText.frame.size.width = editorScrollView.bounds.width-10
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

