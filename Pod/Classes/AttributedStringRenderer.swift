//
//  AttributedStringRenderer.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

let QuoteLevelAttributeName = "QuoteLevelAttributeName"
let HruleAttributeName = "HruleAttributeName"
let ImageLinkAttributeName = "ImageLinkAttributeName"
let CodeBlockStartAttributeName = "CodeBlockStartAttributeName"
let CodeBlockEndAttributeName = "CodeBlockEndAttributeName"

public class AttributedStringRenderer : Renderer
{
    public class func attributedStringRender(plainTexthandler: PlainTextHandler) -> AttributedStringRenderer {
        return AttributedStringRenderer(plainTextHandler: plainTexthandler)
    }
    
    let ZeroWidthSpace = "\u{2063}"
    let ThinSpace = "\u{202f}"
    
    let headerFontSizes = [24.0, 20.0, 18.0, 16.0, 14.0, 12.0];
    let baseFontDescriptor: PlatFontDescriptor
    let codeFontDescriptor: PlatFontDescriptor
    public let finalString: NSMutableAttributedString
    var currentAttributes: [String: AnyObject]
    let plainTextHandler: PlainTextHandler
    var currentListSettings: ListSettings?
    var currentListOrdinal: Int
    
    var codeFont: PlatFont? {
        return PlatFont(descriptor: codeFontDescriptor, size: 12)
    }
    
    var emphasisFontDescriptor: PlatFontDescriptor? {
        #if os(iOS)
            return baseFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
        #elseif os(OSX)
            return baseFontDescriptor.fontDescriptorWithSymbolicTraits(NSFontSymbolicTraits(NSFontBoldTrait))
        #endif
    }
    
    var emphasisFont: PlatFont? {
        return PlatFont(descriptor: emphasisFontDescriptor!, size: 14)
    }
    
