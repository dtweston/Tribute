//
//  GithubParser.swift
//  Pods
//
//  Created by Dave Weston on 3/9/15.
//
//

import Foundation

class TextComponentContainer
{
    var accumulator: String = ""
    var components: [TextComponent] = []
    
    func accumulate(text: String)
    {
        self.accumulator += text
    }
    
    func add(component: TextComponent)
    {
        self.components.append(component)
    }
    
    func flush()
    {
        self.add(PlainTextComponent(plainText: self.accumulator))
        self.accumulator = ""
    }
}

class GithubParser
{
    lazy var commitRegex: NSRegularExpression = {
        let regex = NSRegularExpression(pattern:"^(([-.\\w]+)(/([-.\\w]+))?@)?([a-fA-F0-9]{40})$", options: NSRegularExpressionOptions.allZeros, error: nil)
        return regex!
    }()
    
    lazy var issueRegex: NSRegularExpression = {
        let regex = NSRegularExpression(pattern: "^(([-.\\w]+)(/([-.\\w]+))?)?#(\\d+)$", options: NSRegularExpressionOptions.allZeros, error: nil)
        return regex!
        }()
    
    lazy var userRefRegex: NSRegularExpression = {
        let regex = NSRegularExpression(pattern:"^@([-\\w]+)$", options: NSRegularExpressionOptions.allZeros, error: nil)
        return regex!
    }()
    
    func parseCommitRef(word: NSString) -> TextComponent?
    {
        if word.length < 40 {
            return nil
        }
        
        if let result = self.commitRegex.firstMatchInString(word as String, options: .allZeros, range: NSMakeRange(0, word.length)) {
            let shaRange = result.rangeAtIndex(5)
            let repoRange = result.rangeAtIndex(4)
            let ownerRange = result.rangeAtIndex(2)
            
            let sha = word.substringWithRange(shaRange)
            if ownerRange.location != NSNotFound {
                let owner = word.substringWithRange(ownerRange)
                if (repoRange.location != NSNotFound) {
                    let repo = word.substringWithRange(repoRange)
                    
                }
                else {
                    
                }
            }
        }
        return nil
    }
    
    func parseIssue(word: NSString) -> TextComponent?
    {
        let range = word.rangeOfString("#")
        if range.length == 0 {
            return nil
        }
        
        if let result = self.issueRegex.firstMatchInString(word as String, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, word.length)) {
            
            let issueRange = result.rangeAtIndex(5)
            let repoRange = result.rangeAtIndex(4)
            let ownerRange = result.rangeAtIndex(2)
            
            let issue = word.substringWithRange(issueRange).toInt()
            if issue == nil {
                return nil
            }
            if ownerRange.location != NSNotFound {
                let owner = word.substringWithRange(ownerRange)
                if repoRange.location != NSNotFound {
                    let repo = word.substringWithRange(repoRange)
                    return IssueComponent(issue: issue!, repo: repo, owner: owner)
                }
                else {
                    return IssueComponent(issue: issue!, owner: owner)
                }
            }
            else {
                return IssueComponent(issue: issue!)
            }
        }
        
        return nil
    }
    
    func parseUserMention(word: String) -> TextComponent?
    {
        if let result = self.userRefRegex.firstMatchInString(word, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(word.utf16))) {
            
            let username = word.substringFromIndex(advance(word.startIndex, 1))
            return UserMentionComponent(username: username)
        }
        
        return nil
    }
    
    func components(fromText text: String) -> [TextComponent]
    {
        let scanner = NSScanner(string: text)
        scanner.charactersToBeSkipped = NSCharacterSet()
 
        let components = TextComponentContainer()
        while !scanner.atEnd {
            var maybeWord : NSString? = nil
            if scanner.scanUpToCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &maybeWord) {
                
                let word = maybeWord!
                if word.hasPrefix(":") && word.hasSuffix(":") && word.length > 2 {
                    NSLog("Found potential emoji: %@", word)
                    let emoji = word.substringWithRange(NSMakeRange(1, word.length-2))
                    components.add(EmojiComponent(emoji: emoji))
                    continue
                }
                
                if word.hasPrefix("@") {
                    NSLog("Found potential user mention: %@", word)
                    if let userMention = self.parseUserMention(word as String) {
                        components.add(userMention)
                        continue
                    }
                }
                else {
                    if let issue = self.parseIssue(word) {
                        components.add(issue)
                        continue
                    }
                    
                    if let commit = self.parseCommitRef(word) {
                        components.add(commit)
                        continue
                    }
                }
                
                components.accumulate(word as String)
            }
            
            var maybeWhitespace: NSString? = nil
            if scanner.scanCharactersFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet(), intoString: &maybeWhitespace) {
                let whitespace = maybeWhitespace!
                components.accumulate(whitespace as String)
            }
        }
        
        components.flush()
        
        return components.components
    }
}