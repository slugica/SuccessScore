//
//  StatisticsViewModel.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var statisticsSnapshot: StatisticsSnapshot?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var showError = false

    private let calculator: StatisticsCalculator
    private let dataLoader: DataLoader

    init(calculator: StatisticsCalculator = StatisticsCalculator(), dataLoader: DataLoader = .shared) {
        self.calculator = calculator
        self.dataLoader = dataLoader
    }

    // MARK: - Calculate Statistics

    func calculateStatistics(for profile: UserProfile) async {
        isLoading = true
        error = nil
        showError = false

        defer { isLoading = false }

        do {
            // Ensure data is loaded for this profile's country
            if !dataLoader.isCountryDataLoaded(profile.countryCode) {
                print("📊 Loading data for country: \(profile.countryCode)")
                try await dataLoader.loadCountryData(countryCode: profile.countryCode)
            }

            // Set current country for DataLoader
            dataLoader.setCurrentCountry(profile.countryCode)
            print("📊 Current country set to: \(profile.countryCode)")

            // Generate statistics snapshot
            let snapshot = try await calculator.generateStatisticsSnapshot(for: profile)
            statisticsSnapshot = snapshot

        } catch {
            self.error = error
            self.showError = true
            print("❌❌❌ ERROR calculating statistics for country: \(profile.countryCode)")
            print("❌ Error: \(error)")
            print("❌ Error type: \(type(of: error))")
            print("❌ Error description: \(error.localizedDescription)")
            if let statsError = error as? StatisticsError {
                print("❌ StatisticsError: \(statsError)")
            }
        }
    }

    // MARK: - Data Access

    var hasResults: Bool {
        statisticsSnapshot != nil
    }

    var userIncome: Double {
        statisticsSnapshot?.userProfile.annualIncome ?? 0
    }

    var overallPercentile: Double {
        statisticsSnapshot?.overallPercentile ?? 0
    }

    var allComparisons: [ComparisonResult] {
        statisticsSnapshot?.allComparisons ?? []
    }

    var dataSourceAttribution: String {
        statisticsSnapshot?.dataSource ?? "BLS OEWS, Census ACS, MERIC Cost of Living (2024), AI/Automation Risk Data"
    }

    var generatedDate: Date {
        statisticsSnapshot?.generatedAt ?? Date()
    }

    // MARK: - Comparison Accessors

    var stateComparison: ComparisonResult? {
        statisticsSnapshot?.stateComparison
    }

    var nationalComparison: ComparisonResult? {
        statisticsSnapshot?.nationalComparison
    }

    var occupationComparison: ComparisonResult? {
        statisticsSnapshot?.occupationComparison
    }

    var peerComparison: ComparisonResult? {
        statisticsSnapshot?.peerComparison
    }

    var automationRisk: OccupationRisk? {
        guard let snapshot = statisticsSnapshot else { return nil }
        let socCode = snapshot.userProfile.occupation.socCode
        let countryCode = snapshot.userProfile.countryCode
        return dataLoader.getAutomationRisk(for: socCode, countryCode: countryCode)
    }

    var earnedBadges: [Badge] {
        guard let snapshot = statisticsSnapshot else { return [] }
        return Badge.earnedBadges(from: snapshot, automationRisk: automationRisk)
    }

    // MARK: - Helper Methods

    func getComparison(for category: ComparisonCategory) -> ComparisonResult? {
        allComparisons.first { comparison in
            switch (comparison.category, category) {
            case (.state, .state),
                 (.national, .national),
                 (.occupation, .occupation),
                 (.peers, .peers):
                return true
            default:
                return false
            }
        }
    }

    /// Get percentile color based on performance
    func getPercentileColor(for percentile: Double) -> Color {
        Color.percentileColor(for: percentile)
    }

    /// Get comparison color (above/below median)
    func getComparisonColor(for result: ComparisonResult) -> Color {
        Color.comparisonColor(isAboveMedian: result.isAboveMedian)
    }

    // MARK: - Reset

    func reset() {
        statisticsSnapshot = nil
        error = nil
        showError = false
    }

    // MARK: - Refresh Data

    func refreshData() async {
        do {
            try await dataLoader.loadAllData()
        } catch {
            self.error = error
            self.showError = true
        }
    }

    // MARK: - Error Handling

    var errorMessage: String {
        if let error = error {
            return error.localizedDescription
        }
        return NSLocalizedString("error.unknown", value: "An unknown error occurred", comment: "")
    }

    func clearError() {
        error = nil
        showError = false
    }
}
