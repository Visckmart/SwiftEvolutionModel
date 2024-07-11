import XCTest
import Foundation
@testable import SwiftEvolutionModel

final class SwiftEvolutionModelTests: XCTestCase {
    
    enum DateError: String, Error {
        case invalidDate
    }
    
    lazy var decoder = {
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })
        return decoder
    }()
    
    
    func testBasicFetch() throws {
        let evolutionFile = try fetchEvolutionFile()
        print(evolutionFile)
    }
    
    func testUpcomingFeatureFlagsFetch() throws {
        let evolutionFile = try fetchEvolutionFile()
        printAllUpcomingFeatureFlags(evolutionFile)
    }
    
    func testIssuesFetch() throws {
        let evolutionFile = try fetchEvolutionFile()
        print(evolutionFile)
        printIssues(evolutionFile)
    }
    
    func testIssuesLoad() throws {
        let evolutionFile = try loadEvolutionFile()
        print(evolutionFile)
        printIssues(evolutionFile)
    }
    
    func testTrackingBugsFetch() throws {
        let evolutionFile = try fetchEvolutionFile()
        print(evolutionFile)
        printTrackingBugs(evolutionFile)
    }
    
    func testTrackingBugsLoad() throws {
        let evolutionFile = try loadEvolutionFile()
        print(evolutionFile)
        printTrackingBugs(evolutionFile)
    }
    
    private func loadEvolutionFile() throws -> EvolutionFile {
        let url = Bundle.module.url(forResource: "evolution", withExtension: "json")!
        let data = try String(contentsOf: url).data(using: .utf8)!
        let evolutionFile = try decoder.decode(EvolutionFile.self, from: data)
        return evolutionFile
    }
    
    private func fetchEvolutionFile() throws -> EvolutionFile {
        let url = URL(string: "https://download.swift.org/swift-evolution/v1/evolution.json")!
        let data = try Data(contentsOf: url)
        let evolutionFile = try decoder.decode(EvolutionFile.self, from: data)
        return evolutionFile
    }

    private func printTrackingBugs(_ evolutionFile: EvolutionFile) {
        guard let proposalWithTrackingBugs = evolutionFile.proposals.filter({ $0.trackingBugs?.count ?? 0 > 1 }).randomElement() else {
            print("No proposal tracking bugs")
            return
        }
        print(proposalWithTrackingBugs)
    }

    private func printAllUpcomingFeatureFlags(_ evolutionFile: EvolutionFile) {
        let proposalsUFFs = evolutionFile.proposals.filter({ $0.upcomingFeatureFlag != nil })
        proposalsUFFs.forEach { print($0.id, $0.upcomingFeatureFlag ?? "") }
    }
        
    private func printIssues(_ evolutionFile: EvolutionFile) {
        let warnings = evolutionFile.proposals
            .compactMap { proposal in
                if let warnings = proposal.warnings { warnings.map { (proposal.id, $0) } } else { nil }
            }
            .flatMap { $0 }
        let errors = evolutionFile.proposals
            .compactMap { proposal in
                if let errors = proposal.errors { errors.map { (proposal.id, $0) } } else { nil }
            }
            .flatMap { $0 }
        if warnings.isEmpty == false {
            print("Warnings:")
            for warning in warnings {
                print(warning.0, warning.1)
            }
        } else {
            print("No warnings")
        }
        
        if errors.isEmpty == false {
            print("Errors:")
            for error in errors {
                print(error.0, error.1)
            }
        } else {
            print("No errors")
        }
        
    }
}
