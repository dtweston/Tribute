//
//  File.swift
//  Pods
//
//  Created by Dave Weston on 5/17/15.
//
//

import Foundation

#if os(iOS)
    import UIKit
    public typealias PlatColor = UIColor
    public typealias PlatFontDescriptor = UIFontDescriptor
    public typealias PlatFont = UIFont
    public typealias PlatImage = UIImage
    public typealias PlatRect = CGRect

    public extension UIFont {
        var platformLineHeight : CGFloat {
            return 0.0
        }
        
        func platformFontDescriptor() -> UIFontDescriptor {
            return fontDescriptor()
        }
    }
    
    public extension UIFontDescriptor {
        func platformHasTraits() -> Bool {
            return symbolicTraits.rawValue != 0
        }
    }
#elseif os(OSX)
    import AppKit
    public typealias PlatColor = NSColor
    public typealias PlatFontDescriptor = NSFontDescriptor
    public typealias PlatFont = NSFont
    public typealias PlatImage = NSImage
    public typealias PlatRect = NSRect
    
    public extension NSFont {
        var platformLineHeight : CGFloat {
            return 0.0
        }
        
        func platformFontDescriptor() -> NSFontDescriptor {
            return fontDescriptor
        }
    }

    public extension NSFontDescriptor {
        func platformHasTraits() -> Bool {
            return symbolicTraits != 0
        }
    }
#endif
