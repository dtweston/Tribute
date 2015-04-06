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

public struct ListSettings {
    let type: ListType
    let tightness: Bool
}

public class Node {
    
    let node: COpaquePointer
    
    init(cmarkNode node: COpaquePointer) {
        self.node = node
    }
    
    public var literal : String? {
        var literal = cmark_node_get_literal(self.node)
        if literal != nil {
            return String.fromCString(literal)
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
    
    public var type: String? {
        return String.fromCString(cmark_node_get_type_string(self.node))
    }
    
    public var listSettings: ListSettings {
        let cmark_type = cmark_node_get_list_type(self.node)
        let tightness = cmark_node_get_list_tight(self.node)
        var type = ListType.None
        if cmark_type.value == CMARK_BULLET_LIST.value {
            type = .Bullet
        }
        else if cmark_type.value == CMARK_ORDERED_LIST.value {
            type = .Ordered
        }

        return ListSettings(type: type, tightness: tightness == 1)
    }
    
    public var listStart: Int32 {
        return cmark_node_get_list_start(self.node)
    }
}
