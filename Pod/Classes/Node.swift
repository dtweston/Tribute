//
//  Node.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import cmark_bridge

public enum ListType {
    case None
    case Bullet
    case Ordered
}

public enum ListDelimiterType {
    case None
    case Period
    case Parenthesis
    
    public var repr: String {
        get {
            switch self {
            case .None: return ""
            case .Period: return "."
            case .Parenthesis: return ")"
            }
        }
    }
}

public struct ListSettings {
    let type: ListType
    let tightness: Bool
    let delimiter: ListDelimiterType
    let start: Int
}

public enum NodeType {
    case Unknown
    case Document
    case Header
    case Html
    case Hrule
    case Text
    case Image
    case Link
    case Emph
    case Strong
    case Code
    case BlockQuote
    case CodeBlock
    case List
    case Item
    case SoftBreak
    case Paragraph
}

extension NodeType : CustomStringConvertible {
    public var description: String {
        get {
            switch self {
            case .Unknown: return "unknown"
            case .Document: return "document"
            case .Header: return "header"
            case .Html: return "html"
            case .Hrule: return "hrule"
            case .Text: return "text"
            case .Image: return "image"
            case .Link: return "link"
            case .Emph: return "emph"
            case .Strong: return "strong"
            case .Code: return "code"
            case .BlockQuote: return "block_quote"
            case .CodeBlock: return "code_block"
            case .List: return "list"
            case .Item: return "item"
            case .SoftBreak: return "softbreak"
            case .Paragraph: return "paragraph"
            }
        }
    }
}

public class Node {
    
    let node: COpaquePointer
    
    init(cmarkNode node: COpaquePointer) {
        self.node = node
    }
    
    public var literal : String {
        let literal = cmark_node_get_literal(self.node)
        if literal != nil {
            return String.fromCString(literal) ?? ""
        }
        
        return ""
    }
    
    public var headerLevel: Int32 {
        return cmark_node_get_header_level(self.node)
    }
    
    public var url: String? {
        let url = cmark_node_get_url(self.node)
        return String.fromCString(url)
    }
    
    public var type: NodeType {
        let cTypeString = cmark_node_get_type_string(self.node)
        if let typeString = String.fromCString(cTypeString) {
            switch (typeString) {
                case "document": return NodeType.Document
                case "header": return NodeType.Header
                case "hrule": return NodeType.Hrule
                case "html": return NodeType.Html
                case "text": return NodeType.Text
                case "image": return NodeType.Image
                case "link": return NodeType.Link
                case "emph": return NodeType.Emph
                case "strong": return NodeType.Strong
                case "code": return NodeType.Code
                case "block_quote": return NodeType.BlockQuote
                case "code_block": return NodeType.CodeBlock
                case "list": return NodeType.List
                case "item": return NodeType.Item
                case "softbreak": return NodeType.SoftBreak
                case "paragraph": return NodeType.Paragraph
                default: return NodeType.Unknown
            }
        }
        
        return NodeType.Unknown
    }
    
    public var fenceInfo: String {
        let fence_info = cmark_node_get_fence_info(self.node)
        if fence_info != nil {
            return String.fromCString(fence_info) ?? ""
        }
        
        return ""
    }
    
    public var listSettings: ListSettings {
        let cmark_type = cmark_node_get_list_type(self.node)
        let tightness = cmark_node_get_list_tight(self.node)
        let listStart = cmark_node_get_list_start(self.node)
        let delim_type = cmark_node_get_list_delim(self.node)
        
        var type = ListType.None
        if cmark_type == CMARK_BULLET_LIST {
            type = .Bullet
        }
        else if cmark_type == CMARK_ORDERED_LIST {
            type = .Ordered
        }
        
        var delimType = ListDelimiterType.None
        if delim_type == CMARK_PERIOD_DELIM {
            delimType = .Period
        }
        else if delim_type == CMARK_PAREN_DELIM {
            delimType = .Parenthesis
        }

        return ListSettings(type: type, tightness: tightness == 1, delimiter: delimType, start: Int(listStart))
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        get { return "\(type)(\(literal))" }
    }
}
