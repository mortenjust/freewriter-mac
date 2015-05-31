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
    var secondsLeft: Double!
    var progressTimer : NSTimer!
    var stopWatchTimer : NSTimer!
    var savedText = String()
    var isReviewing = false
    let colors = Colors()
    var fontSize : CGFloat = 16
    @IBOutlet weak var timerContainer: NSView!
    @IBOutlet weak var editorContainer: NSView!
    
    
    @IBOutlet var mainView: NSVisualEffectView!
    
    
    @IBOutlet weak var stopWatchLabel: NSTextField!
    
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
    
    @IBAction func biggerText(sender:AnyObject){
        var font = NSFont(name: "Avenir Next", size: fontSize++)
        mainText.font = font
    
    }
    
    @IBAction func smallerText(sender:AnyObject){
        var font = NSFont(name: "Avenir Next", size: fontSize--)
        mainText.font = font
    }  
    
    @IBAction func resetDocument(sender:AnyObject){ // Menu item: Start Over
        println("resetDocument")
        savedText = ""
        mainText.string = ""
        startReviewMode()
        startNewSession(first: false)
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
            savedText = "\(savedText) \n- \(substring)"
            
            mainText.textStorage?.addAttribute(NSForegroundColorAttributeName, value: colors.selectedText, range: range)
            mainText.textStorage?.addAttribute(NSBackgroundColorAttributeName, value: colors.selectedBackground, range: range)
        }
    }
    
    func fadeView(view:NSView, toValue:CGFloat){
        var anim = POPBasicAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerOpacity) as! POPAnimatableProperty
        anim.toValue = toValue
        anim.duration = 0.5
        view.wantsLayer = true
        view.layer?.pop_addAnimation(anim, forKey: "opacity")
    }
    
    func startProgressBar(){
        
        // fade review message
        var fadeAnim = POPBasicAnimation.linearAnimation()
        fadeAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerOpacity) as! POPAnimatableProperty
        fadeAnim.fromValue = 1
        fadeAnim.toValue = 0.1
        fadeAnim.duration = 0.5
        reviewMessage.layer?.pop_addAnimation(fadeAnim, forKey: "opacity")
        
        
        var moveWatch = POPBasicAnimation.linearAnimation()
        moveWatch.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionX) as! POPAnimatableProperty
        moveWatch.fromValue = view.bounds.width - timerContainer.bounds.width
        moveWatch.toValue = 1
        moveWatch.duration = sessionLength
        timerContainer.wantsLayer = true
        timerContainer.layer?.pop_addAnimation(moveWatch, forKey: "movex")
    }
    
    func hideReviewMessage(){
        var anim = POPSpringAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        anim.toValue = -reviewMessage.bounds.height
        anim.completionBlock = {(en, to) -> Void in
            self.reviewMessage.hidden = true
        }
        reviewMessage.layer?.pop_addAnimation(anim, forKey: "move")
        
    }
    
    
    func showReviewMessage(){
        reviewMessage.hidden = false
        hideTimer()
        var anim = POPSpringAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        anim.toValue = 0
        reviewMessage.layer?.pop_addAnimation(anim, forKey: "position")
        reviewMessage.becomeFirstResponder()
        self.view.needsLayout = true
        fadeView(reviewMessage, toValue: 1)
        
        var moveAnim = POPBasicAnimation.easeInAnimation()
        moveAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        moveAnim.toValue = 0
        moveAnim.beginTime = CACurrentMediaTime() + 0.0
        self.innerMessage.layer?.pop_addAnimation(moveAnim, forKey: "positiony")
    }

    func updateStopWatch(){
        if secondsLeft == nil {
            secondsLeft = Double(sessionLength+1)
        }
        secondsLeft = secondsLeft - 1
        let seconds = Int(secondsLeft % 60)
        let minutes = Int((secondsLeft / 60) % 60)
        stopWatchLabel.stringValue = String(format: "%d:%02d", minutes, seconds)
        if secondsLeft < 1 {
        } else  {
           self.stopWatchTimer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateStopWatch", userInfo: nil, repeats: false)
            }
    }
    
    func startNewSession(first:Bool=false){
        zoomEditor(1, backgroundColor: colors.editorBackground)
        showTimer()
        hideReviewMessage()
        secondsLeft = sessionLength
        if stopWatchTimer != nil { stopWatchTimer.invalidate() }
        updateStopWatch()
        secondsLeft = nil
        println("startNewSession")
        if first {
            mainText.becomeFirstResponder()
        } else {
            progressTimer.invalidate()
        }
        isReviewing = false
        
        var normalAtts = [NSForegroundColorAttributeName : colors.textForeground, NSFontAttributeName : NSFont(name: "Avenir Next", size: fontSize)!]
        var savedAtts = [NSForegroundColorAttributeName : colors.savedTextForeground, NSFontAttributeName : NSFont(name: "Avenir Next", size: fontSize)!]
        var attrString = NSMutableAttributedString(string: "\(savedText)\n\n", attributes: savedAtts)
        mainText.textStorage?.setAttributedString(attrString)
        mainText.typingAttributes = normalAtts
        mainText.moveToEndOfDocument(nil)
        mainText.editable = true
        mainText.drawsBackground = true
        mainText.insertionPointColor = colors.insertionPoint

        startProgressBar()
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(sessionLength, target: self, selector: "startReviewMode", userInfo: nil, repeats: true)
    }
    
    func moveTimer(y:CGFloat){
        var timerAnim = POPSpringAnimation()
        timerAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        timerAnim.toValue = y
        timerContainer.wantsLayer = true
        timerContainer.layer?.pop_addAnimation(timerAnim, forKey: "pos")
    }
    
    func hideTimer(){
        moveTimer(-timerContainer.bounds.height)
    }
    
    func showTimer(){
        moveTimer(0)
    }

    func startReviewMode(){
        println("startReviewMode")
        progressTimer.invalidate()
        isReviewing = true
        mainText.selectable = true
        mainText.selectionGranularity = NSSelectionGranularity.SelectByWord
        mainText.editable = false
        
        reviewMessage.layer?.pop_removeAllAnimations()
        
        zoomEditor(1.02, backgroundColor: colors.reviewEditorBackground)
        showReviewMessage()
    }
    
    func zoomEditor(level : CGFloat, backgroundColor: NSColor){
        var anim = POPSpringAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerScaleXY) as! POPAnimatableProperty
        anim.toValue = NSValue(CGSize: CGSizeMake(level, level))
        anim.completionBlock = {(anim, block) -> Void in
            var backAnim = POPSpringAnimation()
            backAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerScaleXY) as! POPAnimatableProperty
            backAnim.toValue = NSValue(CGSize: CGSizeMake(1,1))
            self.mainText.layer?.pop_addAnimation(backAnim, forKey: "back")
        }
        editorContainer.wantsLayer = true
        mainText.wantsLayer = true
        mainText.drawsBackground = true
        mainText.layer?.pop_addAnimation(anim, forKey: "size")
        
        var colorAnim = POPSpringAnimation()
        colorAnim.property = POPAnimatableProperty.propertyWithName(kPOPLayerBackgroundColor) as! POPAnimatableProperty
        colorAnim.toValue = backgroundColor
        editorContainer.layer?.pop_addAnimation(colorAnim, forKey: "color")
        
    }
    
    func showInnerMessage(){
        
    }

    override func viewDidLoad() {
        self.view.wantsLayer = true
        reviewMessage.wantsLayer = true
        mainView.material = NSVisualEffectMaterial.Dark
        mainView.state = NSVisualEffectState.Active
        mainView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        hideTimer()
        
     //   reviewMessage.layer?.backgroundColor = colors.reviewMessageBackground.CGColor
        editorContainer.layer?.backgroundColor = colors.editorBackground.CGColor
        
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
        
        mainText.selectedTextAttributes = [ NSForegroundColorAttributeName : colors.selectedText
                                          , NSBackgroundColorAttributeName : colors.selectedBackground ]
    }

    override func viewDidLayout() {
        println("layout")
        positionReviewMessageInView()
        positionEditorInView()
        timerContainer.frame.origin = CGPointMake(0, 0)
        editorContainer.frame = view.bounds

    }
    
    func positionReviewMessageInView(){
            reviewMessage.frame.origin.y = 0
            reviewMessage.frame.size.width = self.view.bounds.width
            println(reviewMessage.frame.size.width)
            let midPoint = reviewMessage.bounds.width/2
            innerMessage.frame.origin.x = midPoint-(innerMessage.bounds.width/2) // center=center, the nsway, omg
    }
    
    func positionEditorInView(){
        let midPoint = self.view.bounds.width/2
        editorScrollView.frame.origin.x = midPoint - (editorScrollView.bounds.width/2)
        editorScrollView.frame.origin.y = 0 + reviewMessage.bounds.height
        editorScrollView.frame.size.height = self.view.bounds.height-25-reviewMessage.bounds.height //
        mainText.frame.size.width = editorScrollView.bounds.width-10
    }
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

