//
//  GithubEmoji.swift
//  Pods
//
//  Created by Dave Weston on 3/10/15.
//
//

import Foundation

public class GithubEmoji
{
    public let name: String
    public let imageUrl: NSURL
    public var image: PlatImage?
    
    public init(name: String, url: NSURL) {
        self.name = name
        self.imageUrl = url
    }
}