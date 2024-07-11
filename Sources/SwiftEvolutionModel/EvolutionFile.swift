//
//  Proposal.swift
//  SwiftEvolutionModel
//
//  Created by Victor Martins on 28/04/24.
//

import Foundation

public struct EvolutionFile {
    
    /// The `swift-evolution` repository commit hash used to generate the metadata.
    public let commit: String
    /// An ISO 8601 date of when the metadata was generated.
    public let creationDate: Date
    /// The version of the schema used in the file.
    public let schemaVersion: String
    /// The version of the extraction tool that created the file.
    public let toolVersion: String
    
    /// An array containing a uniqued list of versions found in proposals with “Implemented” status, sorted from lowest to highest version.
    public let implementationVersions: [String]
    
    public let proposals: [Proposal]
    public let undecodableProposals: [String]
    
}

extension EvolutionFile: Codable {
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commit = try container.decode(String.self, forKey: .commit)
        self.creationDate = try container.decode(Date.self, forKey: .creationDate)
        self.schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        self.toolVersion = try container.decode(String.self, forKey: .toolVersion)
        self.implementationVersions = try container.decode([String].self, forKey: .implementationVersions)
        
        let decodedProposalResults = try container.decode([ProposalDecodableGuard].self, forKey: .proposals)
        self.proposals = decodedProposalResults.compactMap(\.value)
        self.undecodableProposals = decodedProposalResults.filter { $0.value == nil }.map { $0.id ?? "unknown" }
    }
    
    private struct ProposalDecodableGuard: Decodable {
        let value: Proposal?
        let id: String?
        
        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                self.value = try container.decode(Proposal.self)
                self.id = nil
            } catch {
                self.value = nil
                self.id = try? decoder.container(keyedBy: IDCodingKeys.self).decodeIfPresent(String.self, forKey: .id)
            }
        }
        
        private enum IDCodingKeys: CodingKey {
            case id
        }
    }
}

extension EvolutionFile: CustomDebugStringConvertible {
    public var debugDescription: String {
        var resultingDescription = [String]()
        resultingDescription.append("┌── Evolution File")
        resultingDescription.append("│ commit: \(commit.debugDescription)")
        resultingDescription.append("│ creationDate: \(creationDate.formatted())")
        resultingDescription.append("│ schema version: \(schemaVersion.debugDescription)")
        resultingDescription.append("│ tool version: \(toolVersion.debugDescription)")
        resultingDescription.append("├ ─ ─ ─ ─ ─ ─ ─ ─")
        let groupedVersions = Dictionary(grouping: implementationVersions, by: \.first)
            .values
            .map { $0
                .compactMap { Version(string: $0)?.description }
                .joined(separator: " ")
            }
            .sorted()
            .joined(separator: "\n│                          ")
        resultingDescription.append("│ implementation versions: \(groupedVersions)")
        resultingDescription.append("├ ─ ─ ─ ─ ─ ─ ─ ─")
        resultingDescription.append("│ proposals: \(proposals.count) (\(proposals.first?.id.debugDescription ?? "") – \(proposals.last?.id.debugDescription ?? ""))")
        resultingDescription.append("│ undecodable proposals: \(undecodableProposals.count) \(undecodableProposals.joined(separator: "\n|                          "))")
        resultingDescription.append("└────────")
        return resultingDescription.joined(separator: "\n")
    }
}
