//
//  GithubPlainTextHandler.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import Foundation
import UIKit
import AVFoundation

public class GithubPlainTextHandler : PlainTextHandler
{
    let emojiLookup: [String: GithubEmoji]
    
    public init(emojiLookup: [String: GithubEmoji]) {
        self.emojiLookup = emojiLookup
    }
    
    lazy var githubParser: GithubParser = {
        return GithubParser()
    }()
    
    func scale(image: UIImage, height: CGFloat) -> UIImage
    {
        let destRect = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, 1000, height))
        UIGraphicsBeginImageContextWithOptions(destRect.size, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, destRect.size.width, destRect.size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    public func renderer(renderer: AttributedStringRenderer, acceptText text: String) {
        let components = self.githubParser.components(fromText: text)
        for component in components {
            let bold = component.isBold
            var text = component.text
            
            var finalAttribs = renderer.currentAttributes
            if let emojiName = component.emojiName {
                if let font = finalAttribs[NSFontAttributeName] as! UIFont? {
                    let lineHeight = font.lineHeight * 0.9
                    if let img = self.emojiLookup[emojiName]?.image {
                        let scaledImage = self.scale(img, height: lineHeight)
                        let attach = NSTextAttachment()
                        attach.image = scaledImage
                        renderer.finalString.appendAttributedString(NSAttributedString(attachment: attach))
                    }
                }
                else {
                    text = String(format: ":%@", emojiName)
                }
            }
            
            if bold {
                if let font = finalAttribs[NSFontAttributeName] as! UIFont? {
                    let currentDescriptor = font.fontDescriptor()
                    let boldDescriptor = currentDescriptor.fontDescriptorWithSymbolicTraits(currentDescriptor.symbolicTraits | .TraitBold)
                    finalAttribs[NSFontAttributeName] = UIFont(descriptor:boldDescriptor!, size: font.pointSize)
                }
            }
            
            if let url = component.url {
                finalAttribs[NSLinkAttributeName] = url
                finalAttribs[NSForegroundColorAttributeName] = UIColor.blueColor()
            }
            
            if !text.isEmpty {
                renderer.finalString.appendAttributedString(NSAttributedString(string: text, attributes: finalAttribs))
            }
        }
    }
}