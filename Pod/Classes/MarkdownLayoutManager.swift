//
//  MarkdownLayoutManager.swift
//  Pods
//
//  Created by Dave Weston on 3/10/15.
//
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif
    
public class MarkdownLayoutManager: NSLayoutManager {

    var attachmentsPositions: [UrlTextAttachment: Int]
    
    override public init() {
        attachmentsPositions = [:]
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserverForName("InvalidateAttachment", object: nil, queue: nil) { (note) -> Void in
            if let attachment = note.object as? UrlTextAttachment {
                if let charIndex = self.attachmentsPositions[attachment] {
                    let charRange = NSMakeRange(charIndex, 1)
                    self.invalidateGlyphsForCharacterRange(charRange, changeInLength: 0, actualCharacterRange: nil)
                    self.invalidateLayoutForCharacterRange(charRange, actualCharacterRange: nil)
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        attachmentsPositions = [:]

        super.init(coder: aDecoder)
    }
    
    private var currentContext: CGContextRef? {
        #if os(iOS)
            return UIGraphicsGetCurrentContext()
        #else
            if #available(OSX 10.10, *) {
                return NSGraphicsContext.currentContext()?.CGContext
            }
            else if let contextPointer = NSGraphicsContext.currentContext()?.graphicsPort {
                let context: CGContextRef = Unmanaged.fromOpaque(COpaquePointer(contextPointer)).takeUnretainedValue()
                return context
            }
            
            return nil
        #endif
    }
    
    override public func drawBackgroundForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        
        var hruleRanges: [NSRange] = []
        self.textStorage?.enumerateAttribute(HruleAttributeName, inRange: glyphsToShow, options: NSAttributedStringEnumerationOptions(), usingBlock: { (value : AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
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
        self.textStorage?.enumerateAttribute(QuoteLevelAttributeName, inRange: glyphsToShow, options: NSAttributedStringEnumerationOptions(), usingBlock: { (value : AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
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
            let context = currentContext
            PlatColor(white: 0.8, alpha: 1.0).setFill()
            
            CGContextFillRects(context, &rects, Int(rects.count))
        }

        super.drawBackgroundForGlyphRange(glyphsToShow, atPoint: origin)
    }
    
#if os(iOS)
    public override func setGlyphs(glyphs: UnsafePointer<CGGlyph>, properties props: UnsafePointer<NSGlyphProperty>, characterIndexes charIndexes: UnsafePointer<Int>, font aFont: PlatFont?, forGlyphRange glyphRange: NSRange) {
        
        super.setGlyphs(glyphs, properties: props, characterIndexes: charIndexes, font: aFont!, forGlyphRange: glyphRange)
        for (var i = 0; i < glyphRange.length; i++) {
            let glyphProperty = props[i];
            let characterIndex = charIndexes[i];
            let glyph = glyphs[i];
            if (glyphProperty == .ControlCharacter) {
                let character = NSString(string: textStorage!.string).characterAtIndex(characterIndex)
                let attribs = textStorage!.attributesAtIndex(characterIndex, effectiveRange: nil)
                if (Int(character) == NSAttachmentCharacter) {
                    if let attach = attribs[NSAttachmentAttributeName] as? UrlTextAttachment {
                        attachmentsPositions[attach] = characterIndex
                        print("Attributes: \(attribs)")
                    }
                }
            }
        }
    }
#endif
}
