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

    // SOC code mapping (UK → US, NOC → SOC, ANZSCO → SOC, KldB → SOC, FAP → SOC, CNO → SOC, etc.)
    private var ukToUSSocMapping: SOCMapping?
    private var nocToSocMapping: SOCMapping?
    private var anzscoToSocMapping: SOCMapping?
    private var kldbToSocMapping: SOCMapping?
    private var fapToSocMapping: SOCMapping?
    private var cnoToSocMapping: SOCMapping?

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

        // Load SOC mapping
        try await loadSOCMapping()

        // Always load US data first (needed for automation risk for all countries)
        if currentCountryCode != "us" {
            try await loadCountryData(countryCode: "us")
        }

        // Load data for current country
        try await loadCountryData(countryCode: currentCountryCode)
    }

    func loadCountryData(countryCode: String) async throws {
        print("📦 loadCountryData called for: \(countryCode)")

        // Create empty dataset
        var dataSet = CountryDataSet()

        // Load data sequentially - continue even if some fail
        do {
            dataSet.occupationsData = try await loadOccupationsData(countryCode: countryCode)
        } catch {
            print("⚠️ Failed to load occupations: \(error)")
        }

        do {
            dataSet.regionData = try await loadRegionData(countryCode: countryCode)
        } catch {
            print("⚠️ Failed to load regions: \(error)")
        }

        do {
            dataSet.nationalData = try await loadNationalData(countryCode: countryCode)
        } catch {
            print("⚠️ Failed to load national data: \(error)")
        }

        // Load automation risk data for US (used universally for all countries)
        if countryCode == "us" {
            do {
                dataSet.automationRiskData = try await loadAutomationRiskData(countryCode: countryCode)
            } catch {
                print("⚠️ Failed to load automation risk data: \(error)")
            }
        } else {
            // For non-US countries, ensure US automation data is loaded
            if countryDataSets["us"]?.automationRiskData == nil {
                do {
                    let usAutomationData = try await loadAutomationRiskData(countryCode: "us")
                    if var usDataSet = countryDataSets["us"] {
                        usDataSet.automationRiskData = usAutomationData
                        countryDataSets["us"] = usDataSet
                    } else {
                        countryDataSets["us"] = CountryDataSet(automationRiskData: usAutomationData)
                    }
                    print("✅ Loaded US automation data for non-US country")
                } catch {
                    print("⚠️ Failed to load US automation risk data: \(error)")
                }
            }
        }

        // Store the dataset even if some data failed to load
        countryDataSets[countryCode] = dataSet
        print("✅ loadCountryData completed for: \(countryCode)")
    }

    func loadCountriesMetadata() async throws {
        countriesMetadata = try await load(filename: "countries_metadata", extension: "json", subdirectory: nil)
    }

    func loadSOCMapping() async throws {
        // Load UK → US SOC mapping
        ukToUSSocMapping = try await load(filename: "uk_to_us_soc_mapping", extension: "json", subdirectory: nil)
        print("🗺️ UK→US SOC mapping loaded: \(ukToUSSocMapping?.mappings.count ?? 0) mappings")

        // Load NOC → SOC mapping for Canada
        nocToSocMapping = try await load(filename: "noc_to_soc_mapping", extension: "json", subdirectory: nil)
        print("🗺️ NOC→SOC mapping loaded: \(nocToSocMapping?.mappings.count ?? 0) mappings")

        // Load ANZSCO → SOC mapping for Australia
        anzscoToSocMapping = try await load(filename: "anzsco_to_soc_mapping", extension: "json", subdirectory: nil)
        print("🗺️ ANZSCO→SOC mapping loaded: \(anzscoToSocMapping?.mappings.count ?? 0) mappings")

        // Load KldB → SOC mapping for Germany
        kldbToSocMapping = try await load(filename: "kldb_to_soc_mapping", extension: "json", subdirectory: nil)
        print("🗺️ KldB→SOC mapping loaded: \(kldbToSocMapping?.mappings.count ?? 0) mappings")

        // Load FAP → SOC mapping for France
        fapToSocMapping = try await load(filename: "fap_to_soc_mapping", extension: "json", subdirectory: nil)
        print("🗺️ FAP→SOC mapping loaded: \(fapToSocMapping?.mappings.count ?? 0) mappings")

        // Load CNO → SOC mapping for Spain
        cnoToSocMapping = try await load(filename: "cno_to_soc_mapping", extension: "json", subdirectory: nil)
        print("🗺️ CNO→SOC mapping loaded: \(cnoToSocMapping?.mappings.count ?? 0) mappings")
    }

    // MARK: - Individual Loaders (Country-specific)

    private func loadOccupationsData(countryCode: String) async throws -> BLSOEWSData {
        let filename: String
        switch countryCode {
        case "us":
            filename = "\(countryCode)_bls_oews_occupations"
        case "uk":
            filename = "\(countryCode)_occupations_full"
        default:
            filename = "\(countryCode)_occupations"
        }
        print("🔍 Loading occupations: \(filename).json for country: \(countryCode)")
        let data = try await load(filename: filename, extension: "json", subdirectory: countryCode) as BLSOEWSData
        print("✅ Loaded \(data.occupations.count) occupations for \(countryCode)")
        return data
    }

    private func loadRegionData(countryCode: String) async throws -> RegionIncomeData {
        let filename = "\(countryCode)_" + (countryCode == "us" ? "state_income_data" : "regions")
        return try await load(filename: filename, extension: "json", subdirectory: countryCode)
    }

    private func loadNationalData(countryCode: String) async throws -> NationalStatisticsData {
        try await load(filename: "\(countryCode)_national_statistics", extension: "json", subdirectory: countryCode)
    }

    private func loadAutomationRiskData(countryCode: String) async throws -> AutomationRiskData {
        try await load(filename: "\(countryCode)_automation_risk_data", extension: "json", subdirectory: countryCode)
    }

    // MARK: - Generic JSON Loader

    private func load<T: Decodable>(filename: String, extension ext: String, subdirectory: String?) async throws -> T {
        let url = try getFileURL(filename: filename, extension: ext, subdirectory: subdirectory)
        let data = try Data(contentsOf: url)
        print("📊 Loaded file size: \(data.count) bytes from \(url.lastPathComponent)")

        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch {
            throw DataLoaderError.decodingError("\(filename).\(ext): \(error.localizedDescription)")
        }
    }

    private func getFileURL(filename: String, extension ext: String, subdirectory: String? = nil) throws -> URL {
        print("🔍 Searching for file: \(filename).\(ext) in subdirectory: \(subdirectory ?? "none")")

        // Debug: List all JSON files in bundle
        if let bundlePath = Bundle.main.resourcePath {
            print("📦 Bundle path: \(bundlePath)")
            if let files = try? FileManager.default.contentsOfDirectory(atPath: bundlePath) {
                let jsonFiles = files.filter { $0.hasSuffix(".json") }
                print("📄 JSON files in bundle: \(jsonFiles.count) files")
                for file in jsonFiles.prefix(5) {
                    print("   - \(file)")
                }
            }
        }

        // Try to find file directly in bundle first (Xcode flattens folder structure)
        if let url = Bundle.main.url(forResource: filename, withExtension: ext) {
            print("✅ Found file at: \(url.lastPathComponent)")
            return url
        } else {
            print("❌ NOT found in bundle root: \(filename).\(ext)")
        }

        // Fallback: try with subdirectory path
        if let subdirectory = subdirectory {
            let searchPath = "Data/JSON/\(subdirectory)"
            if let url = Bundle.main.url(forResource: filename, withExtension: ext, subdirectory: searchPath) {
                print("✅ Found file at: \(url.lastPathComponent) in \(searchPath)")
                return url
            }
        }

        // Last fallback: try Data/JSON directory
        if let url = Bundle.main.url(forResource: filename, withExtension: ext, subdirectory: "Data/JSON") {
            print("✅ Found file at: \(url.lastPathComponent) in Data/JSON")
            return url
        }

        print("❌ File NOT FOUND: \(filename).\(ext)")
        throw DataLoaderError.fileNotFound("\(filename).\(ext)")
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
        print("🤖 Looking for automation risk: SOC=\(socCode), country=\(country)")

        // For non-US countries: use US automation data with appropriate SOC mapping
        var targetSOCCode = socCode
        var searchCountry = country

        if country != "us" {
            // Select appropriate mapping based on country
            let mapping: SOCMapping?
            switch country {
            case "uk":
                mapping = ukToUSSocMapping
            case "ca":
                mapping = nocToSocMapping
            case "au", "nz":
                // Both Australia and New Zealand use ANZSCO classification
                mapping = anzscoToSocMapping
            case "de":
                // Germany uses KldB 2010 classification
                mapping = kldbToSocMapping
            case "fr":
                // France uses FAP 2009 classification
                mapping = fapToSocMapping
            case "es":
                // Spain uses CNO-11 classification
                mapping = cnoToSocMapping
            default:
                mapping = nil
            }

            // Try to map to US SOC code
            if let mappedCode = mapping?.mappings[socCode] {
                targetSOCCode = mappedCode
                searchCountry = "us"
                print("🗺️ Mapped \(country) code \(socCode) → US SOC \(mappedCode)")
            } else {
                print("⚠️ No mapping found for \(country) code: \(socCode)")
                return nil
            }
        }

        // Get automation data (always use US data for risk assessment)
        guard let automationData = countryDataSets["us"]?.automationRiskData else {
            print("⚠️ No US automation data loaded")
            return nil
        }

        // Find exact match in US data
        if let match = automationData.automationRisks.first(where: { $0.socCode == targetSOCCode }) {
            print("✅ Found automation risk for \(targetSOCCode): \(match.overallRisk)%")
            return match
        }

        print("❌ No automation risk found for SOC code: \(targetSOCCode)")
        return nil
    }

    func getAutomationRiskMetadata(countryCode: String? = nil) -> RiskMetadata? {
        // Always return US metadata since we use US automation data for all countries
        return countryDataSets["us"]?.automationRiskData?.metadata
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
        switch country {
        case "uk":
            switch age {
            case 18...21: return "18-21"
            case 22...29: return "22-29"
            case 30...39: return "30-39"
            case 40...49: return "40-49"
            case 50...59: return "50-59"
            default: return "60+"
            }
        case "ca", "au":
            // Canada and Australia use the same age groupings
            switch age {
            case 18...24: return "18-24"
            case 25...34: return "25-34"
            case 35...44: return "35-44"
            case 45...54: return "45-54"
            case 55...64: return "55-64"
            default: return "65+"
            }
        case "fr", "es":
            // France and Spain use similar age groupings
            switch age {
            case 18...24: return "18-24"
            case 25...34: return "25-34"
            case 35...44: return "35-44"
            case 45...54: return "45-54"
            case 55...64: return "55-64"
            default: return "65+"
            }
        default: // US
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