    var doubleEmphasisFontDescriptor: PlatFontDescriptor? {
        #if os(iOS)
            return baseFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitItalic)
        #elseif os(OSX)
            return baseFontDescriptor.fontDescriptorWithSymbolicTraits(NSFontSymbolicTraits(NSFontItalicTrait))
        #endif
    }
    
    var doubleEmphasisFont: PlatFont? {
        return PlatFont(descriptor: doubleEmphasisFontDescriptor!, size: 14)
    }
    
    var normalFont: PlatFont {
        #if os(iOS)
        return PlatFont(descriptor: baseFontDescriptor, size: 14)
        #elseif os(OSX)
        return PlatFont(descriptor: baseFontDescriptor, size: 14)!
        #endif
    }
    
    func leftTabAtLocation(location: CGFloat) -> NSTextTab {
        #if os(iOS)
            return NSTextTab(textAlignment: .Left, location: location, options: [:])
        #elseif os(OSX)
            return NSTextTab(textAlignment: NSTextAlignment.Left, location: location, options: [:])
        #endif
    }
    
    var codeStyle : NSParagraphStyle {
        let style = newStyle()
        style.tailIndent = -10
        style.headIndent = 10
        style.tabStops = [leftTabAtLocation(10)]
        style.lineHeightMultiple = 1.1
        return style
    }
    
    var headerStyle : NSParagraphStyle {
        let style = newStyle()
        style.paragraphSpacing = 10
        style.paragraphSpacingBefore = 5
        return style
    }
    
    var listStyle : NSParagraphStyle {
        let style = newStyle()
        style.headIndent = 15
        style.tabStops = [leftTabAtLocation(15)]
        return style
    }
    
    var quoteStyle : NSParagraphStyle {
        let style = newStyle()
        style.firstLineHeadIndent = 20
        style.headIndent = 20
        style.tabStops = [leftTabAtLocation(20)]
        return style
    }
    
    func newStyle() -> NSMutableParagraphStyle {
        return NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    }
    
    public init(plainTextHandler: PlainTextHandler) {
        baseFontDescriptor = PlatFontDescriptor(name:"Avenir", size: 14)
        #if os(iOS)
            codeFontDescriptor = PlatFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute: "Menlo", UIFontDescriptorSizeAttribute: 12])
        #elseif os(OSX)
            codeFontDescriptor = PlatFontDescriptor(fontAttributes: [NSFontFamilyAttribute: "Menlo", NSFontSizeAttribute: 12])
        #endif
        finalString = NSMutableAttributedString()
        currentAttributes = Dictionary()
        currentListOrdinal = 0
        self.plainTextHandler = plainTextHandler
    }
    
    func resetAttributes() {
        currentAttributes = [NSFontAttributeName: normalFont]
    }
    
    public func parserDidStart() {
        resetAttributes()
    }
    
    public func parserDidFinish() {
    }
    
    func appendString(string: String) {
        appendString(string, attributes: currentAttributes)
    }
    
    func appendString(string: String, attributes: [String: AnyObject]?) {
        appendAttributedString(NSAttributedString(string: string, attributes: attributes))
    }
    
    func appendAttributedString(attribString: NSAttributedString) {
        finalString.appendAttributedString(attribString)
    }
    
    func appendNewLine() {
        appendString("\n")
    }
    
    public func parser(parser: Parser, didEnterNode node: Node) {
        print("ENTER \(node)")
        let type = node.type
        
        if type == .Header {
            let level = node.headerLevel
            #if os(iOS)
            let headerDescriptor = baseFontDescriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
            #elseif os(OSX)
            let headerDescriptor: PlatFontDescriptor = baseFontDescriptor.fontDescriptorWithSymbolicTraits(NSFontSymbolicTraits( NSFontBoldTrait))
            #endif
            let fontSize = headerFontSizes[level - 1];
            let font = PlatFont(descriptor: headerDescriptor, size: CGFloat(fontSize))
            currentAttributes[NSFontAttributeName] = font
            currentAttributes[NSParagraphStyleAttributeName] = headerStyle
        }
        else if type == .Hrule {
            var attribs = currentAttributes
            attribs[HruleAttributeName] = 1
            appendNewLine()
            appendString(ZeroWidthSpace, attributes: attribs)
            appendNewLine()
        }
        else if type == .Text {
            plainTextHandler.renderer(self, acceptText: node.literal)
        }
        else if type == .Image {
            if let imageUrlString = node.url {
                if let imageUrl = NSURL(string:imageUrlString) {
                    currentAttributes[ImageLinkAttributeName] = imageUrl
                    let img = UrlTextAttachment(imageUrl: imageUrl)
                    img.platImage = PlatImage(named: "jed_ok_with_that")
                    appendAttributedString(NSAttributedString(attachment: img))
                }
            }
        }
        else if type == .Link {
            let url = node.url
            currentAttributes[NSLinkAttributeName] = url != nil ? NSURL(string: url!) : url
            currentAttributes[NSForegroundColorAttributeName] = PlatColor.blueColor()
        }
        else if type == .Emph {
            var newFont = doubleEmphasisFont
            if let currentFont = currentAttributes[NSFontAttributeName] as! PlatFont? {
                #if os(iOS)
                newFont = PlatFont(descriptor: currentFont.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitItalic), size: currentFont.pointSize)
                #elseif os(OSX)
                    newFont = PlatFont(descriptor: currentFont.fontDescriptor.fontDescriptorWithSymbolicTraits(NSFontSymbolicTraits(NSFontItalicTrait)), size: currentFont.pointSize)
                #endif
            }
            
            currentAttributes[NSFontAttributeName] = newFont
        }
        else if type == .Strong {
            var newFont = emphasisFont
            if let currentFont = currentAttributes[NSFontAttributeName] as! PlatFont? {
                #if os(iOS)
                newFont = PlatFont(descriptor: currentFont.fontDescriptor().fontDescriptorWithSymbolicTraits(.TraitBold), size: currentFont.pointSize)
                #elseif os(OSX)
                newFont = PlatFont(descriptor: currentFont.fontDescriptor.fontDescriptorWithSymbolicTraits(NSFontSymbolicTraits(NSFontBoldTrait)), size: currentFont.pointSize)
                #endif
            }
            
            currentAttributes[NSFontAttributeName] = newFont
        }
        else if type == .Code {
            var attribs = currentAttributes
            let existing = attribs[NSFontAttributeName] as! PlatFont?
            if let currentFont : PlatFont = existing {
                var needed = codeFontDescriptor
                if currentFont.platformFontDescriptor().platformHasTraits() {
                    #if os(iOS)
                        needed = codeFontDescriptor.fontDescriptorWithSymbolicTraits([currentFont.fontDescriptor().symbolicTraits, .TraitMonoSpace])
                    #elseif os(OSX)
                    needed = codeFontDescriptor.fontDescriptorWithSymbolicTraits(currentFont.fontDescriptor.symbolicTraits | NSFontSymbolicTraits(NSFontMonoSpaceTrait))
                    #endif
                }
                let font = PlatFont(descriptor: needed, size: currentFont.pointSize)
                attribs[NSFontAttributeName] = font
                attribs[NSBackgroundColorAttributeName] = PlatColor(white: 247.0/255.0, alpha: 1.0)
                let str = "\(ThinSpace)\(node.literal)\(ThinSpace)"
                appendString(str, attributes: attribs)
            }
        }
        else if type == .BlockQuote {
            currentAttributes[NSParagraphStyleAttributeName] = quoteStyle
            if let level = currentAttributes[QuoteLevelAttributeName] as! Int? {
                currentAttributes[QuoteLevelAttributeName] = (level + 1)
            }
            else {
                currentAttributes[QuoteLevelAttributeName] = 1
            }
        }
        else if type == .CodeBlock {
            let backColor = PlatColor(white: 247.0/255.0, alpha: 1.0)
            var attribs : [String:AnyObject] = [:]
            attribs[NSFontAttributeName] = codeFont
            attribs[NSBackgroundColorAttributeName] = backColor
            attribs[NSParagraphStyleAttributeName] = codeStyle
            attribs[NSBaselineOffsetAttributeName] = 5
            if node.literal.utf16.count > 0 {
                let literal = node.literal
                let string = literal.stringByReplacingOccurrencesOfString("\n", withString: "\n\t", options:NSStringCompareOptions(), range:Range(start: literal.startIndex, end: literal.endIndex.advancedBy(-1)))
                var startAttribs = attribs
                startAttribs[CodeBlockStartAttributeName] = true
                appendString(ZeroWidthSpace, attributes: startAttribs)
                appendString(String(format: "\t%@", string), attributes: attribs)
                var endAttribs = attribs
                endAttribs[CodeBlockEndAttributeName] = true
                appendString(ZeroWidthSpace, attributes: endAttribs)
            }
            appendNewLine()
        }
        else if type == .List {
            currentListSettings = node.listSettings
            currentListOrdinal = node.listSettings.start
            currentAttributes[NSParagraphStyleAttributeName] = listStyle
        }
        else if type == .Item {
            if let settings = currentListSettings {
                switch settings.type {
                case .Bullet:
                    appendString("\u{2022}\t")
                case .Ordered:
                    appendString(String(format: "%d\(settings.delimiter.repr)\t", currentListOrdinal))
                    currentListOrdinal += 1
                case .None:
                    NSLog("Unhandled ListType.None")
                }
            }
        }
        else if type == .SoftBreak {
            appendNewLine()
        }
    }
    
    public func parser(parser: Parser, didLeaveNode node: Node) {
        print("LEAVE \(node)")
        let type = node.type
        
        if type == .List {
            currentListSettings = nil
            currentListOrdinal = 0
            appendNewLine()
            resetAttributes()
        }
        else if type == .Paragraph {
            appendNewLine()
            if currentListSettings?.tightness == nil {
                resetAttributes()
                appendNewLine()
            }
        }
        else if type == .BlockQuote {
            if let level = currentAttributes[QuoteLevelAttributeName] as! Int? {
                resetAttributes()
                if level > 1 {
                    currentAttributes[QuoteLevelAttributeName] = level - 1
                }
            }
            appendNewLine()
        }
        else if type == .Header {
            resetAttributes()
            appendNewLine()
            if node.headerLevel <= 2 {
                var attribs = currentAttributes
                attribs[HruleAttributeName] = 1
                appendString(ZeroWidthSpace, attributes: attribs)
            }
            appendNewLine()
        }
        else if type == .CodeBlock || type == .Html || type == .Hrule {
            resetAttributes()
            appendNewLine()
        }
        else if type == .Link || type == .Image {
            currentAttributes.removeValueForKey(NSForegroundColorAttributeName)
            currentAttributes.removeValueForKey(NSLinkAttributeName)
        }
        else if type == .Emph || type == .Strong {
            currentAttributes[NSFontAttributeName] = normalFont
        }
    }
    
}