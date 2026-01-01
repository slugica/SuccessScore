//
//  MoreInsightsView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct MoreInsightsView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    private var countryCode: String {
        viewModel.statisticsSnapshot?.userProfile.countryCode ?? "us"
    }

    private var currencySymbol: String {
        switch countryCode {
        case "us":
            return "$"
        case "uk":
            return "£"
        case "ca":
            return "C$"
        case "au":
            return "A$"
        case "nz":
            return "NZ$"
        case "de", "fr", "es":
            return "€"
        default:
            return "$"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                if let snapshot = viewModel.statisticsSnapshot {
                    // Fun Facts
                    if let funFacts = snapshot.funFacts {
                        FunFactsView(funFacts: funFacts, countryCode: countryCode)
                    }

                    // Gender Comparison
                    if let genderComparison = snapshot.genderComparison {
                        GenderComparisonView(genderComparison: genderComparison, currencySymbol: currencySymbol)
                    }

                    // Age Comparison - use region data for current country
                    if let regionData = DataLoader.shared.getRegionData(
                        for: snapshot.userProfile.region.code,
                        countryCode: snapshot.userProfile.countryCode
                    ),
                       let ageGroup = regionData.byAge[DataLoader.shared.getAgeRangeKey(for: snapshot.userProfile.age, countryCode: snapshot.userProfile.countryCode)] {
                        AgeComparisonCard(
                            userAge: snapshot.userProfile.age,
                            userIncome: snapshot.userProfile.annualIncome,
                            ageGroupMedian: ageGroup.median,
                            ageGroupMean: ageGroup.mean,
                            currencySymbol: currencySymbol
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("More Insights")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Age Comparison Card

struct AgeComparisonCard: View {
    let userAge: Int
    let userIncome: Double
    let ageGroupMedian: Double
    let ageGroupMean: Double
    var currencySymbol: String = "$"

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
                Text("Age Group Comparison")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            Divider()

            VStack(spacing: 12) {
                StatRow(label: "Your Age", value: "\(userAge) years old")
                StatRow(label: "Your Income", value: userIncome.asCurrency(symbol: currencySymbol))
                StatRow(label: "Age Group Median", value: ageGroupMedian.asCurrency(symbol: currencySymbol))
                StatRow(label: "Age Group Mean", value: ageGroupMean.asCurrency(symbol: currencySymbol))
            }

            let percentDiff = ((userIncome - ageGroupMedian) / ageGroupMedian) * 100
            let sign = percentDiff >= 0 ? "+" : ""

            Text("\(sign)\(Int(percentDiff))% vs peers your age")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(percentDiff >= 0 ? .green : .red)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .cardShadow()
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        MoreInsightsView(viewModel: StatisticsViewModel())
    }
}
