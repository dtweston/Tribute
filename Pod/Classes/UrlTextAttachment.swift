//
//  UrlTextAttachment.swift
//  Pods
//
//  Created by Dave Weston on 5/9/15.
//
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

public class UrlTextAttachment: NSTextAttachment {
    
    var platImage: PlatImage? {
        didSet {
            #if os(OSX)
                self.attachmentCell = NSTextAttachmentCell(imageCell: platImage)
            #endif
        }
    }
    
    public init(imageUrl: NSURL) {
        if #available(OSX 10.11, *) {
            super.init(data: nil, ofType: nil)
        } else {
            super.init()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW as dispatch_time_t, Int64(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.platImage = PlatImage(named: "mugshot")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("InvalidateAttachment", object: self)
            })
        })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: PlatRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> PlatRect {
        
        if let container = textContainer {
            if let size = platImage?.size {
                let availableWidth = lineFrag.size.width - 2 * container.lineFragmentPadding
                if availableWidth < size.width {
                    return CGRectMake(0, 0, availableWidth, size.height / size.width * availableWidth)
                }
            }
        }
        
        return CGRectZero
    }
    
    public override func imageForBounds(imageBounds: PlatRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> PlatImage? {
        return platImage
    }
}
