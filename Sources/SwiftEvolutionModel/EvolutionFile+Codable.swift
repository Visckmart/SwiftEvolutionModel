//
//  EvolutionFile+Codable.swift
//
//
//  Created by Victor Martins on 24/06/24.
//

import Foundation

extension EvolutionFile {
    
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
    
    public static func decode(fromData data: Data) throws -> Self {
        enum DateError: String, Error {
            case invalidDate
        }
        let decoder = {
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
        return try decoder.decode(Self.self, from: data)
    }
}
