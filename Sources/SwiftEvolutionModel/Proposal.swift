//
//  Proposal.swift
//  SwiftEvolutionModel
//
//  Created by Victor Martins on 28/04/24.
//

import Foundation

public struct Proposal: Codable, Identifiable, Equatable, Hashable, Sendable {
    
    /// SE-NNNN, e.g. "SE-0147"
    public let id: String
    
    public let title: String
    public let summary: String
    public let link: String
    /// SHA of the proposal's Markdown file's latest update
    public let sha: String
    
    public let authors: [Person]
    public let reviewManagers: [Person]
    public let status: Status
    
    /// A list of the related proposal discussions
    public let discussions: [Discussion]
    public let trackingBugs: [TrackingBug]?
    public let implementation: [Implementation]?
    /// IDs of proposals that form a line of succession to this proposal
    public let previousProposalIDs: [String]?
    public let upcomingFeatureFlag: UpcomingFeatureFlag?
    
    public let warnings: [Issue]?
    public let errors: [Issue]?
    
    
    // MARK: Type Declarations
    
    public struct Person: Equatable, Hashable, Sendable {
        public let name: String
        public let link: URL?
        
        public init(name: String, link: URL?) {
            self.name = name
            self.link = link
        }
    }
    
    public enum Status: Equatable, Hashable, Sendable {
        case awaitingReview
        case scheduledForReview
        case activeReview(reviewPeriod: Range<Date>?)
        case returnedForRevision
        case withdrawn
        case accepted
        case acceptedWithRevisions
        case rejected
        case implemented(version: SwiftVersion)
        case previewing
    }
    
    public struct UpcomingFeatureFlag: Codable, Equatable, Hashable, Sendable {
        public var flag: String
        /// Language mode version when feature is always enabled. Omitted when there is no announced language mode
        public var enabledInLanguageMode: String?
        /// Optional field containing the language release version when the flag is available, 
        /// if not the same as the release in which the feature is implemented.
        public var available: String?
    }
    
    public struct Discussion: Equatable, Hashable, Sendable {
        /// "Pitch", "Review", "Acceptance", ...
        public let name: String
        public let link: URL?
        
        public init(name: String, link: URL?) {
            self.name = name
            self.link = link
        }
    }
    
    public struct TrackingBug: Codable, Equatable, Hashable, Sendable {
        let id: String
        let assignee: String
        let link: String
        let radar: String
        let resolution: String
        let status: String
        let title: String
        let updated: String
    }
    
    public struct Implementation: Codable, Equatable, Hashable, Sendable {
        /// "commit" | "pull"
        public var type: String
        public var account: String
        public var repository: String
        public var id: String
    }
    
    public struct Issue: Codable, Equatable, Hashable, Sendable {
        public let kind: String
        /// Human-readable description of what's wrong
        public let message: String
        /// Human-readable description of how to address the issue
        public let suggestion: String
        /// Unique identifier across warnings and errors
        public let code: Int
        
        public init(kind: String, message: String, suggestion: String, code: Int) {
            self.kind = kind
            self.message = message
            self.suggestion = suggestion
            self.code = code
        }
    }
    
    // MARK: Initializer
    
    public init(
        id: String,
        title: String,
        summary: String,
        link: String,
        sha: String,
        authors: [Person],
        reviewManagers: [Person],
        status: Status,
        discussions: [Discussion] = [],
        trackingBugs: [TrackingBug]? = nil,
        implementation: [Implementation]? = nil,
        previousProposalIDs: [String]? = nil,
        upcomingFeatureFlag: UpcomingFeatureFlag? = nil,
        warnings: [Issue]? = nil,
        errors: [Issue]? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.link = link
        self.sha = sha
        self.authors = authors
        self.reviewManagers = reviewManagers
        self.status = status
        self.discussions = discussions
        self.trackingBugs = trackingBugs
        self.implementation = implementation
        self.previousProposalIDs = previousProposalIDs
        self.upcomingFeatureFlag = upcomingFeatureFlag
        self.warnings = warnings
        self.errors = errors
    }
    
    // MARK: Codable Conformance
    
    public enum CodingKeys: Codable, CodingKey {
        case id
        case title
        case summary
        case link
        case sha
        case authors
        case reviewManagers
        case status
        case discussions
        case trackingBugs
        case implementation
        case previousProposalIDs
        case upcomingFeatureFlag
        case warnings
        case errors
    }
}

extension Proposal.Person: Codable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Proposal.Person.CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        // Try to decode the link String as a URL
        let urlString = try container.decodeIfPresent(String.self, forKey: .link)
        self.link = urlString.flatMap { URL(string: $0) } ?? nil
    }
    
}

extension Proposal.Discussion: Codable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Proposal.Discussion.CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        // Try to decode the link String as a URL
        let urlString = try container.decodeIfPresent(String.self, forKey: .link)
        self.link = urlString.flatMap { URL(string: $0) } ?? nil
    }
    
}
