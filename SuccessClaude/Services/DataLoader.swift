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

// MARK: - Country-specific Data Container

struct CountryDataSet {
    var occupationsData: BLSOEWSData?
    var regionData: RegionIncomeData?
    var nationalData: NationalStatisticsData?
    var automationRiskData: AutomationRiskData?
}

class DataLoader {
    static let shared = DataLoader()

    // Multi-country support
    private var countriesMetadata: CountriesMetadata?
    private var countryDataSets: [String: CountryDataSet] = [:]
    private var currentCountryCode: String = "us"

    // Legacy properties for backward compatibility
    private var occupationsData: BLSOEWSData? {
        countryDataSets[currentCountryCode]?.occupationsData
    }
    private var stateData: StateIncomeData? {
        countryDataSets[currentCountryCode]?.regionData
    }
    private var nationalData: NationalStatisticsData? {
        countryDataSets[currentCountryCode]?.nationalData
    }
    private var automationRiskData: AutomationRiskData? {
        countryDataSets[currentCountryCode]?.automationRiskData
    }
    private var metadata: DataMetadata? {
        countryDataSets[currentCountryCode]?.occupationsData?.metadata
    }

    private init() {}

    // MARK: - Country Management

    func setCurrentCountry(_ countryCode: String) {
        currentCountryCode = countryCode
    }

    func getCurrentCountry() -> String {
        currentCountryCode
    }

    func getAvailableCountries() -> [Country] {
        countriesMetadata?.countries.filter { $0.isActive } ?? []
    }

    // MARK: - Load All Data

    func loadAllData() async throws {
        // Load countries metadata first
        try await loadCountriesMetadata()

        // Load data for current country
        try await loadCountryData(countryCode: currentCountryCode)
    }

    func loadCountryData(countryCode: String) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            var dataSet = CountryDataSet()

            group.addTask {
                dataSet.occupationsData = try await self.loadOccupationsData(countryCode: countryCode)
            }

            group.addTask {
                dataSet.regionData = try await self.loadRegionData(countryCode: countryCode)
            }

            group.addTask {
                dataSet.nationalData = try await self.loadNationalData(countryCode: countryCode)
            }

            group.addTask {
                dataSet.automationRiskData = try await self.loadAutomationRiskData(countryCode: countryCode)
            }

            try await group.waitForAll()

