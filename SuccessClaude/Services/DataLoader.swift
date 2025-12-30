//
//  DataLoader.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

enum DataLoaderError: Error {
    case fileNotFound(String)
    case invalidJSON(String)
    case decodingError(String)

    var localizedDescription: String {
        switch self {
        case .fileNotFound(let filename):
            return "Data file not found: \(filename)"
        case .invalidJSON(let filename):
            return "Invalid JSON in file: \(filename)"
        case .decodingError(let message):
            return "Failed to decode data: \(message)"
        }
    }
}

class DataLoader {
    static let shared = DataLoader()

    private var occupationsData: BLSOEWSData?
    private var stateData: StateIncomeData?
    private var nationalData: NationalStatisticsData?
    private var metadata: DataMetadata?
    private var automationRiskData: AutomationRiskData?

    private init() {}

    // MARK: - Load All Data

    func loadAllData() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                self.occupationsData = try await self.loadOccupationsData()
            }

            group.addTask {
                self.stateData = try await self.loadStateData()
            }

            group.addTask {
                self.nationalData = try await self.loadNationalData()
            }

            group.addTask {
                self.metadata = try await self.loadMetadata()
            }

            group.addTask {
                self.automationRiskData = try await self.loadAutomationRiskData()
            }

            try await group.waitForAll()
        }
    }

    // MARK: - Individual Loaders

    private func loadOccupationsData() async throws -> BLSOEWSData {
        try await load(filename: "bls_oews_occupations", extension: "json")
    }

    private func loadStateData() async throws -> StateIncomeData {
        try await load(filename: "state_income_data", extension: "json")
    }

    private func loadNationalData() async throws -> NationalStatisticsData {
        try await load(filename: "national_statistics", extension: "json")
    }

    private func loadMetadata() async throws -> DataMetadata {
        let fullData: [String: DataMetadata] = try await load(filename: "metadata", extension: "json")
        guard let metadata = fullData["app_version"] != nil ? try? JSONDecoder().decode(DataMetadata.self, from: JSONEncoder().encode(fullData)) : nil else {
            // If the structure is different, extract from the JSON
            let url = try getFileURL(filename: "metadata", extension: "json")
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let version = json?["data_version"] as? String ?? "1.0.0"
            let lastUpdated = json?["last_updated"] as? String ?? "2024-09-15"
            let sources = json?["sources"] as? [[String: Any]]
            let source = (sources?.first?["full_name"] as? String) ?? "BLS OEWS, Census ACS, MERIC Cost of Living (2024), AI/Automation Risk Data"
            return DataMetadata(version: version, lastUpdated: lastUpdated, source: source)
        }
        return metadata
    }

    private func loadAutomationRiskData() async throws -> AutomationRiskData {
        try await load(filename: "automation_risk_data", extension: "json")
    }

    // MARK: - Generic JSON Loader

    private func load<T: Decodable>(filename: String, extension ext: String) async throws -> T {
        let url = try getFileURL(filename: filename, extension: ext)
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw DataLoaderError.decodingError("\(filename).\(ext): \(error.localizedDescription)")
        }
    }

    private func getFileURL(filename: String, extension ext: String) throws -> URL {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext, subdirectory: "Data/JSON") ??
                        Bundle.main.url(forResource: filename, withExtension: ext) else {
            throw DataLoaderError.fileNotFound("\(filename).\(ext)")
        }
        return url
    }

    // MARK: - Data Accessors

    func getOccupationData(for socCode: String) -> OccupationData? {
        return occupationsData?.occupations.first { $0.socCode == socCode }
    }

    func getStateData(for state: USState) -> StateData? {
        return stateData?.states.first { $0.code == state.rawValue }
    }

    func getNationalData() -> NationalStats? {
        return nationalData?.national
    }

    func getAllOccupations() -> [OccupationData] {
        let allOccupations = occupationsData?.occupations ?? []

        // Filter out aggregate SOC codes (ending in 0) to avoid duplicates
        // Keep only detailed codes (ending in 1-9)
        // Example: 29-1140 is aggregate, 29-1141 is detailed
        return allOccupations.filter { occupation in
            let socCode = occupation.socCode
            // Get the last character of SOC code
            guard let lastChar = socCode.last else { return true }
            // Keep if last digit is not 0
            return lastChar != "0"
        }
    }

    func getAllStates() -> [StateData] {
        return stateData?.states ?? []
    }

    func getDataMetadata() -> DataMetadata? {
        return metadata
    }

    func getAutomationRisk(for socCode: String) -> OccupationRisk? {
        return automationRiskData?.automationRisks.first { $0.socCode == socCode }
    }

    func getAutomationRiskMetadata() -> RiskMetadata? {
        return automationRiskData?.metadata
    }

    // MARK: - Occupation Categories

    func getOccupationCategories() -> [String: [OccupationData]] {
        let all = getAllOccupations()
        return Dictionary(grouping: all) { $0.category }
    }

    func getOccupationsForCategory(_ category: String) -> [OccupationData] {
        return getAllOccupations().filter { $0.category == category }
    }

    // MARK: - Helper for Age Range

    func getAgeRangeKey(for age: Int) -> String {
        switch age {
        case 16...19: return "16-19"
        case 20...24: return "20-24"
        case 25...34: return "25-34"
        case 35...44: return "35-44"
        case 45...54: return "45-54"
        case 55...64: return "55-64"
        default: return "65+"
        }
    }

    // MARK: - Data Status

    var isDataLoaded: Bool {
        return occupationsData != nil && stateData != nil && nationalData != nil
    }
}
