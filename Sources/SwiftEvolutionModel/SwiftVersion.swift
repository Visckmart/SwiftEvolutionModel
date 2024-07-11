//
//  File.swift
//  
//
//  Created by Victor Martins on 30/04/24.
//

import Foundation

public enum SwiftVersion: Sendable, Equatable, Hashable, Codable {
    
    case unknown
    case specific(Version)
    case next
    
    public init(string: String) {
        if let specificVersion = Version(string: string) {
            self = .specific(specificVersion)
            return
        }
        
        if string.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveContains("Next") {
            self = .next
            return
        }
        
        self = .unknown
    }
    
    public var versionDescription: String? {
        let nbsp = "\u{00a0}"
        switch self {
        case .unknown: return nil
        case .specific(let version): return "Swift\(nbsp)\(version.description)"
        case .next: return "Swift\(nbsp)Next"
        }
    }
}

extension SwiftVersion: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { self.versionDescription ?? "unknown" }
    public var debugDescription: String { self.versionDescription ?? "unknown" }
}

extension SwiftVersion: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)
    }
}
