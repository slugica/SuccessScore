//
//  ZIPCodeService.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

struct ZIPCodeData: Codable {
    let zipCodes: [String: ZIPCodeLocation]

    enum CodingKeys: String, CodingKey {
        case zipCodes = "zip_codes"
    }
}

struct ZIPCodeLocation: Codable {
    let city: String
    let state: String
}

class ZIPCodeService {
    static let shared = ZIPCodeService()

    private var zipCodeData: ZIPCodeData?

    private init() {}

    // MARK: - Load Data

    func loadData() async throws {
        let url = try getFileURL(filename: "zip_code_data", extension: "json")
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        zipCodeData = try decoder.decode(ZIPCodeData.self, from: data)
    }

    private func getFileURL(filename: String, extension ext: String) throws -> URL {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext, subdirectory: "Data/JSON") ??
                        Bundle.main.url(forResource: filename, withExtension: ext) else {
            throw DataLoaderError.fileNotFound("\(filename).\(ext)")
        }
        return url
    }

    // MARK: - Lookup

    func lookup(zipCode: String) -> (city: String, state: USState)? {
        guard let location = zipCodeData?.zipCodes[zipCode] else {
            return nil
        }

        // Convert state abbreviation to USState enum
        guard let usState = USState.allCases.first(where: { $0.rawValue == location.state }) else {
            return nil
        }

        return (city: location.city, state: usState)
    }

    // MARK: - Validation

    func isValidZIPCode(_ zipCode: String) -> Bool {
        // Check if it's a 5-digit number
        guard zipCode.count == 5,
              zipCode.allSatisfy({ $0.isNumber }) else {
            return false
        }

        // Check if it exists in our database
        return zipCodeData?.zipCodes[zipCode] != nil
    }

    var isDataLoaded: Bool {
        return zipCodeData != nil
    }
}
