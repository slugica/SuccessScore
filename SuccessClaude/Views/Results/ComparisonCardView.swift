//
//  ComparisonCardView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct ComparisonCardView: View {
    let comparison: ComparisonResult

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            headerSection
            Divider()
            metricsGrid

            if comparison.hasHouseholdData {
                householdSection
            }

            percentileBar
        }
        .padding(Theme.paddingLarge)
        .background(cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .cardShadow()
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comparison.categoryTitle)
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text(comparison.categoryDescription)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }

    private var metricsGrid: some View {
        VStack(spacing: Theme.paddingMedium) {
            HStack(spacing: Theme.paddingMedium) {
                metricItem(title: "Your Income", value: comparison.userIncome.asCurrency, isHighlighted: true)
                metricItem(title: "Median", value: comparison.medianIncome.asCurrency)
            }

            HStack(spacing: Theme.paddingMedium) {
                metricItem(title: "Average", value: comparison.meanIncome.asCurrency)
                metricItem(title: "Top 10%", value: comparison.top10Threshold.asCurrency)
            }
        }
    }

    private var householdSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()

            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.primaryAccent)
                    .font(.caption)

                Text("Household: \(comparison.householdSize ?? 0) people")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Spacer()

                if let perCapita = comparison.perCapitaIncome {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Per Person")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)

                        Text(perCapita.asCurrency)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryAccent)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func metricItem(title: String, value: String, isHighlighted: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)

            Text(value)
                .font(isHighlighted ? .headline : .subheadline)
                .fontWeight(isHighlighted ? .bold : .regular)
                .foregroundColor(isHighlighted ? .primaryAccent : .textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.paddingSmall)
        .background(Color(.systemBackground))
        .cornerRadius(Theme.cornerRadiusSmall)
    }

    private var percentileBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Percentile")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text(comparison.percentile.asOrdinalPercentile)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(percentileColor)
            }

            // Percentile bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)

                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(percentileColor)
                        .frame(width: geometry.size.width * (comparison.percentile / 100), height: 8)
                }
            }
            .frame(height: 8)

            // Difference from median
            HStack {
                Image(systemName: comparison.isAboveMedian ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(comparison.isAboveMedian ? .green : .red)

                Text(comparison.percentageDifference.asSignedPercentage + " vs. median")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                if comparison.isInTop10 {
                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("Top 10%")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
            }
        }
    }

    // MARK: - Helpers

    private var percentileColor: Color {
        Color.percentileColor(for: comparison.percentile)
    }

    private var cardBackground: some View {
        Color.cardBackground
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }

    private var borderColor: Color {
        if comparison.isInTop10 {
            return Color.orange.opacity(0.3)
        } else if comparison.isAboveMedian {
            return Color.green.opacity(0.2)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ComparisonCardView(
            comparison: ComparisonResult(
                category: .state(stateName: "California"),
                userIncome: 85000,
                medianIncome: 75000,
                meanIncome: 95000,
                top10Threshold: 150000,
                percentile: 67.5,
                percentageDifference: 13.3,
                sampleSize: nil,
                perCapitaIncome: 28333,
                householdSize: 3
            )
        )

        ComparisonCardView(
            comparison: ComparisonResult(
                category: .national,
                userIncome: 45000,
                medianIncome: 55000,
                meanIncome: 70000,
                top10Threshold: 120000,
                percentile: 38.2,
                percentageDifference: -18.2,
                sampleSize: nil,
                perCapitaIncome: nil,
                householdSize: nil
            )
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