            countryDataSets[countryCode] = dataSet
        }
    }

    private func loadCountriesMetadata() async throws {
        countriesMetadata = try await load(filename: "countries_metadata", extension: "json", subdirectory: nil)
    }

    // MARK: - Individual Loaders (Country-specific)

    private func loadOccupationsData(countryCode: String) async throws -> BLSOEWSData {
        let filename = countryCode == "us" ? "bls_oews_occupations" : "occupations"
        return try await load(filename: filename, extension: "json", subdirectory: countryCode)
    }

    private func loadRegionData(countryCode: String) async throws -> RegionIncomeData {
        let filename = countryCode == "us" ? "state_income_data" : "regions"
        return try await load(filename: filename, extension: "json", subdirectory: countryCode)
    }

    private func loadNationalData(countryCode: String) async throws -> NationalStatisticsData {
        try await load(filename: "national_statistics", extension: "json", subdirectory: countryCode)
    }

    private func loadAutomationRiskData(countryCode: String) async throws -> AutomationRiskData {
        try await load(filename: "automation_risk_data", extension: "json", subdirectory: countryCode)
    }

    // MARK: - Generic JSON Loader

    private func load<T: Decodable>(filename: String, extension ext: String, subdirectory: String?) async throws -> T {
        let url = try getFileURL(filename: filename, extension: ext, subdirectory: subdirectory)
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw DataLoaderError.decodingError("\(filename).\(ext): \(error.localizedDescription)")
        }
    }

    private func getFileURL(filename: String, extension ext: String, subdirectory: String? = nil) throws -> URL {
        var searchPath: String
        if let subdirectory = subdirectory {
            searchPath = "Data/JSON/\(subdirectory)"
        } else {
            searchPath = "Data/JSON"
        }

        guard let url = Bundle.main.url(forResource: filename, withExtension: ext, subdirectory: searchPath) ??
                        Bundle.main.url(forResource: filename, withExtension: ext) else {
            throw DataLoaderError.fileNotFound("\(filename).\(ext) in \(searchPath)")
        }
        return url
    }

    // MARK: - Data Accessors (Country-aware)

    func getOccupationData(for socCode: String, countryCode: String? = nil) -> OccupationData? {
        let country = countryCode ?? currentCountryCode
        return countryDataSets[country]?.occupationsData?.occupations.first { $0.socCode == socCode }
    }

    func getRegionData(for regionCode: String, countryCode: String? = nil) -> RegionData? {
        let country = countryCode ?? currentCountryCode
        return countryDataSets[country]?.regionData?.regions.first { $0.code == regionCode }
    }

    func getStateData(for state: USState) -> StateData? {
        return getRegionData(for: state.rawValue, countryCode: "us")
    }

    func getNationalData(countryCode: String? = nil) -> NationalStats? {
        let country = countryCode ?? currentCountryCode
        return countryDataSets[country]?.nationalData?.national
    }

    func getAllOccupations(countryCode: String? = nil) -> [OccupationData] {
        let country = countryCode ?? currentCountryCode
        let allOccupations = countryDataSets[country]?.occupationsData?.occupations ?? []

        // For US, filter out aggregate SOC codes (ending in 0)
        if country == "us" {
            return allOccupations.filter { occupation in
                let socCode = occupation.socCode
                guard let lastChar = socCode.last else { return true }
                return lastChar != "0"
            }
        }

        // For other countries, return all occupations
        return allOccupations
    }

    func getAllRegions(countryCode: String? = nil) -> [RegionData] {
        let country = countryCode ?? currentCountryCode
        return countryDataSets[country]?.regionData?.regions ?? []
    }

    func getAllStates() -> [StateData] {
        return getAllRegions(countryCode: "us")
    }

    func getDataMetadata() -> DataMetadata? {
        return metadata
    }

    func getAutomationRisk(for socCode: String, countryCode: String? = nil) -> OccupationRisk? {
        let country = countryCode ?? currentCountryCode
        return countryDataSets[country]?.automationRiskData?.automationRisks.first { $0.socCode == socCode }
    }

    func getAutomationRiskMetadata(countryCode: String? = nil) -> RiskMetadata? {
        let country = countryCode ?? currentCountryCode
        return countryDataSets[country]?.automationRiskData?.metadata
    }

    // MARK: - Occupation Categories

    func getOccupationCategories(countryCode: String? = nil) -> [String: [OccupationData]] {
        let all = getAllOccupations(countryCode: countryCode)
        return Dictionary(grouping: all) { $0.category }
    }

    func getOccupationsForCategory(_ category: String, countryCode: String? = nil) -> [OccupationData] {
        return getAllOccupations(countryCode: countryCode).filter { $0.category == category }
    }

    // MARK: - Helper for Age Range

    func getAgeRangeKey(for age: Int, countryCode: String? = nil) -> String {
        let country = countryCode ?? currentCountryCode

        // Different age groupings per country
        if country == "uk" {
            switch age {
            case 18...21: return "18-21"
            case 22...29: return "22-29"
            case 30...39: return "30-39"
            case 40...49: return "40-49"
            case 50...59: return "50-59"
            default: return "60+"
            }
        } else { // US
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
    }

    // MARK: - Data Status

    var isDataLoaded: Bool {
        return occupationsData != nil && stateData != nil && nationalData != nil
    }

    func isCountryDataLoaded(_ countryCode: String) -> Bool {
        guard let dataSet = countryDataSets[countryCode] else { return false }
        return dataSet.occupationsData != nil &&
               dataSet.regionData != nil &&
               dataSet.nationalData != nil
    }
}
