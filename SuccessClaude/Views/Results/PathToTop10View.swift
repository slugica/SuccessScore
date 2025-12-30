//
//  PathToTop10View.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct PathToTop10View: View {
    let pathToTop10: PathToTop10
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text(pathToTop10.category)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            if pathToTop10.isAlreadyTop10 {
                // Already in top 10%
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        Text("Congratulations! You're in the top 10%")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }

                    Text("Your income: \(pathToTop10.currentIncome.asCurrency)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text("Top 10% threshold: \(pathToTop10.top10Threshold.asCurrency)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                // Path to top 10%
                VStack(alignment: .leading, spacing: 12) {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            AnimatedNumberView(
                                value: pathToTop10.progressPercentage,
                                format: .integer,
                                font: .title2.weight(.bold),
                                color: .primaryAccent,
                                duration: 1.0,
                                suffix: "%"
                            )

                            Text("of the way to top 10%")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)

                            Spacer()
                        }

                        AnimatedProgressBar(
                            progress: pathToTop10.progressPercentage / 100,
                            height: 16,
                            color: .primaryAccent,
                            backgroundColor: Color.gray.opacity(0.2),
                            cornerRadius: 8,
                            duration: 1.2
                        )
                    }

                    Divider()

                    // Gap information
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Income")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)

                                Text(pathToTop10.currentIncome.asCurrency)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textPrimary)
                            }

                            Spacer()

                            Image(systemName: "arrow.right")
                                .foregroundColor(.textTertiary)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Top 10%")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)

                                Text(pathToTop10.top10Threshold.asCurrency)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primaryAccent)
                            }
                        }

                        HStack {
                            Text("Gap:")
                                .font(.caption)
                                .foregroundColor(.textSecondary)

                            Text(pathToTop10.gapAmount.asCurrency)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)

                            Text("(\(String(format: "%.1f", pathToTop10.gapPercentage))% increase needed)")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
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
}

#Preview {
    VStack(spacing: 20) {
        PathToTop10View(
            pathToTop10: PathToTop10(
                currentIncome: 130000,
                top10Threshold: 200000,
                category: "Software Developers",
                gapAmount: 70000,
                gapPercentage: 53.8,
                isAlreadyTop10: false
            ),
            title: "Path to Top 10%"
        )

        PathToTop10View(
            pathToTop10: PathToTop10(
                currentIncome: 220000,
                top10Threshold: 200000,
                category: "California",
                gapAmount: 0,
                gapPercentage: 0,
                isAlreadyTop10: true
            ),
            title: "Top 10% in California"
        )
    }
    .padding()
}
