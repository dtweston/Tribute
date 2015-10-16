//
//  Parser.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

import cmark_bridge

class DummyRenderer : Renderer
{
    func parserDidStart() {
        NSLog("Parse START")
    }
    
    func parserDidFinish() {
        NSLog("Parse END")
    }
    
    func parser(parser: Parser, didEnterNode node: Node) {
        print("ENTER \(node)")
    }
    
    func parser(parser: Parser, didLeaveNode node: Node) {
        print("LEAVE \(node)")
    }
}

public class Parser {
    
    public class func new() -> Parser {
        return Parser()
    }
    
    public init()
    {
        
    }
    
    public func parseMarkdown(markdown: String, renderer: Renderer)
    {
        let document = cmark_parse_document(markdown.cStringUsingEncoding(NSUTF8StringEncoding)!, Int(markdown.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), 0)
        
        let iter = cmark_iter_new(document);
        
        renderer.parserDidStart();
        
        var ev_type = cmark_iter_next(iter);
        while (ev_type != CMARK_EVENT_DONE) {
            let cur = cmark_iter_get_node(iter);
            let node = Node(cmarkNode: cur);
            if (ev_type == CMARK_EVENT_ENTER) {
                renderer.parser(self, didEnterNode: node)
            }
            else if (ev_type == CMARK_EVENT_EXIT) {
                renderer.parser(self, didLeaveNode: node)
            }
            
            ev_type = cmark_iter_next(iter);
        }
        
        renderer.parserDidFinish()
    }

    public func parseMarkdown(markdown: String)
    {
        parseMarkdown(markdown, renderer: DummyRenderer())
    }
}
