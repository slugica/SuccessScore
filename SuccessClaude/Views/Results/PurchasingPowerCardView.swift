//
//  PurchasingPowerCardView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct PurchasingPowerCardView: View {
    let analysis: PurchasingPowerAnalysis
    var currencySymbol: String = "$"

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            headerSection
            Divider()
            metricsGrid
            colExplanation
        }
        .padding(Theme.paddingLarge)
        .background(cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .cardShadow()
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Real Purchasing Power")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Spacer()

                colBadge
            }

            Text("Adjusted for \(analysis.stateName) cost of living")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }

    private var colBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: colBadgeIcon)
                .font(.caption2)

            Text(analysis.costOfLivingDescription)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(colBadgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colBadgeColor.opacity(0.1))
        .cornerRadius(8)
    }

    private var metricsGrid: some View {
        VStack(spacing: Theme.paddingMedium) {
            HStack(spacing: Theme.paddingMedium) {
                metricItem(
                    title: "Your Income",
                    value: analysis.actualIncome.asCurrency(symbol: currencySymbol),
                    subtitle: "\(analysis.stateName)",
                    isHighlighted: false
                )
                metricItem(
                    title: "Equivalent Income",
                    value: analysis.adjustedIncome.asCurrency(symbol: currencySymbol),
                    subtitle: "National Average Area",
                    isHighlighted: true
                )
            }

            Divider()

            HStack(spacing: Theme.paddingMedium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cost of Living Index")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", analysis.costOfLivingIndex))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)

                        Text("/ 100")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 4) {
                    Text(savingsImpactLabel)
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text(savingsImpactValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(savingsImpactColor)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var colExplanation: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.caption)
                .foregroundColor(.primaryAccent)

            Text(explanationText)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    private func metricItem(title: String, value: String, subtitle: String, isHighlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)

            Text(value)
                .font(isHighlighted ? .headline : .subheadline)
                .fontWeight(isHighlighted ? .bold : .semibold)
                .foregroundColor(isHighlighted ? .primaryAccent : .textPrimary)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Computed Properties

    private var colBadgeIcon: String {
        if analysis.costOfLivingIndex < 95 {
            return "arrow.down.circle.fill"
        } else if analysis.costOfLivingIndex > 105 {
            return "arrow.up.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }

    private var colBadgeColor: Color {
        if analysis.costOfLivingIndex < 95 {
            return .green
        } else if analysis.costOfLivingIndex > 105 {
            return .orange
        } else {
            return .blue
        }
    }

    private var savingsImpactLabel: String {
        if analysis.savingsImpact > 0 {
            return "Extra Buying Power"
        } else if analysis.savingsImpact < 0 {
            return "Higher Living Costs"
        } else {
            return "Impact"
        }
    }

    private var savingsImpactValue: String {
        let impact = abs(analysis.savingsImpact)
        return impact > 1000 ? impact.asCurrency(symbol: currencySymbol) : "\(currencySymbol)0"
    }

    private var savingsImpactColor: Color {
        if analysis.savingsImpact > 0 {
            return .green
        } else if analysis.savingsImpact < 0 {
            return .red
        } else {
            return .gray
        }
    }

    private var explanationText: String {
        let diff = analysis.adjustedIncome - analysis.actualIncome

        if analysis.costOfLivingIndex > 105 {
            return "Living in \(analysis.stateName) costs \(String(format: "%.0f", analysis.costOfLivingIndex - 100))% more than average. Your \(analysis.actualIncome.asCurrency(symbol: currencySymbol)) has the same buying power as \(analysis.adjustedIncome.asCurrency(symbol: currencySymbol)) elsewhere."
        } else if analysis.costOfLivingIndex < 95 {
            return "Living in \(analysis.stateName) costs \(String(format: "%.0f", 100 - analysis.costOfLivingIndex))% less than average. Your \(analysis.actualIncome.asCurrency(symbol: currencySymbol)) goes further here!"
        } else {
            return "Cost of living in \(analysis.stateName) is close to the national average."
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
            .fill(Color(.systemBackground))
    }
}

#Preview {
    PurchasingPowerCardView(
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
    .padding()
}
