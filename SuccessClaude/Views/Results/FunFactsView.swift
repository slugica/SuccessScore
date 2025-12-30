//
//  FunFactsView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct FunFactsView: View {
    let funFacts: FunFacts

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)

                Text("Interesting Facts")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Spacer()
            }

            VStack(spacing: 12) {
                // National ranking
                FactCard(
                    icon: "flag.fill",
                    iconColor: .blue,
                    title: "National Ranking",
                    fact: "You earn more than \(String(format: "%.0f", funFacts.nationalRankPercentile))% of people in the US",
                    detail: "Top \(String(format: "%.0f", 100 - funFacts.nationalRankPercentile))% nationally"
                )

                // Occupation employment
                if let occEmployment = funFacts.occupationEmployment {
                    FactCard(
                        icon: "person.3.fill",
                        iconColor: .green,
                        title: "Profession Size",
                        fact: "\(formatNumber(occEmployment)) people work in your profession nationwide",
                        detail: nil
                    )
                }

                // State employment
                if let stateEmployment = funFacts.stateEmployment {
                    FactCard(
                        icon: "map.fill",
                        iconColor: .orange,
                        title: "In Your State",
                        fact: "\(formatNumber(stateEmployment)) people in your profession",
                        detail: nil
                    )
                }

                // Occupation rank
                if let occRank = funFacts.occupationRank {
                    let topPercent = (Double(occRank) / Double(funFacts.totalOccupations)) * 100
                    FactCard(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Profession Ranking",
                        fact: "Your profession ranks #\(occRank) out of \(funFacts.totalOccupations)",
                        detail: "Top \(String(format: "%.0f", topPercent))% highest-paying occupations"
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct FactCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let fact: String
    let detail: String?

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)

                Text(fact)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.primaryAccent)
                        .fontWeight(.semibold)
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#Preview {
    FunFactsView(
        funFacts: FunFacts(
            nationalRankPercentile: 87.5,
            occupationEmployment: 1_450_000,
            stateEmployment: 250_000,
            occupationRank: 12,
            totalOccupations: 122
        )
    )
    .padding()
}
