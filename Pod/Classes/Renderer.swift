//
//  Renderer.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

public protocol Renderer {
    func parserDidStart()
    func parserDidFinish()
    func parser(parser: Parser, didEnterNode node: Node)
    func parser(parser: Parser, didLeaveNode node: Node)
}
