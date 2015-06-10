//
//  ViewController.swift
//  freewriter
//
//  Created by Morten Just Petersen on 5/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SpriteKit
import SceneKit

class ViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate, NSAnimationDelegate {
    @IBOutlet weak var reviewMessage: NSView!
    @IBOutlet weak var innerMessage: NSView!
    
    @IBOutlet weak var mainScrollView: NSScrollView!
    
    @IBOutlet weak var focusedEditor: FocusedEditor!

    
    @IBOutlet var mainText: NSTextView!
    let sessionLength:Double = 5 * 60
    var secondsLeft: Double!
    var scene:WriteEmitterScene!
    var progressTimer : NSTimer!
    var stopTypingTimer : NSTimer!
    var stopWatchTimer : NSTimer!
    var savedText = String()
    var skView : SKView!
    var lastKeystroke : Double!
    var document : Document!
    var docContents : NSAttributedString = NSAttributedString() {
        didSet {
            println("did set, updating document")
            document.docContents = docContents
        }
    }
    
    var normalAtts: [String : NSObject]!
    var savedAtts: [String : NSObject]!
    
    enum MJEditMode { case Normal, Focused }
    var editMode = MJEditMode.Normal
    var isReviewing = false
    let colors = Colors()
    var fontSize : CGFloat = 18
    var focusedFontSize : CGFloat = 24
    var sceneView: SCNView!
    
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
    
    @IBAction func biggerText(sender:AnyObject){
        // TODO: Check for mode here, focused or not?
        
        if editMode == .Normal {
            let newSize = mainText.font!.pointSize + CGFloat(2)
            mainText.font = NSFont(name: "Avenir Next", size: newSize)
        } else {
            focusedEditor.biggerFont()
        }
    }
    
    @IBAction func smallerText(sender:AnyObject){
        if editMode == .Normal {
            let newSize = mainText.font!.pointSize - CGFloat(2)
            mainText.font = NSFont(name: "Avenir Next", size: newSize)
        } else {
            focusedEditor.smallerFont()
        }
        
    }

    override func controlTextDidChange(obj: NSNotification) {
        self.focusedEditor.wantsLayer = true
        
        var isAsLongAsWindow = false
        if (focusedEditor.sizeOfString().width > view.bounds.width) {
            isAsLongAsWindow = true
        }
        
        if isAsLongAsWindow {
            if let lastKey = lastKeystroke {
                let speed = lastKey - NSDate.timeIntervalSinceReferenceDate()
                lastKeystroke = NSDate.timeIntervalSinceReferenceDate()
                self.showParticles(speed)
            } else {
                lastKeystroke = Double(NSDate.timeIntervalSinceReferenceDate())
            }
        }

        let jumpTo = CGRectGetMidY(view.bounds) - (focusedEditor.bounds.height/2)
//        var animUp = MJPOPBasic(view: focusedEditor, propertyName: kPOPLayerPositionY, toValue: jumpTo, easing: MJEasing.easeOut, duration: 0.1, delay: 0, runNow: false, animationName: "positionOut")
        
//        var animUp = MJPOPSpring(view: focusedEditor, propertyName: kPOPLayerPositionY, toValue: jumpTo, springBounciness: 0.01, springSpeed: 13.8, dynamicsTension: 16.3, dynamicsFriction: 1.6, dynamicsMass: 0.15, animationName: "jumpUpWhenWriting", runNow: true)

        var animUp = MJPOPSpring(view: focusedEditor, propertyName: kPOPLayerPositionY, toValue: jumpTo, springBounciness: 0.01, springSpeed: 13.8, dynamicsTension: 71.6, dynamicsFriction: 8.7, dynamicsMass: 2.4, animationName: "jumpUpWhenWriting", runNow: true)

        
        if let stt = self.stopTypingTimer {
            self.stopTypingTimer.invalidate()
            }
        
        animUp.completionBlock = {(one, two) -> Void in // start the decay
            
           self.stopTypingTimer =  NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "hideParticles", userInfo: nil, repeats: false)
 
            MJPOPSpring(view: self.focusedEditor, propertyName: kPOPLayerPositionY, toValue: 20, delay:0.3, repeatForever: false, springBounciness: 0.01, springSpeed: 13.8, dynamicsTension: 19.9, dynamicsFriction: 20, dynamicsMass: 16.6, animationName: "animateTextDown", runNow: true)
            MJPOPBasic(view: self.focusedEditor, propertyName: kPOPLayerOpacity, toValue: 0.16, easing: MJEasing.easeInOut, duration: 1, delay: 0.3)
        }
        
