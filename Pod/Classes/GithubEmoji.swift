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
    let name: String
    let imageUrl: NSURL
    var image: UIImage?
    
    public init(name: String, url: NSURL) {
        self.name = name
        self.imageUrl = url
    }
}