//
//  GithubPlainTextHandler.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import Foundation
import AVFoundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

public class GithubPlainTextHandler : PlainTextHandler
{
    public class func plainTextHandler(emojiLookup: [String: GithubEmoji]) -> GithubPlainTextHandler {
        return GithubPlainTextHandler(emojiLookup: emojiLookup)
    }
    
    let emojiLookup: [String: GithubEmoji]
    
    public init(emojiLookup: [String: GithubEmoji]) {
        self.emojiLookup = emojiLookup
    }
    
    lazy var githubParser: GithubParser = {
        return GithubParser()
    }()
    
    func scale(image: PlatImage, height: CGFloat) -> PlatImage
    {
        let destRect = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, 1000, height))
        #if os(iOS)
        UIGraphicsBeginImageContextWithOptions(destRect.size, false, 0.0)
        #elseif os(OSX)
        let scaledImage = NSImage(size: destRect.size)
        scaledImage.lockFocus()
        #endif
        image.drawInRect(CGRectMake(0, 0, destRect.size.width, destRect.size.height))
        #if os(iOS)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        #elseif os(OSX)
        scaledImage.unlockFocus()
        #endif
        
        return scaledImage
    }
    
    public func renderer(renderer: AttributedStringRenderer, acceptText text: String) {
        let components = self.githubParser.components(fromText: text)
        for component in components {
            let bold = component.isBold
            var text = component.text
            
            var finalAttribs = renderer.currentAttributes
            if let emojiName = component.emojiName {
                if let font = finalAttribs[NSFontAttributeName] as! PlatFont? {
                    let lineHeight = font.platformLineHeight * 0.9
                    if let img = self.emojiLookup[emojiName]?.image {
                        let scaledImage = self.scale(img, height: lineHeight)
                        let attach = NSTextAttachment()
//                        attach.image = scaledImage
                        renderer.finalString.appendAttributedString(NSAttributedString(attachment: attach))
                    }
                }
                else {
                    text = String(format: ":%@", emojiName)
                }
            }
            
            if bold {
                if let font = finalAttribs[NSFontAttributeName] as! PlatFont? {
                    let currentDescriptor = font.platformFontDescriptor()
                    #if os(iOS)
                        let boldDescriptor = currentDescriptor.fontDescriptorWithSymbolicTraits([currentDescriptor.symbolicTraits, UIFontDescriptorSymbolicTraits.TraitBold])
                        finalAttribs[NSFontAttributeName] = PlatFont(descriptor:boldDescriptor, size: font.pointSize)
                    #elseif os(OSX)
                        let currentTraits = currentDescriptor.symbolicTraits
                        let boldDescriptor = currentDescriptor.fontDescriptorWithSymbolicTraits(currentTraits | NSFontSymbolicTraits(NSFontBoldTrait))
                    #endif
                    finalAttribs[NSFontAttributeName] = PlatFont(descriptor:boldDescriptor, size: font.pointSize)
                }
            }
            
            if let url = component.url {
                finalAttribs[NSLinkAttributeName] = url
                finalAttribs[NSForegroundColorAttributeName] = PlatColor.blueColor()
            }
            
            if !text.isEmpty {
                renderer.finalString.appendAttributedString(NSAttributedString(string: text, attributes: finalAttribs))
            }
        }
    }
}