//
//  StatisticsCalculator.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

class StatisticsCalculator {
    private let dataLoader: DataLoader

    init(dataLoader: DataLoader = .shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - Main Calculation Method

    func generateStatisticsSnapshot(for profile: UserProfile) async throws -> StatisticsSnapshot {
        print("📊 generateStatisticsSnapshot START for country: \(profile.countryCode), region: \(profile.region.code)")

        if !dataLoader.isDataLoaded {
            try await dataLoader.loadAllData()
        }

        print("📊 Generating comparisons...")
        // Generate all comparisons in parallel
        async let stateComparison = generateStateComparison(for: profile)
        async let nationalComparison = generateNationalComparison(for: profile)
        async let occupationComparison = generateOccupationComparison(for: profile)
        async let peerComparison = generatePeerComparison(for: profile)

        // Generate additional statistics
        async let pathToTop10State = calculatePathToTop10State(for: profile)
        async let pathToTop10Occupation = calculatePathToTop10Occupation(for: profile)
        async let careerForecast = calculateCareerForecast(for: profile)
        async let genderComparison = calculateGenderComparison(for: profile)
        async let stateRanking = calculateStateRanking(for: profile)
        async let similarOccupations = calculateSimilarOccupations(for: profile)
        async let funFacts = calculateFunFacts(for: profile)
        let afterTaxIncome = calculateAfterTaxIncome(for: profile)
        async let purchasingPowerAnalysis = calculatePurchasingPowerAnalysis(for: profile)

        let dataSource = dataLoader.getDataMetadata()?.source ?? "BLS OEWS, Census ACS, MERIC Cost of Living (2024), AI/Automation Risk Data"

        return StatisticsSnapshot(
            userProfile: profile,
            stateComparison: try await stateComparison,
            nationalComparison: try await nationalComparison,
            occupationComparison: try await occupationComparison,
            peerComparison: try await peerComparison,
            generatedAt: Date(),
            dataSource: dataSource,
            pathToTop10State: try? await pathToTop10State,
            pathToTop10Occupation: try? await pathToTop10Occupation,
            careerForecast: try? await careerForecast,
            genderComparison: try? await genderComparison,
            stateRanking: try? await stateRanking,
            similarOccupations: try? await similarOccupations,
            funFacts: try? await funFacts,
            afterTaxIncome: afterTaxIncome,
            purchasingPowerAnalysis: try? await purchasingPowerAnalysis
        )
    }

    // MARK: - Individual Comparisons

    private func generateStateComparison(for profile: UserProfile) async throws -> ComparisonResult {
        print("📊 generateStateComparison for region: \(profile.region.code), country: \(profile.countryCode)")
        guard let regionData = dataLoader.getRegionData(for: profile.region.code, countryCode: profile.countryCode) else {
            print("❌ Region data not found for: \(profile.region.code), country: \(profile.countryCode)")
            throw StatisticsError.dataNotAvailable("Region data not available")
        }
        print("✅ Region data found for: \(profile.region.code)")

        let ageRange = dataLoader.getAgeRangeKey(for: profile.age, countryCode: profile.countryCode)
        let maritalKey = profile.maritalStatus.rawValue

            // Get the most specific data available - prioritize marital status for household comparisons
        let stats: IncomeStats
        if let maritalStats = regionData.byMaritalStatus?[maritalKey] {
            // Use marital status specific data (better for household income comparisons)
            stats = maritalStats
        } else {
            // Use overall region data for single/divorced/widowed
            stats = regionData.overall.asIncomeStats
        }

        // Use comparisonIncome for fair household comparison (uses equivalised income for AU)
        let income = profile.comparisonIncome
        let percentile = calculatePercentile(income: income, median: stats.median, mean: stats.mean)
        let percentageDiff = ((income - stats.median) / stats.median) * 100

        return ComparisonResult(
            category: .state(stateName: profile.region.name),
            userIncome: income,
            medianIncome: stats.median,
            meanIncome: stats.mean,
            top10Threshold: regionData.overall.top10Percent ?? (stats.mean * 1.8),
            percentile: percentile,
            percentageDifference: percentageDiff,
            sampleSize: nil,
            perCapitaIncome: profile.perCapitaIncome,
            householdSize: profile.householdSize,
            countryCode: profile.countryCode
        )
    }

    private func generateNationalComparison(for profile: UserProfile) async throws -> ComparisonResult {
        print("📊 generateNationalComparison for country: \(profile.countryCode)")
        guard let nationalStats = dataLoader.getNationalData(countryCode: profile.countryCode) else {
            print("❌ National data not found for country: \(profile.countryCode)")
            throw StatisticsError.dataNotAvailable("National data not available")
        }
        print("✅ National data found for country: \(profile.countryCode)")

        // Use overall national statistics for "vs National" comparison
        // This provides an accurate comparison "vs all earners"
        // (marital-specific comparison is done in state/region comparison)

        // For mean: Use explicit meanIndividualIncome if available
        // Otherwise check if household and individual medians are similar
        // If so, the data is already individual-level (e.g., Canada)
        // Otherwise, estimate individual mean from household mean
        let estimatedMean: Double
        if let meanIndividual = nationalStats.overall.meanIndividualIncome {
            // Use explicit individual mean if available
            estimatedMean = meanIndividual
        } else {
            let householdMedian = nationalStats.overall.medianHouseholdIncome
            let individualMedian = nationalStats.overall.medianIndividualIncome
            let isIndividualData = abs(householdMedian - individualMedian) / max(householdMedian, 1) < 0.1

            if isIndividualData {
                // Data is already individual-level, use as-is
                estimatedMean = nationalStats.overall.meanHouseholdIncome
            } else {
                // Estimate individual mean from household mean
                estimatedMean = nationalStats.overall.meanHouseholdIncome / 2.5
            }
        }

        let stats = IncomeStats(
            median: nationalStats.overall.medianIndividualIncome,
            mean: estimatedMean
        )

        // Use personal income for national comparison (comparing individual earnings)
        let income = profile.annualIncome
        let percentile = calculatePercentile(income: income, median: stats.median, mean: stats.mean)
        let percentageDiff = ((income - stats.median) / stats.median) * 100

        return ComparisonResult(
            category: .national,
            userIncome: income,
            medianIncome: stats.median,
            meanIncome: stats.mean,
            top10Threshold: nationalStats.overall.top10Percent,
            percentile: percentile,
            percentageDifference: percentageDiff,
            sampleSize: nil,
            perCapitaIncome: profile.perCapitaIncome,
            householdSize: profile.householdSize,
            countryCode: profile.countryCode
        )
    }

    private func generateOccupationComparison(for profile: UserProfile) async throws -> ComparisonResult {
        print("📊 generateOccupationComparison for socCode: \(profile.occupation.socCode), country: \(profile.countryCode)")
        guard let occupationData = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode) else {
            print("❌ Occupation data not found for socCode: \(profile.occupation.socCode), country: \(profile.countryCode)")
            throw StatisticsError.dataNotAvailable("Occupation data not available")
        }
        print("✅ Occupation data found: \(occupationData.title)")

        let income = profile.annualIncome
        let percentile = calculatePercentile(
            income: income,
            median: occupationData.nationalMedian,
            mean: occupationData.nationalMean
        )
        let percentageDiff = ((income - occupationData.nationalMedian) / occupationData.nationalMedian) * 100

        return ComparisonResult(
            category: .occupation(occupationTitle: occupationData.title),
            userIncome: income,
            medianIncome: occupationData.nationalMedian,
            meanIncome: occupationData.nationalMean,
            top10Threshold: occupationData.top10Percent,
            percentile: percentile,
            percentageDifference: percentageDiff,
            sampleSize: nil,
            perCapitaIncome: nil,  // Don't show household metrics for occupation comparison
            householdSize: nil,
            countryCode: profile.countryCode
        )
    }

