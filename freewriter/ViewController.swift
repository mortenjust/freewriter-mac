//
//  ViewController.swift
//  freewriter
//
//  Created by Morten Just Petersen on 5/22/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {
    @IBOutlet weak var reviewMessage: NSView!
    @IBOutlet var mainText: NSTextView!
    @IBOutlet weak var progress: NSProgressIndicator!
    let sessionLength = 5
    var progressTimer : NSTimer!
    var savedText = ""
    
    
    @IBAction func doneReviewPressed(sender: NSButton) {
        println("done pressed")
        startNewSession()
    }
    
    
    func textViewDidChangeSelection(notification: NSNotification) {
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
    
    func startNewSession(first:Bool=false){
        if first {
            mainText.becomeFirstResponder()
        } else {
            progressTimer.invalidate()
        }
        
        var normalAtts = [NSForegroundColorAttributeName : NSColor(calibratedRed:0.608, green:0.646, blue:0.696, alpha:1), NSFontAttributeName : NSFont(name: "Helvetica", size: 18)!]

        var savedAtts = [NSForegroundColorAttributeName : NSColor(calibratedRed:0.608, green:0.646, blue:0.696, alpha:0.5), NSFontAttributeName : NSFont(name: "Helvetica", size: 18)!]
        
        var attrString = NSMutableAttributedString(string: savedText, attributes: savedAtts)

        mainText.textStorage?.setAttributedString(attrString)
        mainText.typingAttributes = normalAtts
        
        
        mainText.moveToEndOfDocument(nil)
        
        mainText.editable = true
        mainText.drawsBackground = true
        mainText.insertionPointColor = NSColor(deviceRed:1, green:0.933, blue:0.820, alpha:1)
        progress.doubleValue = 100
        reviewMessage.hidden = true
        
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "decreaseBar", userInfo: nil, repeats: true)
    }
    
    func decreaseBar(){
        progress.incrementBy(-5.0)
        if progress.doubleValue < 0.1 {
            startReviewMode()
        }
    }
    
    func startReviewMode(){
        reviewMessage.hidden = false
        
        mainText.selectable = true
        mainText.selectionGranularity = NSSelectionGranularity.SelectByWord
        mainText.editable = false
        mainText.drawsBackground = false
    }

    override func viewDidLoad() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(deviceHue:0.609, saturation:0.812, brightness:0.251, alpha:1).CGColor
        reviewMessage.wantsLayer = true
        reviewMessage.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        
        let window = NSApplication.sharedApplication().windows.first as! NSWindow
        window.movableByWindowBackground = true
        window.titleVisibility = NSWindowTitleVisibility.Hidden
        window.titlebarAppearsTransparent = true;
        window.styleMask |= NSFullSizeContentViewWindowMask;
        window.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
        
        
        super.viewDidLoad()
        mainText.delegate = self
        startNewSession(first:true)

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

