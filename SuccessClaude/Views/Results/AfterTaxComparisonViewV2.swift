//
//  AfterTaxComparisonViewV2.swift
//  SuccessClaude
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

/// Country-aware after-tax income comparison view
struct AfterTaxComparisonViewV2: View {
    let afterTaxIncome: AfterTaxIncomeResult
    let currencySymbol: String

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
                        duration: 1.0,
                        currencySymbol: currencySymbol
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
                        duration: 1.0,
                        currencySymbol: currencySymbol
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

            // Tax breakdown - dynamic based on components
            VStack(spacing: 12) {
                ForEach(Array(afterTaxIncome.components.enumerated()), id: \.offset) { index, component in
                    TaxBreakdownRowV2(
                        icon: iconForComponent(component.name, index: index),
                        iconColor: colorForComponent(component.name, index: index),
                        label: component.name,
                        amount: component.amount,
                        rate: component.rate,
                        total: afterTaxIncome.grossIncome,
                        currencySymbol: currencySymbol
                    )
                }
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
                        duration: 1.0,
                        currencySymbol: currencySymbol
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

            // Country-specific hint
            if let hint = hintForCountry() {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)

                    Text(hint)
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

    // MARK: - Helpers

    private func iconForComponent(_ name: String, index: Int) -> String {
        if name.contains("Federal") || name.contains("Income Tax") {
            return "flag.fill"
        } else if name.contains("State") || name.contains("Region") {
            return "map.fill"
        } else if name.contains("FICA") || name.contains("Social Security") {
            return "cross.case.fill"
        } else if name.contains("National Insurance") {
            return "shield.fill"
        } else {
            return "banknote.fill"
        }
    }

    private func colorForComponent(_ name: String, index: Int) -> Color {
        if name.contains("Federal") || name.contains("Income Tax") {
            return .blue
        } else if name.contains("State") || name.contains("Region") {
            return .purple
        } else if name.contains("FICA") || name.contains("Social Security") {
            return .orange
        } else if name.contains("National Insurance") {
            return .green
        } else {
            let colors: [Color] = [.blue, .purple, .orange, .green, .red]
            return colors[index % colors.count]
        }
    }

    private func hintForCountry() -> String? {
        switch afterTaxIncome.countryCode {
        case "us":
            if afterTaxIncome.components.contains(where: { $0.name.contains("State") && $0.amount > 0 }) {
                return "Some states have no income tax (TX, FL, WA). Use Relocation Calculator to compare."
            }
            return nil
        case "uk":
            return "UK tax rates apply to all regions. National Insurance funds NHS and state pension."
        default:
            return nil
        }
    }
}

struct TaxBreakdownRowV2: View {
    let icon: String
    let iconColor: Color
    let label: String
    let amount: Double
    let rate: Double
    let total: Double
    let currencySymbol: String

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
                progress: total > 0 ? amount / total : 0,
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
                    duration: 1.0,
                    currencySymbol: currencySymbol
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
    ScrollView {
        VStack(spacing: 20) {
            // US Example
            AfterTaxComparisonViewV2(
                afterTaxIncome: TaxCalculator.calculateAfterTaxIncome(
                    grossIncome: 150_000,
                    countryCode: "us",
                    region: Region(code: "CA", name: "California", countryCode: "us"),
                    filingStatus: .married
                ),
                currencySymbol: "$"
            )

            // UK Example
            AfterTaxComparisonViewV2(
                afterTaxIncome: TaxCalculator.calculateAfterTaxIncome(
                    grossIncome: 75_000,
                    countryCode: "uk",
                    region: Region(code: "LON", name: "London", countryCode: "uk"),
                    filingStatus: .single
                ),
                currencySymbol: "£"
            )
        }
        .padding()
    }
}
