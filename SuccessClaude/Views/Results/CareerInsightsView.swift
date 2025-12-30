//
//  CareerInsightsView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct CareerInsightsView: View {
    let occupation: OccupationCategory
    let automationRisk: OccupationRisk

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                // Hero section
                heroSection

                // Risk breakdown
                riskBreakdownSection

                // Detailed explanation
                explanationSection

                // Timeline
                timelineSection

                // Data sources
                sourcesSection
            }
            .padding()
        }
        .navigationTitle("Career Insights")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: Theme.paddingMedium) {
            // Occupation title
            Text(occupation.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.textPrimary)

            // Overall risk badge
            HStack(spacing: 12) {
                Text(automationRisk.overallRiskLevel.emoji)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text(automationRisk.overallRiskLevel.label)
                        .font(.headline)
                        .foregroundColor(automationRisk.overallRiskLevel.color)

                    Text("\(Int(automationRisk.overallRisk))% Automation Exposure")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .fill(automationRisk.overallRiskLevel.color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                    .stroke(automationRisk.overallRiskLevel.color.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Risk Breakdown

    private var riskBreakdownSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            Text("Automation Risk Breakdown")
                .font(.headline)
                .foregroundColor(.textPrimary)

            // AI Risk
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("🤖 AI / LLM Risk")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("\(Int(automationRisk.aiRisk))%")
                        .font(.headline)
                        .foregroundColor(automationRisk.aiRiskLevel.color)
                }

                ProgressBar(
                    progress: automationRisk.aiRisk / 100,
                    color: automationRisk.aiRiskLevel.color,
                    backgroundColor: Color.gray.opacity(0.2),
                    height: 8
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(Theme.cornerRadiusMedium)

            // Robotics Risk
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("🦾 Physical Automation")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text("\(Int(automationRisk.roboticsRisk))%")
                        .font(.headline)
                        .foregroundColor(automationRisk.roboticsRiskLevel.color)
                }

                ProgressBar(
                    progress: automationRisk.roboticsRisk / 100,
                    color: automationRisk.roboticsRiskLevel.color,
                    backgroundColor: Color.gray.opacity(0.2),
                    height: 8
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(Theme.cornerRadiusMedium)

            // Primary threat
            Text("Primary exposure: **\(automationRisk.primaryThreat)**")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.horizontal)
        }
    }

    // MARK: - Explanation Section

    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            Text("What This Means")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text(automationRisk.overallRiskLevel.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .cornerRadius(Theme.cornerRadiusMedium)

            Text("Detailed Analysis")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.top, 8)

            Text(automationRisk.detailedExplanation)
                .font(.body)
                .foregroundColor(.textSecondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .cornerRadius(Theme.cornerRadiusMedium)
        }
    }

    // MARK: - Timeline Section

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            Text("Timeframe Estimate")
                .font(.headline)
                .foregroundColor(.textPrimary)

            HStack(spacing: 12) {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.primaryAccent)

                VStack(alignment: .leading, spacing: 4) {
                    Text(automationRisk.timeframeEstimate)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Text("Based on current technology trends")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(Theme.cornerRadiusMedium)
        }
    }

    // MARK: - Sources Section

    private var sourcesSection: some View {
        VStack(alignment: .leading, spacing: Theme.paddingSmall) {
            Text("Data Sources")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)

            if let metadata = DataLoader.shared.getAutomationRiskMetadata() {
                ForEach(metadata.sources, id: \.self) { source in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .foregroundColor(.textTertiary)
                        Text(source)
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }

                Text("Last updated: \(metadata.lastUpdated)")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.cardBackground.opacity(0.5))
        .cornerRadius(Theme.cornerRadiusSmall)
    }
}

// MARK: - Progress Bar Component

private struct ProgressBar: View {
    let progress: Double
    let color: Color
    let backgroundColor: Color
    let height: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * min(progress, 1.0))
            }
        }
        .frame(height: height)
    }
}

#Preview {
    NavigationStack {
        CareerInsightsView(
            occupation: OccupationCategory(
                socCode: "15-1252",
                title: "Software Developers",
                category: "Computer and Mathematical"
            ),
            automationRisk: OccupationRisk(
                socCode: "15-1252",
                title: "Software Developers",
                category: "Computer and Mathematical",
                aiRisk: 85,
                roboticsRisk: 10,
                overallRisk: 55
            )
        )
    }
}