        runMJAnim(focusedEditor, animUp, "up")
        MJPOPBasic(view: focusedEditor, propertyName: kPOPLayerOpacity, toValue: 1, easing: MJEasing.easeOut, duration: 0.2, delay: 0)
    }
    
    func startParticles(){
        skView = SKView(frame: self.view.bounds)
        skView.wantsLayer = true
        skView.allowsTransparency = true
        scene = WriteEmitterScene(size: self.view.bounds.size)
        skView.presentScene(scene)
        view.addSubview(skView, positioned: NSWindowOrderingMode.Above, relativeTo: focusedEditor)
    }
    
    func hideParticles(){
        scene.emitter.particleBirthRate = 0
    }
    
    func positionParticles(){
        skView.frame = self.view.bounds
    }
    
    func showParticles(speed : Double){
        let birthRate = abs(log(abs(speed)) * 100) /// secret formula for success
        scene.emitter.particleBirthRate = CGFloat(birthRate)
    }
    
    func startFocusEditing(){
        startParticles()
        hideParticles()
        editMode = .Focused
        mainText.hidden = true
        focusedEditor.setup()
        focusedEditor.positionInView(view)
        focusedEditor.hidden = false
        focusedEditor.delegate = self
        focusedEditor.becomeFirstResponder()
        editorContainer.layer?.backgroundColor = colors.editorBackground.CGColor
    }
    
    func startNormalEditing(){
        editMode = .Normal
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
        focusedEditor.stringValue = " "
        startNewSession()
    }
    
    func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String) -> Bool {
        // This was the best way I could find to bind the document to the form field in a storyboards-based app. Weird, right?
        document.docContents = mainText.attributedString()
        return true
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


    
    func startNormalSession(first:Bool=false){
        zoomEditor(1, backgroundColor: colors.editorBackground)
        if first {
            mainText.becomeFirstResponder()
        } else {
            progressTimer.invalidate()
        }
        isReviewing = false
        
        mainText.hidden = false
        var attrString = NSMutableAttributedString(string: "\(savedText)\n\n", attributes: savedAtts)
        mainText.textStorage?.setAttributedString(attrString)
        mainText.typingAttributes = normalAtts
        mainText.moveToEndOfDocument(nil)
        mainText.editable = true
        mainText.drawsBackground = true
        mainText.insertionPointColor = colors.insertionPoint
    }
    
    func startNewSession(first:Bool=false){
        showTimer()
        hideReviewMessage()
        secondsLeft = sessionLength
        if stopWatchTimer != nil { stopWatchTimer.invalidate() }
        updateStopWatch()
        secondsLeft = nil
        println("startNewSession")
        startProgressBar()
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(sessionLength, target: self, selector: "startReviewMode", userInfo: nil, repeats: true)

        if self.editMode == MJEditMode.Normal {
            startNormalSession(first: first)
        } else {
            startFocusEditing()
        }
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
        
        var attrString = NSMutableAttributedString(string: "\(savedText)\n\n", attributes: savedAtts)
        mainText.textStorage?.setAttributedString(attrString)
        
        if editMode == .Focused {
            focusedEditor.hidden = true
            mainText.hidden = false
            skView.hidden = true
            mainText.string! += "\n\(focusedEditor.stringValue)\n"
        }
        
        mainText.selectedRanges = [NSMakeRange(0, 0)]
        
        mainText.selectable = true
        mainText.selectionGranularity = NSSelectionGranularity.SelectByWord
        mainText.editable = false
        
        progressTimer.invalidate()
        isReviewing = true
        reviewMessage.layer?.pop_removeAllAnimations()
        zoomEditor(1.02, backgroundColor: colors.reviewEditorBackground)
        
        mainText.moveToEndOfDocument(nil)

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
    
    override func viewWillAppear() {
        let win = self.view.window
        let winc = win?.windowController() as! NSWindowController
        document = winc.document as! Document

    }

    override func viewDidLoad() {
        normalAtts = [NSForegroundColorAttributeName : colors.textForeground, NSFontAttributeName : NSFont(name: "Avenir Next", size: fontSize)!]
        savedAtts = [NSForegroundColorAttributeName : colors.savedTextForeground, NSFontAttributeName : NSFont(name: "Avenir Next", size: fontSize)!]
        
        
        self.view.wantsLayer = true
        reviewMessage.wantsLayer = true
        mainScrollView.scrollerStyle = NSScrollerStyle.Overlay
        mainScrollView.scrollerKnobStyle = NSScrollerKnobStyle.Light
        
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
        
        self.editMode = .Focused
        
        mainText.hidden = true
        startNewSession(first:true)
        
        mainText.selectedTextAttributes = [ NSForegroundColorAttributeName : colors.selectedText
                                          , NSBackgroundColorAttributeName : colors.selectedBackground ]
     
    }

    override func viewDidLayout() {
        focusedEditor.positionInView(view)
        positionParticles()

        println("layout")
        positionReviewMessageInView()
        positionEditorInView()
        timerContainer.frame.origin = CGPointMake(0, 0)
        editorContainer.frame = view.bounds
        scene.repositionInView(self.view)

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
    
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

