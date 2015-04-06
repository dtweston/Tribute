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

class ViewController: UIViewController {
    var textView: UITextView!
    var textStorage: NSTextStorage!
    var layoutDelegate: NSLayoutManagerDelegate!
    
    override func viewDidLoad() {
        self.textStorage = NSTextStorage()
        self.layoutDelegate = MarkdownLayoutManagerDelegate()
        let layoutManager = MarkdownLayoutManager()
        layoutManager.delegate = self.layoutDelegate
        self.textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)
        
        self.textView = UITextView(frame: self.view.bounds, textContainer: textContainer)
        self.textView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.textView.editable = false
        self.view.addSubview(self.textView)
        
        var parser = Parser()
        let emojiLookup = ["ok": GithubEmoji(name: "ok", url: NSURL(string: "https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png?v5")!)]
        var githubPlainTextHandler = GithubPlainTextHandler(emojiLookup: emojiLookup)
        var renderer = AttributedStringRenderer(plainTextHandler: githubPlainTextHandler)
        if let url = NSBundle.mainBundle().URLForResource("AFNetworking-README", withExtension: "md") {
            let data = NSData(contentsOfURL: url)
            if let str = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil) {
                parser.parseMarkdown(str, renderer: renderer)
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue()) { () -> Void in
            self.textView.attributedText = renderer.finalString
        }
    }
}
