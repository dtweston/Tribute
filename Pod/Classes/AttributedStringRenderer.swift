//
//  AttributedStringRenderer.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import UIKit

let QuoteLevelAttributeName = "QuoteLevelAttributeName"
let HruleAttributeName = "HruleAttributeName"
let CodeBlockStartAttributeName = "CodeBlockStartAttributeName"
let CodeBlockEndAttributeName = "CodeBlockEndAttributeName"

public class AttributedStringRenderer : Renderer
{
    let ZeroWidthSpace = "\u{2063}"
    
    let headerFontSizes = [24.0, 20.0, 18.0, 16.0, 14.0, 12.0];
    let baseFontDescriptor: UIFontDescriptor
    let codeFontDescriptor: UIFontDescriptor
    public let finalString: NSMutableAttributedString
    var currentAttributes: [NSObject: AnyObject]
    let plainTextHandler: PlainTextHandler
    var currentListSettings: ListSettings?
    
    var codeFont: UIFont {
        return UIFont(descriptor: self.codeFontDescriptor, size: 12)
    }
    
    var emphasisFontDescriptor: UIFontDescriptor? {
        return baseFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    }
    
    var emphasisFont: UIFont {
        return UIFont(descriptor: emphasisFontDescriptor!, size: 14)
    }
    
