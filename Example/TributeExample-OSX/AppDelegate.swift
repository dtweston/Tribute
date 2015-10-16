//
//  AppDelegate.swift
//  TributeExample-OSX
//
//  Created by Dave Weston on 5/16/15.
//  Copyright (c) 2015 Dave Weston. All rights reserved.
//

import Cocoa
import Tribute

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var textView: NSTextView!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        self.textView.editable = false
//        self.textView.delegate = self
        
        let parser = Parser()
        let emojiLookup = ["ok": GithubEmoji(name: "ok", url: NSURL(string: "https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png?v5")!)]
        let githubPlainTextHandler = GithubPlainTextHandler(emojiLookup: emojiLookup)
        let renderer = AttributedStringRenderer(plainTextHandler: githubPlainTextHandler)
        if let url = NSBundle.mainBundle().URLForResource("AFNetworking-README", withExtension: "md") {
            if let data = NSData(contentsOfURL: url) {
                if let str = String(data: data, encoding: NSUTF8StringEncoding) {
                    parser.parseMarkdown(str, renderer: renderer)
                }
            }
        }
        
        self.textView.textContainer?.replaceLayoutManager(MarkdownLayoutManager())
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue()) { () -> Void in
            self.textView.textStorage?.setAttributedString(renderer.finalString)
        }
}

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

