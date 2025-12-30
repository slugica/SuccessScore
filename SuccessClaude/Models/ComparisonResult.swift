//
//  ComparisonResult.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

struct ComparisonResult: Identifiable {
    let id = UUID()
    let category: ComparisonCategory
    let userIncome: Double
    let medianIncome: Double
    let meanIncome: Double
    let top10Threshold: Double
    let percentile: Double
    let percentageDifference: Double
    let sampleSize: Int?
    let perCapitaIncome: Double?
    let householdSize: Int?

    var isAboveMedian: Bool {
        userIncome >= medianIncome
    }

    var isInTop10: Bool {
        userIncome >= top10Threshold
    }

    var hasHouseholdData: Bool {
        guard let size = householdSize else { return false }
        return size > 1
    }

    var categoryTitle: String {
        switch category {
        case .state(let stateName):
            return NSLocalizedString("comparison.state", value: "vs. \(stateName)", comment: "State comparison")
        case .national:
            return NSLocalizedString("comparison.national", value: "vs. National Average", comment: "National comparison")
        case .occupation(let occupationTitle):
            return NSLocalizedString("comparison.occupation", value: "vs. \(occupationTitle)", comment: "Occupation comparison")
        case .peers:
            return NSLocalizedString("comparison.peers", value: "vs. Your Peers", comment: "Peer comparison")
        }
    }

    var categoryDescription: String {
        switch category {
        case .state(let stateName):
            return NSLocalizedString("comparison.state.desc", value: "Compared to all earners in \(stateName)", comment: "State comparison description")
        case .national:
            return NSLocalizedString("comparison.national.desc", value: "Compared to all earners in the United States", comment: "National comparison description")
        case .occupation(let occupationTitle):
            return NSLocalizedString("comparison.occupation.desc", value: "Compared to all \(occupationTitle) nationwide", comment: "Occupation comparison description")
        case .peers:
            if let size = sampleSize {
                return NSLocalizedString("comparison.peers.desc", value: "Compared to \(size) people in your occupation with similar age", comment: "Peer comparison description")
            } else {
                return NSLocalizedString("comparison.peers.desc.general", value: "Compared to people in your occupation with similar age", comment: "Peer comparison description general")
            }
        }
    }
}

enum ComparisonCategory {
    case state(stateName: String)
    case national
    case occupation(occupationTitle: String)
    case peers

    var sortOrder: Int {
        switch self {
        case .state: return 0
        case .national: return 1
        case .occupation: return 2
        case .peers: return 3
        }
    }
}

// MARK: - Additional Statistics Models

struct PathToTop10 {
    let currentIncome: Double
    let top10Threshold: Double
    let category: String
    let gapAmount: Double
    let gapPercentage: Double
    let isAlreadyTop10: Bool

    var progressPercentage: Double {
        guard top10Threshold > 0 else { return 0 }
        return min((currentIncome / top10Threshold) * 100, 100)
    }
}

struct CareerForecast {
    let currentAge: Int
    let userIncome: Double
    let ageGroups: [AgeGroupIncome]
    let peakAge: String
    let peakIncome: Double
}

struct AgeGroupIncome {
    let ageRange: String
    let median: Double
    let mean: Double
}

struct GenderComparison {
    let category: String
    let maleMedian: Double?
    let femaleMedian: Double?
    let userGender: Gender
    let userIncome: Double
    let payGap: Double?

    var hasData: Bool {
        maleMedian != nil && femaleMedian != nil
    }
}

struct StateRanking {
    let occupation: String
    let topStates: [StateIncomeInfo]
    let userStateRank: Int?
    let userState: String
}

struct StateIncomeInfo {
    let stateName: String
    let stateCode: String
    let median: Double
    let rank: Int
}

struct SimilarOccupation {
    let title: String
    let socCode: String
    let median: Double
    let percentageDifference: Double
}

struct FunFacts {
    let nationalRankPercentile: Double
    let occupationEmployment: Int?
    let stateEmployment: Int?
    let occupationRank: Int?
    let totalOccupations: Int
}

struct PurchasingPowerAnalysis {
    let actualIncome: Double
    let adjustedIncome: Double
    let costOfLivingIndex: Double
    let stateName: String
    let nationalMedianAdjusted: Double
    let adjustedPercentile: Double
    let savingsImpact: Double // How much more/less you can save compared to average state

    var costOfLivingDescription: String {
        if costOfLivingIndex < 95 {
            return NSLocalizedString("col.below_average", value: "Below Average Cost", comment: "")
        } else if costOfLivingIndex > 105 {
            return NSLocalizedString("col.above_average", value: "Above Average Cost", comment: "")
        } else {
            return NSLocalizedString("col.average", value: "Average Cost", comment: "")
        }
    }

    var adjustmentPercentage: Double {
        ((adjustedIncome - actualIncome) / actualIncome) * 100
    }
}

struct StatisticsSnapshot {
    let userProfile: UserProfile
    let stateComparison: ComparisonResult
    let nationalComparison: ComparisonResult
    let occupationComparison: ComparisonResult
    let peerComparison: ComparisonResult
    let generatedAt: Date
    let dataSource: String

    // New additional statistics
    let pathToTop10State: PathToTop10?
    let pathToTop10Occupation: PathToTop10?
    let careerForecast: CareerForecast?
    let genderComparison: GenderComparison?
    let stateRanking: StateRanking?
    let similarOccupations: [SimilarOccupation]?
    let funFacts: FunFacts?
    let afterTaxIncome: AfterTaxIncome?
    let purchasingPowerAnalysis: PurchasingPowerAnalysis?

    var allComparisons: [ComparisonResult] {
        [stateComparison, nationalComparison, occupationComparison, peerComparison]
            .sorted { $0.category.sortOrder < $1.category.sortOrder }
    }

    var overallPercentile: Double {
        let percentiles = [
            stateComparison.percentile,
            nationalComparison.percentile,
            occupationComparison.percentile,
            peerComparison.percentile
        ]
        return percentiles.reduce(0, +) / Double(percentiles.count)
    }
}
