//
//  ViewController.swift
//  freewriter
//
//  Created by Morten Just Petersen on 5/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate, NSAnimationDelegate, FocusedEditorWritingDelegate, FWStashEditorDelegate {
    @IBOutlet weak var reviewMessage: NSView!
    @IBOutlet weak var innerMessage: NSView!
    @IBOutlet weak var mainScrollView: NSScrollView!
    @IBOutlet weak var focusedEditor: FocusedEditor!
    
    @IBOutlet weak var reviewDoneButton: NSButton!
    
    @IBOutlet weak var blankSlateContainer: NSView!
    
    @IBOutlet var mainText: NSTextView!
    let sessionLength:Double = 5 * 60
    var secondsLeft: Double!
    var scene:WriteEmitterScene!
    var progressTimer : NSTimer!
    var stopTypingTimer : NSTimer!
    var didPressBackspace = false
    var stopWatchTimer : NSTimer!
    var savedText = String()
    var lastKeystroke : Double!
    var document : Document!

   
    @IBOutlet weak var focusScoreField: NSTextField!
    
    enum MJEditMode { case Normal, Focused }
    var editMode = MJEditMode.Normal
    var isReviewing = false
    let colors = Colors()
    var sessionSpeedPoints : Double = 0
    
    @IBOutlet weak var timerView: FWTimerView!
    @IBOutlet weak var editorContainer: NSView!
    @IBOutlet var mainView: NSVisualEffectView!
    
    @IBOutlet var stashEditor: FWStashEditor!    
    @IBOutlet weak var stashContainer: NSView!
    
    @IBOutlet weak var stopWatchLabel: NSTextField!
    @IBOutlet weak var editorScrollView: NSScrollView!
    
    @IBOutlet var  splitView: FWSplitView!
    

    @IBAction func freeWriteSelected(sender:NSMenuItem){
        startNewSession(first: false)
    }
    
    
    
    
    @IBAction override func selectAll(sender: AnyObject?) {
        println("Select all")
    }
    
    @IBAction func reviseSelected(sender:NSMenuItem){ // manual override
        startReviewMode()
    }
    
    @IBAction func biggerText(sender:AnyObject){
        if editMode == .Normal {
            let newSize = mainText.font!.pointSize + CGFloat(2)
            mainText.font = NSFont(name: colors.mainFont, size: newSize)
        } else {
            focusedEditor.biggerFont()
        }
    }
    
    @IBAction func smallerText(sender:AnyObject){
        if editMode == .Normal {
            let newSize = mainText.font!.pointSize - CGFloat(2)
            mainText.font = NSFont(name: colors.mainFont, size: newSize)
        } else {
            focusedEditor.smallerFont()
        }
    }
    
    func focusedEditorUserTypedReallyFast() {
        changeSessionPoints(1.4)
    }
    
    func focusedEditorUserLostFocus() {
        changeSessionPoints(-5.0)
    }
    
    func focusedEditorSessionPointChanged(byPoints: Double) {
        changeSessionPoints(byPoints)
    }
    
    func focusedEditorTextChangedTo(newString: String) {

    }
    
    func changeSessionPoints(points: Double){
        sessionSpeedPoints += points
        if sessionSpeedPoints < 1 { sessionSpeedPoints = 1 }
    }

    func startFocusEditing(){
        editMode = .Focused
        mainText.hidden = true
        focusedEditor.setup()
        focusedEditor.parentView = view
        focusedEditor.writingDelegate = self
        focusedEditor.hidden = false
//        focusedEditor.positionInView(view)
        focusedEditor.animate(view)
        focusedEditor.becomeFirstResponder()
        focusedEditor.selectText(view)
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
        savedText = stashEditor.string!
        focusedEditor.stringValue = "Let's go again!"
        mainText.string = " "
        startNewSession()
    }
    
    func textView(textView: NSTextView, shouldChangeTextInRange affectedCharRange: NSRange, replacementString: String) -> Bool {
        // This was the best way I could find to bind the document to the form field in a storyboards-based app. Weird, right?
        document.docContents = mainText.string
        return true
    }

    func hideBlankSlateMessage(){
        MJPOPBasic(view: blankSlateContainer, propertyName: kPOPLayerOpacity, toValue: 0, easing: MJEasing.easeInOut, duration: 0.3, delay: 0)
    }
    
    func stashEditorDidChange() {
        hideBlankSlateMessage()
    }
    
    func textViewDidChangeSelection(notification: NSNotification) {
        if !isReviewing { return }
        let range = mainText.selectedRange()
        if range.length != 0 {
            hideBlankSlateMessage()
            let string = mainText.string!
            let substring = NSString(string: string).substringWithRange(range)
            println(substring)
            
            savedText = "\(stashEditor.string!)"
            savedText = "\(savedText) \n• \(substring)"
            
            stashEditor.string = savedText
            stashEditor.moveToEndOfDocument(nil)

            
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
        
        timerView.start(sessionLength, view:self.view)
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
    
    
    func showReviewMessage(sessionScore:Int){
        focusScoreField.stringValue = "\(sessionScore)%"
        reviewMessage.hidden = false
        timerView.hide()
        var anim = POPSpringAnimation()
        anim.property = POPAnimatableProperty.propertyWithName(kPOPLayerPositionY) as! POPAnimatableProperty
        anim.toValue = 0
        anim.removedOnCompletion = true
        reviewMessage.layer?.pop_addAnimation(anim, forKey: "position")
        reviewMessage.becomeFirstResponder()
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
        var attrString = NSMutableAttributedString(string: "\(savedText)", attributes: colors.savedAtts)
        mainText.textStorage?.setAttributedString(attrString)
        mainText.typingAttributes = colors.normalAtts
        mainText.editable = true
        mainText.drawsBackground = true
        mainText.insertionPointColor = colors.insertionPoint
    }
    
    func startNewSession(first:Bool=false){
        if let s = splitView {
        s.hidden = true
        }
        timerView.show()
        hideReviewMessage()
        secondsLeft = sessionLength
        if stopWatchTimer != nil { stopWatchTimer.invalidate() }
        updateStopWatch()
        secondsLeft = nil
        startProgressBar()
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(sessionLength, target: self, selector: "startReviewMode", userInfo: nil, repeats: true)

        if self.editMode == MJEditMode.Normal {
            startNormalSession(first: first)
        } else {
            startFocusEditing()
        }
    }
    


    func startReviewMode(){
        println("startReviewMode")
        var attrString = NSMutableAttributedString(string: "\(savedText)", attributes: colors.stashEditorAtts)
        stashEditor.textStorage?.setAttributedString(attrString)
        println("speedpoints \(sessionSpeedPoints) vs length \(count(focusedEditor.stringValue))")
        
        // score
        var sessionScore:Int = 0
        if count(focusedEditor.stringValue) > 1 {
            sessionScore = Int(round(Double(sessionSpeedPoints) / Double(count(focusedEditor.stringValue)) * 100))
        } else {
            sessionScore = 1
        }
        println("session score is \(sessionScore)")
        sessionSpeedPoints = 0

        stashContainer.wantsLayer = true
        stashContainer.alphaValue = 0
        stashContainer.layer?.backgroundColor = colors.stashEditorBackground.CGColor

        
        var shadow = NSShadow()
        shadow.shadowOffset = NSSize(width: 10, height: 10)
        shadow.shadowBlurRadius = 3
        shadow.shadowColor = NSColor.blackColor()
        
        stashContainer.shadow = shadow
        
//        MJPOPSpring(view: stashContainer, propertyName: kPOPLayerOpacity, toValue: 1, dynamicsTension: 2.1, dynamicsFriction: 4.9, dynamicsMass: 0.01)
        
        MJPOPBasic(view: stashContainer, propertyName: kPOPLayerOpacity, toValue: 1, easing: MJEasing.easeOut, duration: 0.3, delay: 0)
        
        
        // user interface
        mainText.textContainerInset = NSSize(width: 20, height: 20)
        stashEditor.textContainerInset = NSSize(width: 20, height: 20)

        let centeredY = stashContainer.bounds.height/2 - blankSlateContainer.bounds.height/2
        var animBlankSlate = MJPOPBasic(view: blankSlateContainer, propertyName: kPOPLayerPositionY, toValue: centeredY, easing: MJEasing.easeOut, duration: 0.4, delay: 0, runNow: false, animationName: "upup")
        animBlankSlate.fromValue = centeredY-20
        animBlankSlate.removedOnCompletion = true
        runMJAnim(blankSlateContainer, animBlankSlate, "upup")
        
        blankSlateContainer.alphaValue = 0.4
        
        
        mainText.typingAttributes = colors.sessionReviewAtts
        if editMode == .Focused {
            focusedEditor.hidden = true
            mainText.hidden = false
            mainText.string! += "\n\(focusedEditor.stringValue)\n"
        }
        
        splitView.hidden = false
        
//        splitView.positionInParentView()
//        stashEditor.positionInParentView()


        mainText.selectedRanges = [NSMakeRange(0, 0)]
        mainText.selectable = true
        mainText.selectionGranularity = NSSelectionGranularity.SelectByWord
        mainText.editable = false
        
        progressTimer.invalidate()
        isReviewing = true
        reviewMessage.layer?.pop_removeAllAnimations()
        zoomEditor(1.02, backgroundColor: colors.reviewEditorBackground)
        
        mainText.moveToEndOfDocument(nil)
        stashEditor.moveToEndOfDocument(nil)

        showReviewMessage(sessionScore)
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
        println("View vwill appear")
        let win = self.view.window
        let winc = win?.windowController() as! NSWindowController
        document = winc.document as! Document
        
        println("dumping doccontents")
        println(document.docContents?.length)
        
        if let docContents = document.docContents {
            if docContents.length > 0 {
                savedText = document.docContents! as String
                self.startReviewMode()
                }
        }
    }

    override func viewDidLoad() {

        self.view.wantsLayer = true
        self.focusedEditor.wantsLayer = true
        reviewMessage.wantsLayer = true
        stashEditor.stashEditorDelegate = self
        splitView.parentView = self.view
        mainScrollView.scrollerStyle = NSScrollerStyle.Overlay
        mainScrollView.scrollerKnobStyle = NSScrollerKnobStyle.Light
        mainView.material = NSVisualEffectMaterial.Dark
        mainView.state = NSVisualEffectState.Active
        mainView.blendingMode = NSVisualEffectBlendingMode.BehindWindow
        timerView.hide()
        editorContainer.layer?.backgroundColor = colors.editorBackground.CGColor
        
        reviewDoneButton.layer?.backgroundColor = NSColor.clearColor().CGColor
        reviewDoneButton.font = NSFont(name: colors.mainFont, size: 14)
        
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
        if !isReviewing {
            timerView.frame.origin = CGPointMake(0, 0)
            }
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

