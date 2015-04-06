//
//  Parser.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import UIKit
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
        NSLog("ENTER %@(%@)", node.type!, node.literal!)
    }
    
    func parser(parser: Parser, didLeaveNode node: Node) {
        NSLog("LEAVE %@(%@)", node.type!, node.literal!)
    }
}

public class Parser {
    
    public init()
    {
        
    }
    
    public func parseMarkdown(markdown: String, renderer: Renderer)
    {
        let document = cmark_parse_document(markdown.cStringUsingEncoding(NSUTF8StringEncoding)!, Int(markdown.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), 0)
        
        var iter = cmark_iter_new(document);
        
        renderer.parserDidStart();
        
        var ev_type = cmark_iter_next(iter);
        while (ev_type.value != CMARK_EVENT_DONE.value) {
            let cur = cmark_iter_get_node(iter);
            let node = Node(cmarkNode: cur);
            if (ev_type.value == CMARK_EVENT_ENTER.value) {
                renderer.parser(self, didEnterNode: node)
            }
            else if (ev_type.value == CMARK_EVENT_EXIT.value) {
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
