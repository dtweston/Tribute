//
//  ViewController.swift
//  Tribute
//
//  Created by Dave Weston on 3/10/15.
//  Copyright (c) 2015 Dave Weston. All rights reserved.
//

import UIKit
import Tribute
import cmark_bridge

class ViewController: UIViewController, UITextViewDelegate {
    var textView: UITextView!
    var textStorage: NSTextStorage!
    var layoutDelegate: NSLayoutManagerDelegate!
    
    override func viewDidLoad() {
        textStorage = NSTextStorage()
        layoutDelegate = MarkdownLayoutManagerDelegate()
        let layoutManager = MarkdownLayoutManager()
        layoutManager.delegate = layoutDelegate
        self.textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: view.bounds, textContainer: textContainer)
        textView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        textView.editable = false
        textView.delegate = self
        view.addSubview(textView)
        
        let parser = Parser()
        if let url = NSURL(string: "https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png?v5") {
            let emojiLookup = ["ok": GithubEmoji(name: "ok", url: url)]
            
            let githubPlainTextHandler = GithubPlainTextHandler(emojiLookup: emojiLookup)
            let renderer = AttributedStringRenderer(plainTextHandler: githubPlainTextHandler)
            if let url = NSBundle.mainBundle().URLForResource("AFNetworking-README", withExtension: "md") {
                if let data = NSData(contentsOfURL: url) {
                    if let str = String(data: data, encoding: NSUTF8StringEncoding) {
                        parser.parseMarkdown(str, renderer: renderer)
                    }
                }
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue()) { () -> Void in
                self.textView.attributedText = renderer.finalString
            }
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        NSLog("URL clicked: %@", URL)
        
        return false
    }
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        NSLog("text attachment clicked: %@", textAttachment)
        return false
    }
}
