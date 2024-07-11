//
//  Proposal+Description.swift
//  SwiftEvolutionModel
//
//  Created by Victor Martins on 28/04/24.
//

import Foundation

extension Proposal: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var resultingDescription = [String]()
        func describe(_ propertyName: String, value: Any? = nil) {
            if let value {
                if let values = value as? [CustomDebugStringConvertible] {
                    let separator = "\n│   "+Array(repeating: " ", count: propertyName.count)
                    let valuesDescription = values.map(\.debugDescription).joined(separator: separator)
                    resultingDescription.append("│ \(propertyName): \(valuesDescription)")
                } else {
                    resultingDescription.append("│ \(propertyName): \(value)")
                }
            } else {
                resultingDescription.append(propertyName)
            }
        }
        
        describe("┌── Proposal \(self.id)")
        describe("title", value: title)
        describe("summary", value: summary.truncate(100))
        describe("link", value: link)
        describe("sha", value: sha.truncate(5))
        
        describe("├ ─ ─ ─ ─")
        
        describe("authors", value: authors)
        describe("review managers", value: reviewManagers)
        describe("status", value: status)
        
        describe("├ ─ ─ ─ ─")
        
        describe("discussions", value: discussions)
        
        if let trackingBugs { describe("tracking bugs", value: trackingBugs) }
        if let implementation { describe("implementation", value: implementation) }
        if let previousProposalIDs { describe("previous proposal IDs", value: previousProposalIDs.joined(separator: ", ")) }
        if let upcomingFeatureFlag { describe("upcoming feature flag", value: upcomingFeatureFlag) }
        
        if let warnings {
            describe("├ ─ ─ ─ ─")
            resultingDescription.append("│ ! warning: \(warnings.map(\.debugDescription).joined(separator: "\n│            "))")
        }
        if let errors {
            if warnings == nil { describe("├ ─ ─ ─ ─") }
            resultingDescription.append("│ ! errors: \(errors.map(\.debugDescription).joined(separator: "\n│           "))")
        }
        describe("└────────")
        return resultingDescription.joined(separator: "\n")
    }
}

fileprivate extension String {
    func truncate(_ maxLength: Int) -> String {
        guard self.count > maxLength else {
            return self
        }
        return "\(self.prefix(maxLength))..."
    }
}

extension Proposal.Issue: CustomDebugStringConvertible {
    public var debugDescription: String {
        [kind, code.description, message, suggestion].compactMap{$0.debugDescription}.joined(separator: " | ")
    }
}

extension Proposal.Person: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(self.name) (\(self.link?.description ?? "empty or invalid URL"))"
    }
}

extension Proposal.Implementation: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(self.id) \(self.type) on \(self.account)/\(self.repository)"
    }
}

extension Proposal.Discussion: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(self.name) (\(self.link?.description ?? "empty or invalid URL"))"
    }
}

extension Proposal.TrackingBug: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(self.id) (\(self.link))"
    }
}

extension Proposal.UpcomingFeatureFlag: CustomDebugStringConvertible {
    public var debugDescription: String {
        [
            self.flag,
            self.available.flatMap {"available from: \($0)"},
            self.enabledInLanguageMode.flatMap {"language mode: \($0)"}
        ].compactMap { $0 }.joined(separator: " | ")
    }
}

extension Proposal.Status: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self {
        case .awaitingReview: return "Awaiting Review"
        case .scheduledForReview: return "Scheduled for Review"
        case .activeReview: return "Active Review"
        case .returnedForRevision: return "Returned for Revision"
        case .withdrawn: return "Withdrawn"
        case .accepted: return "Accepted"
        case .acceptedWithRevisions: return "Accepted with Revisions"
        case .rejected: return "Rejected"
        case .implemented: return "Implemented"
        case .previewing: return "Previewing"
        }
    }
    
    public var debugDescription: String {
        if case .activeReview(let reviewPeriod) = self, let reviewPeriod {
            let formattedPeriod = reviewPeriod.formatted(.interval.day().month(.wide))
            return "Active Review \(formattedPeriod)"
        }
        
        return self.description
    }
}
//extension Proposal.Status: CustomDebugStringConvertible {
//    var debugDescription: String {
//        [
//            self.state,
//            self.start.flatMap { "start: \($0)" },
//            self.end.flatMap { "end: \($0)" },
//            self.version.flatMap { "version: \($0)" },
//            self.reason.flatMap { "reason: \($0)" }
//        ].compactMap { $0 }.joined(separator: " | ")
//    }
//}
