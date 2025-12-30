//
//  StatisticalData.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

// MARK: - BLS OEWS Data Structures

struct BLSOEWSData: Codable {
    let occupations: [OccupationData]
    let metadata: DataMetadata
}

struct OccupationData: Codable, Identifiable {
    let socCode: String
    let title: String
    let category: String
    let nationalMedian: Double
    let nationalMean: Double
    let top10Percent: Double
    let byState: [String: StateOccupationStats]
    let ageDistribution: [String: IncomeStats]

    var id: String { socCode }

    enum CodingKeys: String, CodingKey {
        case socCode = "soc_code"
        case title
        case category
        case nationalMedian = "national_median"
        case nationalMean = "national_mean"
        case top10Percent = "top_10_percent"
        case byState = "by_state"
        case ageDistribution = "age_distribution"
    }
}

struct StateOccupationStats: Codable {
    let median: Double
    let mean: Double
    let employment: Int
}

struct IncomeStats: Codable {
    let median: Double
    let mean: Double
}

// MARK: - State Income Data Structures

struct StateIncomeData: Codable {
    let states: [StateData]
    let metadata: DataMetadata
}

struct StateData: Codable, Identifiable {
    let code: String
    let name: String
    let overall: IncomeStats
    let byAge: [String: IncomeStats]
    let byGender: [String: IncomeStats]
    let byMaritalStatus: [String: IncomeStats]
    let costOfLivingIndex: Double // Index where 100 = US average

    var id: String { code }

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case overall
        case byAge = "by_age"
        case byGender = "by_gender"
        case byMaritalStatus = "by_marital_status"
        case costOfLivingIndex = "cost_of_living_index"
    }
}

// MARK: - National Statistics Data Structures

struct NationalStatisticsData: Codable {
    let national: NationalStats
    let metadata: DataMetadata
}

struct NationalStats: Codable {
    let overall: DetailedIncomeStats
    let byAge: [String: IncomeStats]
    let byGender: [String: IncomeStats]
    let byMaritalStatus: [String: IncomeStats]

    enum CodingKeys: String, CodingKey {
        case overall
        case byAge = "by_age"
        case byGender = "by_gender"
        case byMaritalStatus = "by_marital_status"
    }
}

struct DetailedIncomeStats: Codable {
    let medianHouseholdIncome: Double
    let medianIndividualIncome: Double
    let meanHouseholdIncome: Double
    let top10Percent: Double

    enum CodingKeys: String, CodingKey {
        case medianHouseholdIncome = "median_household_income"
        case medianIndividualIncome = "median_individual_income"
        case meanHouseholdIncome = "mean_household_income"
        case top10Percent = "top_10_percent"
    }
}

// MARK: - Metadata

struct DataMetadata: Codable {
    let version: String
    let lastUpdated: String
    let source: String

    enum CodingKeys: String, CodingKey {
        case version
        case lastUpdated = "last_updated"
        case source
    }
}
