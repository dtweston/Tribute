//
//  TextComponent.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import Foundation

protocol TextComponent
{
    var emojiName : String? { get }
    var isBold : Bool { get }
    var text : String { get }
    var url : NSURL? { get }
}

class BaseTextComponent: TextComponent
{
    var emojiName: String? { get { return nil } }
    var isBold : Bool { get { return false } }
    var text: String { get { return "" } }
    var url: NSURL? { get { return nil } }
}

class PlainTextComponent : BaseTextComponent
{
    var plainText: String
    
    init(plainText: String)
    {
        self.plainText = plainText
    }
    
    override var text: String { return self.plainText }
}

class EmojiComponent: BaseTextComponent
{
    var emoji: String
    init(emoji: String)
    {
        self.emoji = emoji
    }
    
    override var emojiName: String? { get { return self.emoji } }
}

class IssueComponent: BaseTextComponent
{
    var issueNumber: Int
    var repo: String?
    var owner: String?
    
    init(issue: Int, owner: String? = nil, repo: String? = nil)
    {
        assert(issue >= 0, "Issue number is required to be positive")
        self.issueNumber = issue
        self.repo = repo
        self.owner = owner
    }
    
    override var text: String {
        get {
            var string = ""
            if let owner = self.owner {
                if let repo = self.repo {
                    string += "\(owner)/\(repo)"
                }
                else {
                    string += "\(owner)"
                }
            }
            string += "#\(self.issueNumber)"
            
            return string
        }
    }
    
    override var url: NSURL? {
        return NSURL(string: String(format:"coderev://%@", self.text))
    }
}

class ShaRefComponent: BaseTextComponent
{
    var sha: String
    var owner: String?
    var repo: String?
    
    init(sha: String, owner: String? = nil, repo: String? = nil) {
        self.sha = sha
        self.owner = owner
        self.repo = repo
    }
    
    lazy var subText: String = {
        var subText = ""
        if let owner = self.owner {
            if let repo = self.repo {
                subText += "\(owner)/\(repo)"
            }
            else {
                subText += owner
            }
        }
        return subText
    }()
    
    override var text: String { get { return String(format: "%@%@%@", subText, !subText.isEmpty ? "@" : "", self.sha.substringToIndex(self.sha.startIndex.advancedBy(6))) } }
    override var url: NSURL? { get { return NSURL(string:String(format: "coderev://%@@%@", self.subText, self.sha)) } }
}

class UserMentionComponent: BaseTextComponent
{
    var username: String
    init(username: String)
    {
        self.username = username
    }
    
    override var text: String { get { return String(format: "@%@", self.username) } }
    override var isBold: Bool { get { return true } }
}
