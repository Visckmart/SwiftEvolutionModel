//
//  Proposal+Codable.swift
//  SwiftEvolutionMonitor
//
//  Created by Victor Martins on 16/05/23.
//

import Foundation
import SwiftUI

extension Proposal.Status: Codable {
    private static let reviewDateOriginalFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .gmt
        return dateFormatter
    }()
    
    public enum CodingKeys: CodingKey {
        case state
        case version
        case start
        case end
    }
    
    enum StatusDecodingError: LocalizedError {
        case activeReviewWithoutDate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary: [String : String?]
        do {
            dictionary = try container.decode([String: String?].self)
        } catch {
            print(error)
            throw error
        }
        
        switch dictionary["state"] {
        case "awaitingReview": self = .awaitingReview
        case "scheduledForReview": self = .scheduledForReview
        case "activeReview":
            guard case let reviewPeriodStartString?? = dictionary["start"],
                  case let reviewPeriodEndString?? = dictionary["end"] else {
                self = .activeReview(reviewPeriod: nil)
                return
            }
            if let reviewPeriodStart = Self.reviewDateOriginalFormatter.date(from: reviewPeriodStartString),
               let reviewPeriodEnd = Self.reviewDateOriginalFormatter.date(from: reviewPeriodEndString),
               reviewPeriodStart < reviewPeriodEnd {
                self = .activeReview(reviewPeriod: reviewPeriodStart..<reviewPeriodEnd)
            } else if let reviewPeriodStart = ISO8601DateFormatter().date(from: reviewPeriodStartString),
                      let reviewPeriodEnd = ISO8601DateFormatter().date(from: reviewPeriodEndString),
                      reviewPeriodStart < reviewPeriodEnd {
                self = .activeReview(reviewPeriod: reviewPeriodStart..<reviewPeriodEnd)
            } else {
                self = .activeReview(reviewPeriod: nil)
            }
        case "returnedForRevision": self = .returnedForRevision
        case "withdrawn": self = .withdrawn
        case "accepted": self = .accepted
        case "acceptedWithRevisions": self = .acceptedWithRevisions
        case "rejected": self = .rejected
        case "implemented":
            guard let version = dictionary["version"] else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "missing implementation version"
                )
            }
            self = .implemented(version: SwiftVersion(string: version ?? ""))
        case "previewing": self = .previewing
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "state")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Proposal.Status.CodingKeys.self)
        switch self {
        case .awaitingReview:
            try container.encode("awaitingReview", forKey: Proposal.Status.CodingKeys.state)
        case .scheduledForReview:
            try container.encode("scheduledForReview", forKey: Proposal.Status.CodingKeys.state)
        case .activeReview(let reviewPeriod):
            try container.encode("activeReview", forKey: Proposal.Status.CodingKeys.state)
            if let reviewPeriod {
                try container.encode(Self.reviewDateOriginalFormatter.string(from: reviewPeriod.lowerBound),
                                     forKey: Proposal.Status.CodingKeys.start)
                try container.encode(Self.reviewDateOriginalFormatter.string(from: reviewPeriod.upperBound),
                                     forKey: Proposal.Status.CodingKeys.end)
            }
        case .returnedForRevision:
            try container.encode("returnedForRevision", forKey: Proposal.Status.CodingKeys.state)
        case .withdrawn:
            try container.encode("withdrawn", forKey: Proposal.Status.CodingKeys.state)
        case .accepted:
            try container.encode("accepted", forKey: Proposal.Status.CodingKeys.state)
        case .acceptedWithRevisions:
            try container.encode("acceptedWithRevisions", forKey: Proposal.Status.CodingKeys.state)
        case .rejected:
            try container.encode("rejected", forKey: Proposal.Status.CodingKeys.state)
        case .implemented(let version):
            try container.encode("implemented", forKey: Proposal.Status.CodingKeys.state)
            try container.encode(version.versionDescription, forKey: Proposal.Status.CodingKeys.version)
        case .previewing:
            try container.encode("previewing", forKey: Proposal.Status.CodingKeys.state)
        }
    }
}

extension Proposal.Status {
    
    var explanation: String {
        let nbsp = "\u{00a0}"
        return switch self {
        case .awaitingReview:
            "The proposal is awaiting review. Once known, the dates for the actual review will be placed in the proposal document. When the review period begins, the review manager will update the state to Active\(nbsp)review."
        case .scheduledForReview:
            "The public review of the proposal in the Swift forums has been scheduled for the specified date\(nbsp)range."
        case .activeReview(_):
            "The proposal is undergoing public review in the Swift forums. The review will continue through the specified date\(nbsp)range."
        case .returnedForRevision:
            "The proposal has been returned from review for additional revision to the current\(nbsp)draft."
        case .withdrawn:
            "The proposal has been withdrawn by the original\(nbsp)submitter."
        case .accepted:
            "The proposal has been accepted and is either awaiting implementation or is actively being\(nbsp)implemented."
        case .acceptedWithRevisions:
            "The proposal has been accepted, contingent upon the inclusion of one or more\(nbsp)revisions."
        case .rejected:
            "The proposal has been considered and\(nbsp)rejected."
        case .implemented(_):
            "The proposal has been implemented."
        case .previewing:
            "The proposal has been accepted and is available for preview in the Standard Library Preview\(nbsp)package."
        }
    }
}