    var doubleEmphasisFontDescriptor: UIFontDescriptor? {
        return self.baseFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitItalic)
    }
    
    var doubleEmphasisFont: UIFont {
        return UIFont(descriptor: doubleEmphasisFontDescriptor!, size: 14)
    }
    
    var normalFont: UIFont {
        return UIFont(descriptor: self.baseFontDescriptor, size: 14)
    }
    
    var codeStyle : NSParagraphStyle {
        var style : NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        
        style.tailIndent = -10
        style.headIndent = 10
        style.tabStops = [NSTextTab(textAlignment: .Left, location: 10, options: nil)]
        style.lineHeightMultiple = 1.1
        return style
    }
    
    var headerStyle : NSParagraphStyle {
        var style : NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.paragraphSpacing = 10
        style.paragraphSpacingBefore = 5
        return style
    }
    
    var listStyle : NSParagraphStyle {
        var style: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.headIndent = 15
        style.tabStops = [NSTextTab(textAlignment: .Left, location: 15, options: nil)]
        return style
    }
    
    var quoteStyle : NSParagraphStyle {
        var style: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.firstLineHeadIndent = 20
        style.headIndent = 20
        style.tabStops = [NSTextTab(textAlignment: .Left, location: 20, options: nil)]
        return style
    }
    
    public init(plainTextHandler: PlainTextHandler) {
        self.baseFontDescriptor = UIFontDescriptor(name:"Avenir", size: 14)
        self.codeFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute: "Menlo", UIFontDescriptorSizeAttribute: 12])
        self.finalString = NSMutableAttributedString()
        self.currentAttributes = Dictionary()
        self.plainTextHandler = plainTextHandler
    }
    
    func resetAttributes() {
        self.currentAttributes = [NSFontAttributeName: self.normalFont]
    }
    
    public func parserDidStart() {
        self.resetAttributes()
    }
    
    public func parserDidFinish() {
    }
    
    public func parser(parser: Parser, didEnterNode node: Node) {
        NSLog("ENTER %@(%@)", node.type!, node.literal!)
        let type = node.type!
        
        if (type == "header") {
            let level = node.headerLevel
            let headerDescriptor = self.baseFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
            let fontSize = headerFontSizes[level - 1];
            let font = UIFont(descriptor: headerDescriptor!, size: CGFloat(fontSize))
            self.currentAttributes[NSFontAttributeName] = font
            self.currentAttributes[NSParagraphStyleAttributeName] = self.headerStyle
        }
        else if type == "hrule" {
            var attribs = self.currentAttributes
            attribs[HruleAttributeName] = 1
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
            self.finalString.appendAttributedString(NSAttributedString(string: ZeroWidthSpace, attributes:attribs))
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
        }
        else if (type == "text") {
            self.plainTextHandler.renderer(self, acceptText: node.literal ?? "")
        }
        else if (type == "image") {
            let imageUrl = node.url
            self.currentAttributes[NSLinkAttributeName] = imageUrl != nil ? NSURL(string: imageUrl!) : imageUrl
            let img = NSTextAttachment()
            img.image = nil;
            self.finalString.appendAttributedString(NSAttributedString(attachment: img))
        }
        else if (type == "link") {
            let url = node.url
            self.currentAttributes[NSLinkAttributeName] = url != nil ? NSURL(string: url!) : url
            self.currentAttributes[NSForegroundColorAttributeName] = UIColor.blueColor()
        }
        else if (type == "emph") {
            var newFont = self.doubleEmphasisFont
            if let currentFont = self.currentAttributes[NSFontAttributeName] as! UIFont? {
                newFont = UIFont(descriptor: currentFont.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitItalic)!, size: currentFont.pointSize)
            }
            
            self.currentAttributes[NSFontAttributeName] = newFont
        }
        else if (type == "strong") {
            var newFont = self.emphasisFont
            if let currentFont = self.currentAttributes[NSFontAttributeName] as! UIFont? {
                newFont = UIFont(descriptor: currentFont.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold)!, size: currentFont.pointSize)
            }
            
            self.currentAttributes[NSFontAttributeName] = newFont
        }
        else if (type == "code") {
            var attribs = self.currentAttributes
            let existing : UIFont? = attribs[NSFontAttributeName] as! UIFont?
            if let currentFont : UIFont = existing {
                var needed = self.codeFontDescriptor
                if currentFont.fontDescriptor().symbolicTraits.rawValue != 0 {
                    needed = self.codeFontDescriptor.fontDescriptorWithSymbolicTraits(currentFont.fontDescriptor().symbolicTraits | .TraitMonoSpace)!
                }
                let font = UIFont(descriptor: needed, size: currentFont.pointSize)
                attribs[NSFontAttributeName] = font
                attribs[NSBackgroundColorAttributeName] = UIColor(white: 247.0/255.0, alpha: 1.0)
                let str = String(format: "\u{202f}%@\u{202f}", node.literal!)
                self.finalString.appendAttributedString(NSAttributedString(string: str, attributes:attribs))
            }
        }
        else if type == "block_quote" {
            NSLog("%@", self.finalString)
            self.currentAttributes[NSParagraphStyleAttributeName] = self.quoteStyle
            if let level = self.currentAttributes[QuoteLevelAttributeName] as! Int? {
                self.currentAttributes[QuoteLevelAttributeName] = (level + 1)
            }
            else {
                self.currentAttributes[QuoteLevelAttributeName] = 1
            }
        }
        else if (type == "code_block") {
            let attribs = [NSFontAttributeName: self.codeFont, NSBackgroundColorAttributeName: UIColor(white: 247.0/255.0, alpha: 1.0), NSParagraphStyleAttributeName: self.codeStyle, NSBaselineOffsetAttributeName: 5]
            if let literal = node.literal {
                let string = literal.stringByReplacingOccurrencesOfString("\n", withString: "\n\t", options:nil, range:Range(start: literal.startIndex, end: advance(literal.endIndex, -1)))
                var startAttribs = attribs
                startAttribs[CodeBlockStartAttributeName] = true
                self.finalString.appendAttributedString(NSAttributedString(string: ZeroWidthSpace, attributes: startAttribs))
                self.finalString.appendAttributedString(NSAttributedString(string: String(format: "\t%@", string), attributes: attribs))
                var endAttribs = attribs
                endAttribs[CodeBlockEndAttributeName] = true
                self.finalString.appendAttributedString(NSAttributedString(string: ZeroWidthSpace, attributes: endAttribs))
            }
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
        }
        else if (type == "list") {
            self.currentListSettings = node.listSettings
            self.currentAttributes[NSParagraphStyleAttributeName] = self.listStyle
        }
        else if type == "item" {
            if let type = self.currentListSettings?.type {
                switch type {
                case .Bullet:
                    self.finalString.appendAttributedString(NSAttributedString(string:"\u{2022}\t", attributes: self.currentAttributes))
                case .Ordered:
                    self.finalString.appendAttributedString(NSAttributedString(string: String(format: "%d.\t", node.listStart), attributes: self.currentAttributes))
                case .None:
                    NSLog("Unhandled ListType.None")
                }
            }
        }
        else if (type == "softbreak") {
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
        }
    }
    
    public func parser(parser: Parser, didLeaveNode node: Node) {
        NSLog("LEAVE %@(%@)", node.type!, node.literal!)
        let type = node.type!
        
        if type == "list" {
            self.currentListSettings = nil
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
            self.resetAttributes()
        }
        else if type == "paragraph" {
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
            if self.currentListSettings?.tightness == nil {
                self.resetAttributes()
                self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
            }
        }
        else if type == "block_quote" {
            if let level = self.currentAttributes[QuoteLevelAttributeName] as! Int? {
                self.resetAttributes()
                if level > 1 {
                    self.currentAttributes[QuoteLevelAttributeName] = level - 1
                }
            }
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
        }
        else if type == "header" {
            self.resetAttributes()
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
            if node.headerLevel <= 2 {
                var attribs = self.currentAttributes
                attribs[HruleAttributeName] = 1
                self.finalString.appendAttributedString(NSAttributedString(string: ZeroWidthSpace, attributes:attribs))
            }
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
        }
        else if type == "code_block" || type == "html" || type == "hrule" {
            self.resetAttributes()
            self.finalString.appendAttributedString(NSAttributedString(string: "\n", attributes: self.currentAttributes))
        }
        else if type == "link" || type == "image" {
            self.currentAttributes.removeValueForKey(NSForegroundColorAttributeName)
            self.currentAttributes.removeValueForKey(NSLinkAttributeName)
        }
        else if type == "emph" || type == "strong" {
            self.currentAttributes[NSFontAttributeName] = self.normalFont
        }
    }
    
}