//
//  StringExtensions.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 2/1/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation


extension String {
    
    static let MUST_REVALIDATE_PRECURSOR_REGEX = "(must-revalidate,+\\s)";
    static let MUST_REVALIDATE_POSTCURSOR_REGEX = "(,+\\smust-revalidate)"
    
    public func filterMustRevalidate() -> String {
        var mutableSelf = self
        mutableSelf.removingRegexMatches(pattern: .MUST_REVALIDATE_PRECURSOR_REGEX, replaceWith: "")
        mutableSelf.removingRegexMatches(pattern: .MUST_REVALIDATE_POSTCURSOR_REGEX, replaceWith: "")
        return mutableSelf
    }
    
    
    mutating func removingRegexMatches(pattern: String, replaceWith: String = "") {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, self.count)
            self = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch {
            return
        }
    }
    
}