    private func generatePeerComparison(for profile: UserProfile) async throws -> ComparisonResult {
        print("📊 generatePeerComparison for socCode: \(profile.occupation.socCode), country: \(profile.countryCode)")
        guard let occupationData = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode) else {
            print("❌ Peer comparison - Occupation data not found for socCode: \(profile.occupation.socCode), country: \(profile.countryCode)")
            throw StatisticsError.dataNotAvailable("Occupation data not available")
        }
        print("✅ Peer comparison - Occupation data found: \(occupationData.title)")

        let ageRange = dataLoader.getAgeRangeKey(for: profile.age, countryCode: profile.countryCode)

        // Get peer stats (same occupation + similar age)
        let stats: IncomeStats
        if let ageStats = occupationData.ageDistribution[ageRange] {
            stats = ageStats
        } else {
            // Fallback to national occupation stats
            stats = IncomeStats(median: occupationData.nationalMedian, mean: occupationData.nationalMean)
        }

        // Try to get region-specific peer data
        let regionSpecificStats: IncomeStats?
        if let regionOccStats = occupationData.byState[profile.region.code] {
            regionSpecificStats = IncomeStats(median: regionOccStats.median, mean: regionOccStats.mean)
        } else {
            regionSpecificStats = nil
        }

        // Use region-specific if available, otherwise use age-based peer stats
        let finalStats = regionSpecificStats ?? stats

