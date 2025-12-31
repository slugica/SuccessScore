//
//  PurchasingPowerDetailView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct PurchasingPowerDetailView: View {
    let analysis: PurchasingPowerAnalysis
    var currencySymbol: String = "$"

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                headerSection
                PurchasingPowerCardView(analysis: analysis, currencySymbol: currencySymbol)
                explanationSection
                footerSection
            }
            .padding(Theme.paddingLarge)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Purchasing Power")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingSmall) {
            Text("Real Buying Power")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)

            Text("How far your income goes in \(analysis.stateName)")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var explanationSection: some View {
        VStack(spacing: Theme.paddingMedium) {
            explanationCard(
                icon: "map.fill",
                title: "Cost of Living Varies",
                description: "The same income has different buying power depending on where you live. \(analysis.stateName) has a cost of living index of \(String(format: "%.1f", analysis.costOfLivingIndex)) (national average = 100)."
            )

            explanationCard(
                icon: "chart.bar.fill",
                title: "Adjusted Income",
                description: "Your \(analysis.actualIncome.asCurrency(symbol: currencySymbol)) in \(analysis.stateName) has the same purchasing power as \(analysis.adjustedIncome.asCurrency(symbol: currencySymbol)) in an average-cost area."
            )

            if abs(analysis.savingsImpact) > 1000 {
                explanationCard(
                    icon: analysis.savingsImpact < 0 ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                    title: analysis.savingsImpact < 0 ? "Higher Expenses" : "Lower Expenses",
                    description: savingsImpactExplanation,
                    accentColor: analysis.savingsImpact < 0 ? .red : .green
                )
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Divider()

            Text("Data based on 2024 Cost of Living Index")
                .font(.caption)
                .foregroundColor(.textTertiary)

            Text("Index derived from housing, utilities, groceries, transportation, healthcare, and other goods/services")
                .font(.caption2)
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Theme.paddingLarge)
    }

    // MARK: - Helper Views

    private func explanationCard(icon: String, title: String, description: String, accentColor: Color = .primaryAccent) -> some View {
        HStack(alignment: .top, spacing: Theme.paddingMedium) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(accentColor)
                .frame(width: 40, height: 40)
                .background(accentColor.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Theme.paddingMedium)
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadiusMedium)
        .cardShadow()
    }

    // MARK: - Computed Properties

    private var savingsImpactExplanation: String {
        let impact = abs(analysis.savingsImpact)

        if analysis.savingsImpact < 0 {
            return "Living in \(analysis.stateName) costs you approximately \(impact.asCurrency(symbol: currencySymbol)) per year more than if you lived in an average-cost area with the same nominal income."
        } else {
            return "Living in \(analysis.stateName) saves you approximately \(impact.asCurrency(symbol: currencySymbol)) per year compared to living in an average-cost area with the same nominal income."
        }
    }
}

#Preview {
    NavigationStack {
        PurchasingPowerDetailView(
            analysis: PurchasingPowerAnalysis(
                actualIncome: 100000,
                adjustedIncome: 69000,
                costOfLivingIndex: 144.8,
                stateName: "California",
                nationalMedianAdjusted: 45000,
                adjustedPercentile: 65,
                savingsImpact: -44800
            )
        )
    }
}
