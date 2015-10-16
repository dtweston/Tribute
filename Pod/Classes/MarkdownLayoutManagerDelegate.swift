//
//  MarkdownLayoutManagerDelegate.swift
//  Pods
//
//  Created by Dave Weston on 3/27/15.
//
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

public class MarkdownLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {
    
    public func layoutManager(layoutManager: NSLayoutManager, paragraphSpacingBeforeGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        
        let charIndex = layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
        if let storage = layoutManager.textStorage {
            if storage.length > charIndex {
                if let isCodeBlockStart = storage.attribute(CodeBlockStartAttributeName, atIndex: charIndex, effectiveRange: nil) as! Bool? {
                    if isCodeBlockStart {
                        return 15.0
                    }
                }
            }
        }
        
        return 0.0
    }
    
    public func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        let charIndex = layoutManager.characterIndexForGlyphAtIndex(glyphIndex)
        let val: AnyObject? = layoutManager.textStorage?.attribute(CodeBlockEndAttributeName, atIndex: charIndex, effectiveRange: nil)
        if let isCodeBlockStart = val as! Bool? {
            if isCodeBlockStart {
                return 15.0
            }
        }
        
        return 0.0
    }
}