        let income = profile.annualIncome
        let percentile = calculatePercentile(
            income: income,
            median: finalStats.median,
            mean: finalStats.mean
        )
        let percentageDiff = ((income - finalStats.median) / finalStats.median) * 100

        // Estimate sample size (rough approximation)
        let sampleSize: Int?
        if let regionOccStats = occupationData.byState[profile.region.code] {
            sampleSize = regionOccStats.employment / 5 // Assume 1/5 are in similar age range
        } else {
            sampleSize = nil
        }

        return ComparisonResult(
            category: .peers,
            userIncome: income,
            medianIncome: finalStats.median,
            meanIncome: finalStats.mean,
            top10Threshold: finalStats.mean * 1.8,
            percentile: percentile,
            percentageDifference: percentageDiff,
            sampleSize: sampleSize,
            perCapitaIncome: nil,  // Don't show household metrics for peer comparison
            householdSize: nil,
            countryCode: profile.countryCode
        )
    }

    // MARK: - Percentile Calculation

    func calculatePercentile(income: Double, median: Double, mean: Double) -> Double {
        // Using a normal distribution approximation
        // This is a simplified model; real data would use actual distribution

        if income <= 0 {
            return 0
        }

        if income < median {
            // Below median: map 0 to median as 0 to 50th percentile
            let ratio = income / median
            return ratio * 50.0
        } else {
            // Above median: use exponential curve to map median+ to 50-100th percentile
            // At median: 50%, at mean: ~58%, at 2x median: ~84%, at 3x median: ~95%

            if income >= mean * 3 {
                return min(99.5, 95 + (income - mean * 3) / (mean * 10) * 4.5)
            } else if income >= mean * 2 {
                return 84 + (income - mean * 2) / mean * 11.0
            } else if income >= mean {
                return 65 + (income - mean) / mean * 19.0
            } else {
                // Between median and mean
                return 50 + (income - median) / (mean - median) * 15.0
            }
        }
    }

    // MARK: - Statistical Helper Methods

    func calculateMean(values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    func calculateMedian(values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let count = sorted.count

        if count % 2 == 0 {
            return (sorted[count / 2 - 1] + sorted[count / 2]) / 2.0
        } else {
            return sorted[count / 2]
        }
    }

    func getTop10Threshold(values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let index = Int(Double(sorted.count) * 0.9)
        return sorted[min(index, sorted.count - 1)]
    }

    // MARK: - Additional Statistics Calculations

    private func calculatePathToTop10State(for profile: UserProfile) async throws -> PathToTop10 {
        guard let regionData = dataLoader.getRegionData(for: profile.region.code, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Region data not available")
        }

        // Use actual top 10% data from region if available, otherwise estimate from mean
        let top10 = regionData.overall.top10Percent ?? (regionData.overall.mean * 1.8)

        // Use comparisonIncome for fair household comparison
        let income = profile.comparisonIncome
        let gap = max(0, top10 - income)
        let gapPercentage = income > 0 ? (gap / income) * 100 : 100

        return PathToTop10(
            currentIncome: income,
            top10Threshold: top10,
            category: profile.region.name,
            gapAmount: gap,
            gapPercentage: gapPercentage,
            isAlreadyTop10: income >= top10
        )
    }

    private func calculatePathToTop10Occupation(for profile: UserProfile) async throws -> PathToTop10 {
        guard let occupationData = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Occupation data not available")
        }

        let top10 = occupationData.top10Percent
        let income = profile.annualIncome
        let gap = max(0, top10 - income)
        let gapPercentage = income > 0 ? (gap / income) * 100 : 100

        return PathToTop10(
            currentIncome: income,
            top10Threshold: top10,
            category: occupationData.title,
            gapAmount: gap,
            gapPercentage: gapPercentage,
            isAlreadyTop10: income >= top10
        )
    }

    private func calculateCareerForecast(for profile: UserProfile) async throws -> CareerForecast {
        guard let occupationData = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Occupation data not available")
        }

        let ageGroups: [AgeGroupIncome] = occupationData.ageDistribution
            .sorted { $0.key < $1.key }
            .map { AgeGroupIncome(ageRange: $0.key, median: $0.value.median, mean: $0.value.mean) }

        // Require at least 2 age groups for meaningful forecast
        guard ageGroups.count >= 2 else {
            throw StatisticsError.dataNotAvailable("Insufficient age distribution data for career forecast")
        }

        let peakGroup = ageGroups.max { $0.median < $1.median }
        let peakAge = peakGroup?.ageRange ?? "45-54"
        let peakIncome = peakGroup?.median ?? occupationData.nationalMedian

        return CareerForecast(
            currentAge: profile.age,
            userIncome: profile.annualIncome,
            ageGroups: ageGroups,
            peakAge: peakAge,
            peakIncome: peakIncome
        )
    }

    private func calculateGenderComparison(for profile: UserProfile) async throws -> GenderComparison {
        guard let regionData = dataLoader.getRegionData(for: profile.region.code, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Region data not available")
        }

        // Support both capitalized and lowercase keys for by_gender (varies by country data files)
        let maleMedian = regionData.byGender["Male"]?.median ?? regionData.byGender["male"]?.median
        let femaleMedian = regionData.byGender["Female"]?.median ?? regionData.byGender["female"]?.median

        let payGap: Double?
        if let male = maleMedian, let female = femaleMedian, male > 0 {
            payGap = ((male - female) / male) * 100
        } else {
            payGap = nil
        }

        // Use personal income for gender comparison (comparing individual earnings, not household)
        return GenderComparison(
            category: profile.region.name,
            maleMedian: maleMedian,
            femaleMedian: femaleMedian,
            userGender: profile.gender,
            userIncome: profile.annualIncome,
            payGap: payGap
        )
    }

    private func calculateStateRanking(for profile: UserProfile) async throws -> StateRanking {
        guard let occupationData = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Occupation data not available")
        }

        // Get all states with data for this occupation
        var stateIncomes: [(code: String, median: Double)] = []
        for (stateCode, stats) in occupationData.byState {
            stateIncomes.append((code: stateCode, median: stats.median))
        }

        // Sort by median descending
        stateIncomes.sort { $0.median > $1.median }

        // Get top 5
        let topStates = stateIncomes.prefix(5).enumerated().map { index, item in
            let stateName = USState.fromCode(item.code)?.fullName ?? item.code
            return StateIncomeInfo(
                stateName: stateName,
                stateCode: item.code,
                median: item.median,
                rank: index + 1
            )
        }

        // Find user's region rank
        let userStateRank = stateIncomes.firstIndex { $0.code == profile.region.code }.map { $0 + 1 }

        return StateRanking(
            occupation: occupationData.title,
            topStates: topStates,
            userStateRank: userStateRank,
            userState: profile.region.name
        )
    }

    private func calculateSimilarOccupations(for profile: UserProfile) async throws -> [SimilarOccupation] {
        guard let currentOccupation = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Occupation data not available")
        }

        // Get all occupations from same category
        let allOccupations = dataLoader.getAllOccupations(countryCode: profile.countryCode)
        let sameCategory = allOccupations.filter {
            $0.category == currentOccupation.category && $0.socCode != currentOccupation.socCode
        }

        // Calculate similarity and sort by median income
        let similar = sameCategory.map { occupation in
            let percentDiff = ((occupation.nationalMedian - currentOccupation.nationalMedian) / currentOccupation.nationalMedian) * 100
            return SimilarOccupation(
                title: occupation.title,
                socCode: occupation.socCode,
                median: occupation.nationalMedian,
                percentageDifference: percentDiff
            )
        }

        // Return top 5 by income
        return Array(similar.sorted { $0.median > $1.median }.prefix(5))
    }

    private func calculateFunFacts(for profile: UserProfile) async throws -> FunFacts {
        guard let occupationData = dataLoader.getOccupationData(for: profile.occupation.socCode, countryCode: profile.countryCode),
              let nationalStats = dataLoader.getNationalData(countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Data not available")
        }

        // Calculate national rank percentile using personal income vs individual income stats
        // This matches the "vs National" comparison in the results
        let estimatedMean: Double
        if let meanIndividual = nationalStats.overall.meanIndividualIncome {
            estimatedMean = meanIndividual
        } else {
            let householdMedian = nationalStats.overall.medianHouseholdIncome
            let individualMedian = nationalStats.overall.medianIndividualIncome
            let isIndividualData = abs(householdMedian - individualMedian) / max(householdMedian, 1) < 0.1
            estimatedMean = isIndividualData ? nationalStats.overall.meanHouseholdIncome : nationalStats.overall.meanHouseholdIncome / 2.5
        }

        let nationalPercentile = calculatePercentile(
            income: profile.annualIncome,
            median: nationalStats.overall.medianIndividualIncome,
            mean: estimatedMean
        )

        // Get employment numbers
        let stateEmployment = occupationData.byState[profile.region.code]?.employment

        // Calculate occupation employment (sum across all states)
        let occupationEmployment = occupationData.byState.values.reduce(0) { $0 + $1.employment }

        // Calculate occupation rank (how high-paying is this occupation)
        let allOccupations = dataLoader.getAllOccupations()
        let sorted = allOccupations.sorted { $0.nationalMedian > $1.nationalMedian }
        let occupationRank = sorted.firstIndex { $0.socCode == occupationData.socCode }.map { $0 + 1 }

        return FunFacts(
            nationalRankPercentile: nationalPercentile,
            occupationEmployment: occupationEmployment,
            stateEmployment: stateEmployment,
            occupationRank: occupationRank,
            totalOccupations: allOccupations.count
        )
    }

    private func calculateAfterTaxIncome(for profile: UserProfile) -> AfterTaxIncomeResult {
        return TaxCalculator.calculateAfterTaxIncome(
            grossIncome: profile.effectiveIncome,
            countryCode: profile.countryCode,
            region: profile.region,
            filingStatus: profile.maritalStatus
        )
    }

    private func calculatePurchasingPowerAnalysis(for profile: UserProfile) async throws -> PurchasingPowerAnalysis {
        guard let regionData = dataLoader.getRegionData(for: profile.region.code, countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("Region data not available")
        }

        guard let nationalData = dataLoader.getNationalData(countryCode: profile.countryCode) else {
            throw StatisticsError.dataNotAvailable("National data not available")
        }

        // Use comparisonIncome for purchasing power comparison
        let actualIncome = profile.comparisonIncome
        let colIndex = regionData.costOfLivingIndex

        // Adjusted income: what your income would be worth in an average-cost state
        // Formula: actual_income × (100 / state_COL_index)
        let adjustedIncome = actualIncome * (100.0 / colIndex)

        // National median adjusted for COL (comparing apples to apples)
        let nationalMedian = nationalData.overall.medianIndividualIncome
        let nationalMedianAdjusted = nationalMedian * (100.0 / colIndex)

        // Calculate adjusted percentile (where you'd rank if COL was equal everywhere)
        let adjustedPercentile = calculatePercentile(
            income: adjustedIncome,
            median: nationalMedian,
            mean: nationalData.overall.meanHouseholdIncome
        )

        // Savings impact: difference in purchasing power vs average state
        // If you live in expensive state (index > 100), negative impact
        // If you live in cheap state (index < 100), positive impact
        let savingsImpact = actualIncome * ((100.0 - colIndex) / 100.0)

        return PurchasingPowerAnalysis(
            actualIncome: actualIncome,
            adjustedIncome: adjustedIncome,
            costOfLivingIndex: colIndex,
            stateName: profile.region.name,
            nationalMedianAdjusted: nationalMedianAdjusted,
            adjustedPercentile: adjustedPercentile,
            savingsImpact: savingsImpact
        )
    }
}

// MARK: - Errors

enum StatisticsError: Error {
    case dataNotAvailable(String)
    case calculationError(String)

    var localizedDescription: String {
        switch self {
        case .dataNotAvailable(let message):
            return "Data not available: \(message)"
        case .calculationError(let message):
            return "Calculation error: \(message)"
        }
    }
}
