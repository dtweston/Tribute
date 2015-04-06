//
//  MarkdownLayoutManager.swift
//  Pods
//
//  Created by Dave Weston on 3/10/15.
//
//

import UIKit

public class MarkdownLayoutManager: NSLayoutManager {

    override public func drawBackgroundForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        
        var hruleRanges: [NSRange] = []
        self.textStorage?.enumerateAttribute(HruleAttributeName, inRange: glyphsToShow, options: .allZeros, usingBlock: { (value : AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if value != nil {
                hruleRanges.append(range)
            }
        })

        var rects: [CGRect] = []
        
        if hruleRanges.count > 0 {
            for range in hruleRanges {
                let startRect = self.lineFragmentRectForGlyphAtIndex(range.location, effectiveRange: nil)
                let endRect = self.lineFragmentRectForGlyphAtIndex(NSMaxRange(range), effectiveRange: nil)

                let lineRect = CGRectMake(5, CGRectGetMidY(startRect) - 0.5, CGRectGetWidth(startRect) - 10, 1)
                rects.append(lineRect)
            }
        }
        
        var quoteRanges: [NSRange] = []
        self.textStorage?.enumerateAttribute(QuoteLevelAttributeName, inRange: glyphsToShow, options: .allZeros, usingBlock: { (value : AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if value != nil {
                quoteRanges.append(range)
            }
        })
        
        if quoteRanges.count > 0 {
            for range in quoteRanges {
                let startRect = self.lineFragmentRectForGlyphAtIndex(range.location, effectiveRange: nil)
                let endRect = self.lineFragmentRectForGlyphAtIndex(NSMaxRange(range), effectiveRange: nil)
                
                let lineRect = CGRectMake(startRect.origin.x + 2, startRect.origin.y, 4, CGRectGetMaxY(endRect) - startRect.origin.y)
                
                rects.append(lineRect)
            }
        }
        
        if rects.count > 0 {
            
            let context = UIGraphicsGetCurrentContext()
            UIColor(white: 0.8, alpha: 1.0).setFill()
            
            CGContextFillRects(context, &rects, Int(rects.count))
        }

        super.drawBackgroundForGlyphRange(glyphsToShow, atPoint: origin)
    }
}
