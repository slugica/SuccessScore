//
//  AfterTaxComparisonView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct AfterTaxComparisonView: View {
    let afterTaxIncome: AfterTaxIncome

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("After-Tax Income")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text("Your real take-home pay")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // Big numbers comparison
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Gross")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    AnimatedNumberView(
                        value: afterTaxIncome.grossIncome,
                        format: .currency,
                        font: .title3.weight(.bold),
                        color: .textPrimary,
                        duration: 1.0
                    )
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.textTertiary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("After Tax")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    AnimatedNumberView(
                        value: afterTaxIncome.afterTaxIncome,
                        format: .currency,
                        font: .title3.weight(.bold),
                        color: .green,
                        duration: 1.0
                    )
                }

                Spacer()

                // Effective rate badge
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Effective Rate")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)

                    AnimatedNumberView(
                        value: afterTaxIncome.effectiveTaxRate,
                        format: .percentage,
                        font: .title3.weight(.bold),
                        color: .red,
                        duration: 1.0,
                        decimalPlaces: 1
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.05))
            )

            // Tax breakdown
            VStack(spacing: 12) {
                TaxBreakdownRow(
                    icon: "flag.fill",
                    iconColor: .blue,
                    label: "Federal Tax",
                    amount: afterTaxIncome.federalTax,
                    rate: afterTaxIncome.federalTaxRate,
                    total: afterTaxIncome.grossIncome
                )

                TaxBreakdownRow(
                    icon: "map.fill",
                    iconColor: .purple,
                    label: "\(afterTaxIncome.state.fullName) State Tax",
                    amount: afterTaxIncome.stateTax,
                    rate: afterTaxIncome.stateTaxRate,
                    total: afterTaxIncome.grossIncome
                )

                TaxBreakdownRow(
                    icon: "cross.case.fill",
                    iconColor: .orange,
                    label: "FICA (SS + Medicare)",
                    amount: afterTaxIncome.ficaTax,
                    rate: (afterTaxIncome.ficaTax / afterTaxIncome.grossIncome) * 100,
                    total: afterTaxIncome.grossIncome
                )
            }

            Divider()

            // Total tax
            HStack {
                Image(systemName: "sum")
                    .foregroundColor(.red)

                Text("Total Taxes")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    AnimatedNumberView(
                        value: afterTaxIncome.totalTax,
                        format: .currency,
                        font: .body.weight(.bold),
                        color: .red,
                        duration: 1.0
                    )

                    AnimatedNumberView(
                        value: afterTaxIncome.effectiveTaxRate,
                        format: .percentage,
                        font: .caption2,
                        color: .textSecondary,
                        duration: 1.0,
                        suffix: " of income",
                        decimalPlaces: 1
                    )
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.05))
            )

            // State comparison hint
            if afterTaxIncome.stateTax > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text("Some states have no income tax (TX, FL, WA). Use Relocation Calculator to compare.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct TaxBreakdownRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let amount: Double
    let rate: Double
    let total: Double

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)

            // Label
            Text(label)
                .font(.subheadline)
                .foregroundColor(.textPrimary)

            Spacer()

            // Progress bar
            AnimatedProgressBar(
                progress: amount / total,
                height: 6,
                color: iconColor.opacity(0.7),
                backgroundColor: Color.gray.opacity(0.1),
                cornerRadius: 4,
                duration: 1.0
            )
            .frame(width: 60)

            // Amount and rate
            VStack(alignment: .trailing, spacing: 2) {
                AnimatedNumberView(
                    value: amount,
                    format: .currency,
                    font: .subheadline.weight(.semibold),
                    color: .textPrimary,
                    duration: 1.0
                )

                AnimatedNumberView(
                    value: rate,
                    format: .percentage,
                    font: .caption2,
                    color: .textSecondary,
                    duration: 1.0,
                    decimalPlaces: 1
                )
            }
            .frame(width: 80, alignment: .trailing)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AfterTaxComparisonView(
            afterTaxIncome: TaxCalculator.calculateAfterTaxIncome(
                grossIncome: 150_000,
                state: .california,
                filingStatus: .married
            )
        )

        AfterTaxComparisonView(
            afterTaxIncome: TaxCalculator.calculateAfterTaxIncome(
                grossIncome: 150_000,
                state: .texas,
                filingStatus: .single
            )
        )
    }
    .padding()
}
