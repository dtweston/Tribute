//
//  PlainTextHandler.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import Foundation

public protocol PlainTextHandler
{
    func renderer(renderer: AttributedStringRenderer, acceptText text:String)
}