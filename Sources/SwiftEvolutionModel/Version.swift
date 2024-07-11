//
//  SwiftVersion.swift
//
//  Created by Victor Martins on 29/02/24.
//

import Foundation
import RegexBuilder

public struct Version: Hashable, Equatable, Codable, Comparable, Sendable {
    
    let major: Int
    let minor: Int?
    let patch: Int?
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.major == rhs.major
        && (lhs.minor ?? 0) == (rhs.minor ?? 0)
        && (lhs.patch ?? 0) == (rhs.patch ?? 0)
    }
    
    public static func <(lhs: Version, rhs: Version) -> Bool {
        lhs.major < rhs.major
        || lhs.minor ?? 0 < rhs.minor ?? 0
        || lhs.patch ?? 0 < rhs.patch ?? 0
    }
}

extension Version {
    
    init?(string: String) {
        let parsingRegex = Regex {
            Capture { OneOrMore(.digit) }
            Optionally {
                "."
                Capture { OneOrMore(.digit) }
                Optionally {
                    "."
                    Capture { OneOrMore(.digit) }
                }
            }
        }
        
        let regexMatch = try? parsingRegex.firstMatch(in: string)?.output
        
        guard let (_, major, minor, patch) = regexMatch else {
            return nil
        }
        
        guard let integerMajor = Int(major) else {
            return nil
        }
        
        var integerMinor: Int?
        if let minor {
            integerMinor = Int(minor)
        }
        
        var integerPatch: Int?
        if case let patch?? = patch {
            integerPatch = Int(patch)
        }
        
        self.init(major: integerMajor, minor: integerMinor, patch: integerPatch)
    }
}

extension Version: CustomStringConvertible {
    
    public var description: String {
        let minorDescription = if let minor { ".\(minor)" } else { "" }
        let patchDescription = if let patch { ".\(patch)" } else { "" }
        
        return "\(major)\(minorDescription)\(patchDescription)"
    }
    
}
