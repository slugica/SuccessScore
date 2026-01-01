//
//  StatisticsResultsView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct StatisticsResultsView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Country/Currency Support

    private var countryCode: String {
        viewModel.statisticsSnapshot?.userProfile.countryCode ?? "us"
    }

    private var currencySymbol: String {
        switch countryCode {
        case "us":
            return "$"
        case "ca":
            return "C$"
        case "uk":
            return "£"
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

    private var countryName: String {
        switch countryCode {
        case "us":
            return "United States"
        case "ca":
            return "Canada"
        case "uk":
            return "United Kingdom"
        case "au":
            return "Australia"
        case "nz":
            return "New Zealand"
        case "de":
            return "Germany"
        case "fr":
            return "France"
        case "es":
            return "Spain"
        default:
            return "Country"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                if let snapshot = viewModel.statisticsSnapshot {
                    resultsContent
                } else {
                    loadingView
                }
            }
            .padding(Theme.paddingLarge)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resultsContent: some View {
        VStack(spacing: Theme.paddingLarge) {
            // 1. Hero Section (with integrated quick stats)
            heroSection

            // 2. Insight Cards Grid
            insightCardsGrid

            footerSection
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        let successScore = SuccessScore(score: viewModel.overallPercentile)

        return VStack(spacing: Theme.paddingMedium) {
            // Tier Badge
            HStack(spacing: 6) {
                Text(successScore.tier.emoji)
                    .font(.title3)

                Text(successScore.tier.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(successScore.tier.color)

                Text("Tier")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(successScore.tier.color.opacity(0.15))
            )

            // Occupation with emoji
            if let snapshot = viewModel.statisticsSnapshot {
                HStack(spacing: 8) {
                    Text(OccupationPersonalization.getEmoji(for: snapshot.userProfile.occupation.category))
                        .font(.system(size: 32))

                    Text(snapshot.userProfile.occupation.title)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.horizontal)

                // Income Range + Location + Age
                VStack(spacing: 8) {
                    // Income Range
                    Text(incomeRangeText(for: snapshot.userProfile.annualIncome))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)

                    // Location + Age
                    HStack(spacing: 6) {
                        Text("📍 \(snapshot.userProfile.region.name)")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)

                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.textTertiary)

                        Text("👤 \(snapshot.userProfile.age) years old")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.top, 8)
            }

            Divider()
                .padding(.horizontal, Theme.paddingLarge)

            // SUCCESS SCORE label
            Text("SUCCESS SCORE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.textSecondary)
                .tracking(2)

            // Score circle
            PercentileIndicatorView(percentile: viewModel.overallPercentile, color: successScore.tier.color)
                .padding(.vertical, 8)

            // Motivational message
            Text(successScore.tier.motivationalMessage)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            // Quick Stats (integrated)
            if viewModel.allComparisons.count >= 4 {
                Divider()
                    .padding(.horizontal, Theme.paddingLarge)
                    .padding(.vertical, 8)

                VStack(spacing: 8) {
                    HStack(spacing: 16) {
                        CompactStatItem(
                            icon: "map.fill",
                            iconColor: .blue,
                            label: "vs State",
                            value: formatQuickStat(viewModel.allComparisons[0])
                        )
                        CompactStatItem(
                            icon: "flag.fill",
                            iconColor: .green,
                            label: "vs Nation",
                            value: formatQuickStat(viewModel.allComparisons[1])
                        )
                    }

                    HStack(spacing: 16) {
                        CompactStatItem(
                            icon: "briefcase.fill",
                            iconColor: .orange,
                            label: "vs Occupation",
                            value: formatQuickStat(viewModel.allComparisons[2])
                        )
                        CompactStatItem(
                            icon: "person.2.fill",
                            iconColor: .purple,
                            label: "vs Peers",
                            value: formatQuickStat(viewModel.allComparisons[3])
                        )
                    }
                }
            }

            // Earned Badges
            if !viewModel.earnedBadges.isEmpty {
                Divider()
                    .padding(.horizontal, Theme.paddingLarge)
                    .padding(.vertical, 4)

                HStack(spacing: 6) {
                    ForEach(Array(viewModel.earnedBadges.enumerated()), id: \.element.id) { index, badge in
                        BadgePill(badge: badge)

                        if index < viewModel.earnedBadges.count - 1 {
                            Text("•")
                                .font(.subheadline)
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
            }
        }
        .padding(Theme.paddingLarge)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cardBackground,
                            successScore.tier.color.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: successScore.tier.color.opacity(0.2), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(successScore.tier.color.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.bottom, 4)

            if viewModel.allComparisons.count >= 4 {
                QuickStatRow(
                    icon: "map.fill",
                    iconColor: .blue,
                    label: "vs State",
                    value: formatQuickStat(viewModel.allComparisons[0])
                )

                QuickStatRow(
                    icon: "flag.fill",
                    iconColor: .green,
                    label: "vs Nation",
                    value: formatQuickStat(viewModel.allComparisons[1])
                )

                QuickStatRow(
                    icon: "briefcase.fill",
                    iconColor: .orange,
                    label: "vs Occupation",
                    value: formatQuickStat(viewModel.allComparisons[2])
                )

                QuickStatRow(
                    icon: "person.2.fill",
                    iconColor: .purple,
                    label: "vs Peers",
                    value: formatQuickStat(viewModel.allComparisons[3])
                )
            }
        }
        .padding(Theme.paddingLarge)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .cardShadow()
    }

    // MARK: - Insight Cards Grid

    private var insightCardsGrid: some View {
        VStack(spacing: Theme.paddingMedium) {
            // After Tax Card
            NavigationLink(destination: afterTaxDestination) {
                InsightCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: .green,
                    title: "After Tax",
                    subtitle: afterTaxSubtitle,
                    accentColor: .green
                ) {
                    afterTaxPreview
                }
            }
            .buttonStyle(.plain)

            // Purchasing Power Card
            if let snapshot = viewModel.statisticsSnapshot,
               let purchasingPower = snapshot.purchasingPowerAnalysis {
                NavigationLink(destination: purchasingPowerDestination) {
                    InsightCard(
                        icon: "cart.fill",
                        iconColor: purchasingPowerColor(purchasingPower),
                        title: "Purchasing Power",
                        subtitle: purchasingPowerSubtitle(purchasingPower),
                        accentColor: purchasingPowerColor(purchasingPower)
                    ) {
                        purchasingPowerPreview(purchasingPower)
                    }
                }
                .buttonStyle(.plain)
            }

            // Comparisons Card
            NavigationLink(destination: ComparisonsDetailView(viewModel: viewModel)) {
                InsightCard(
                    icon: "chart.bar.fill",
                    iconColor: .blue,
                    title: "Comparisons",
                    subtitle: comparisonsSubtitle,
                    accentColor: .blue
                ) {
                    comparisonsPreview
                }
            }
            .buttonStyle(.plain)

            // Career Path Card
            NavigationLink(destination: careerPathDestination) {
                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: .primaryAccent,
                    title: "Career Path",
                    subtitle: careerPathSubtitle,
                    accentColor: .primaryAccent
                ) {
                    careerPathPreview
                }
            }
            .buttonStyle(.plain)

            // Career Insights Card
            if viewModel.automationRisk != nil {
                NavigationLink(destination: careerInsightsDestination) {
                    InsightCard(
                        icon: "brain.head.profile",
                        iconColor: .purple,
                        title: "Career Insights",
                        subtitle: careerInsightsSubtitle,
                        accentColor: .purple
                    ) {
                        careerInsightsPreview
                    }
                }
                .buttonStyle(.plain)
            }

            // More Insights Card
            NavigationLink(destination: MoreInsightsView(viewModel: viewModel)) {
                InsightCard(
                    icon: "sparkles",
                    iconColor: .orange,
                    title: "More Insights",
                    subtitle: "Fun facts & stats",
                    accentColor: .orange
                ) {
                    moreInsightsPreview
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Preview Content

    @ViewBuilder
    private var afterTaxPreview: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let afterTax = snapshot.afterTaxIncome {
            HStack(spacing: 20) {
                PreviewStatItem(label: "Gross", value: afterTax.grossIncome.asCurrency(countryCode: countryCode))
                PreviewStatItem(label: "Taxes", value: afterTax.totalTax.asCurrency(countryCode: countryCode), color: .red)
                PreviewStatItem(label: "Net", value: afterTax.afterTaxIncome.asCurrency(countryCode: countryCode), color: .green)
            }
        }
    }

    @ViewBuilder
    private func purchasingPowerPreview(_ analysis: PurchasingPowerAnalysis) -> some View {
        HStack(spacing: 16) {
            PreviewStatItem(
                label: "Actual",
                value: analysis.actualIncome.asCurrency(countryCode: countryCode)
            )
            PreviewStatItem(
                label: "Adjusted",
                value: analysis.adjustedIncome.asCurrency(countryCode: countryCode),
                color: purchasingPowerColor(analysis)
            )
            PreviewStatItem(
                label: "COL Index",
                value: String(format: "%.0f", analysis.costOfLivingIndex),
                color: .textSecondary
            )
        }
    }

    @ViewBuilder
    private var comparisonsPreview: some View {
        if let state = viewModel.stateComparison {
            HStack(spacing: 4) {
                Text("You're in the")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                Text("\(Int(state.percentile))th")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryAccent)
                Text("percentile")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var careerPathPreview: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let forecast = snapshot.careerForecast {
            VStack(alignment: .leading, spacing: 4) {
                Text("Peak at \(forecast.peakAge): \(forecast.peakIncome.asCurrency(countryCode: countryCode))")
                    .font(.caption)
                    .foregroundColor(.textPrimary)
            }
        }
    }

    @ViewBuilder
    private var careerInsightsPreview: some View {
        if let risk = viewModel.automationRisk {
            VStack(spacing: 8) {
                RiskBarPreview(icon: "🤖", label: "AI:", risk: risk.aiRisk, color: risk.aiRiskLevel.color)
                RiskBarPreview(icon: "🦾", label: "Robots:", risk: risk.roboticsRisk, color: risk.roboticsRiskLevel.color)
            }
        }
    }

    @ViewBuilder
    private var moreInsightsPreview: some View {
        if let snapshot = viewModel.statisticsSnapshot {
            Text("Gender gap, age group, and more")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }

    // Computed subtitles
    private var afterTaxSubtitle: String {
        guard let snapshot = viewModel.statisticsSnapshot,
              let afterTax = snapshot.afterTaxIncome else {
            return "Real take-home"
        }
        return afterTax.afterTaxIncome.asCurrency(countryCode: countryCode)
    }

    private func purchasingPowerSubtitle(_ analysis: PurchasingPowerAnalysis) -> String {
        return analysis.adjustedIncome.asCurrency(countryCode: countryCode)
    }

    private func purchasingPowerColor(_ analysis: PurchasingPowerAnalysis) -> Color {
        if analysis.costOfLivingIndex < 95 {
            return .green
        } else if analysis.costOfLivingIndex > 105 {
            return .orange
        } else {
            return .cyan
        }
    }

    private var comparisonsSubtitle: String {
        guard let state = viewModel.stateComparison else {
            return "vs 4 groups"
        }
        let percentile = Int(state.percentile)
        return "Top \(100 - percentile)%"
    }

    private var careerPathSubtitle: String {
        guard let snapshot = viewModel.statisticsSnapshot,
              let forecast = snapshot.careerForecast else {
            return "Future earnings"
        }
        return "Peak: \(forecast.peakIncome.asCurrency(countryCode: countryCode))"
    }

    private var careerInsightsSubtitle: String {
        guard let risk = viewModel.automationRisk else {
            return "AI & Automation"
        }
        return "Risk: \(Int(risk.overallRisk))% \(risk.overallRiskLevel.emoji)"
    }

    // Navigation destinations
    @ViewBuilder
    private var afterTaxDestination: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let afterTax = snapshot.afterTaxIncome {
            AfterTaxDetailView(afterTaxIncome: afterTax, userProfile: snapshot.userProfile)
        }
    }

    @ViewBuilder
    private var purchasingPowerDestination: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let purchasingPower = snapshot.purchasingPowerAnalysis {
            PurchasingPowerDetailView(analysis: purchasingPower, currencySymbol: currencySymbol)
        }
    }

    @ViewBuilder
    private var careerPathDestination: some View {
        if let snapshot = viewModel.statisticsSnapshot {
            CareerPathDetailView(snapshot: snapshot)
        }
    }

    @ViewBuilder
    private var careerInsightsDestination: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let risk = viewModel.automationRisk {
            CareerInsightsView(
                occupation: snapshot.userProfile.occupation,
                automationRisk: risk
            )
        }
    }


    // MARK: - After Tax Section

    @ViewBuilder
    private var afterTaxSection: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let afterTaxIncome = snapshot.afterTaxIncome {
            AfterTaxComparisonViewV2(
                afterTaxIncome: afterTaxIncome,
                currencySymbol: currencySymbol
            )
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }

    // MARK: - Career Path Section

    @ViewBuilder
    private var careerPathSection: some View {
        VStack(spacing: Theme.paddingMedium) {
            if let snapshot = viewModel.statisticsSnapshot {
                if let pathState = snapshot.pathToTop10State {
                    PathToTop10View(pathToTop10: pathState, title: "Path to Top 10% in State", currencySymbol: currencySymbol)
                }

                if let pathOccupation = snapshot.pathToTop10Occupation {
                    PathToTop10View(pathToTop10: pathOccupation, title: "Path to Top 10% in Profession", currencySymbol: currencySymbol)
                }

                if let careerForecast = snapshot.careerForecast {
                    CareerForecastView(careerForecast: careerForecast, currencySymbol: currencySymbol)
                }
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }


    // MARK: - Gender Comparison Section

    @ViewBuilder
    private var genderComparisonSection: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let genderComparison = snapshot.genderComparison,
           genderComparison.hasData {
            GenderComparisonView(genderComparison: genderComparison, currencySymbol: currencySymbol)
        }
    }

    // MARK: - State Ranking Section

    @ViewBuilder
    private var stateRankingSection: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let stateRanking = snapshot.stateRanking {
            StateRankingView(stateRanking: stateRanking, countryCode: countryCode)
        }
    }

    // MARK: - Similar Occupations Section

    @ViewBuilder
    private var similarOccupationsSection: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let similarOccupations = snapshot.similarOccupations,
           !similarOccupations.isEmpty {
            SimilarOccupationsView(similarOccupations: similarOccupations, countryCode: countryCode)
        }
    }

    // MARK: - Fun Facts Section

    @ViewBuilder
    private var funFactsSection: some View {
        if let snapshot = viewModel.statisticsSnapshot,
           let funFacts = snapshot.funFacts {
            FunFactsView(funFacts: funFacts)
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Data Sources")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)

            Text(viewModel.dataSourceAttribution)
                .font(.caption2)
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)

            Text("Data as of: \(viewModel.generatedDate, style: .date)")
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
        .padding(Theme.paddingMedium)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Theme.paddingLarge) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Calculating statistics...")
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Theme.paddingXLarge)
    }

    // MARK: - Helper Functions

    private func formatQuickStat(_ comparison: ComparisonResult) -> String {
        let percentDiff = ((comparison.userIncome - comparison.medianIncome) / comparison.medianIncome) * 100
        let sign = percentDiff >= 0 ? "+" : ""
        return "\(sign)\(Int(percentDiff))%"
    }

    private func incomeRangeText(for income: Double) -> String {
        // Create privacy-friendly income range
        let ranges: [(Double, Double, String)] = [
            (0, 25000, "\(currencySymbol)0 - \(currencySymbol)25K"),
            (25000, 35000, "\(currencySymbol)25K - \(currencySymbol)35K"),
            (35000, 50000, "\(currencySymbol)35K - \(currencySymbol)50K"),
            (50000, 75000, "\(currencySymbol)50K - \(currencySymbol)75K"),
            (75000, 100000, "\(currencySymbol)75K - \(currencySymbol)100K"),
            (100000, 150000, "\(currencySymbol)100K - \(currencySymbol)150K"),
            (150000, 200000, "\(currencySymbol)150K - \(currencySymbol)200K"),
            (200000, 250000, "\(currencySymbol)200K - \(currencySymbol)250K"),
            (250000, .infinity, "\(currencySymbol)250K+")
        ]

        for (min, max, label) in ranges {
            if income >= min && income < max {
                return label
            }
        }

        return "\(currencySymbol)0 - \(currencySymbol)25K"
    }

    // MARK: - Career Insights Preview Card

    private var careerInsightsPreviewCard: some View {
        NavigationLink(destination: careerInsightsDestination) {
            VStack(alignment: .leading, spacing: Theme.paddingMedium) {
                HStack {
                    Text("🔮")
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Career Insights")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        if let risk = viewModel.automationRisk {
                            HStack(spacing: 8) {
                                Text("Automation Risk:")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)

                                Text("\(Int(risk.overallRisk))%")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(risk.overallRiskLevel.color)

                                Text(risk.overallRiskLevel.emoji)
                                    .font(.caption)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.textTertiary)
                }

                if let risk = viewModel.automationRisk {
                    // Mini progress bars
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("🤖 AI:")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                                .frame(width: 50, alignment: .leading)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.2))

                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(risk.aiRiskLevel.color)
                                        .frame(width: geometry.size.width * (risk.aiRisk / 100))
                                }
                            }
                            .frame(height: 4)

                            Text("\(Int(risk.aiRisk))%")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                                .frame(width: 35, alignment: .trailing)
                        }

                        HStack(spacing: 8) {
                            Text("🦾 Robots:")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                                .frame(width: 50, alignment: .leading)

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.2))

                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(risk.roboticsRiskLevel.color)
                                        .frame(width: geometry.size.width * (risk.roboticsRisk / 100))
                                }
                            }
                            .frame(height: 4)

                            Text("\(Int(risk.roboticsRisk))%")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                                .frame(width: 35, alignment: .trailing)
                        }
                    }

                    Text("Tap for detailed analysis")
                        .font(.caption)
                        .foregroundColor(.primaryAccent)
                }
            }
            .padding(Theme.paddingMedium)
            .background(Color.cardBackground)
            .cornerRadius(Theme.cornerRadiusLarge)
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Stat Row

struct QuickStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
                .font(.body)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.textPrimary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(value.hasPrefix("+") ? .green : .red)
        }
    }
}

// MARK: - Action Card

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .fill(isExpanded ? color.opacity(0.1) : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .stroke(isExpanded ? color : Color.clear, lineWidth: 2)
            )
            .cardShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Stat Item

struct PreviewStatItem: View {
    let label: String
    let value: String
    var color: Color = .textPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.textSecondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Risk Bar Preview

struct RiskBarPreview: View {
    let icon: String
    let label: String
    let risk: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.caption)
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .frame(width: 45, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (risk / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)

            Text("\(Int(risk))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

// MARK: - Compact Stat Item

struct CompactStatItem: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(iconColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(valueColor)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var valueColor: Color {
        if value.hasPrefix("+") {
            return .green
        } else if value.hasPrefix("-") {
            return .red
        }
        return .textPrimary
    }
}

// MARK: - Badge Pill

struct BadgePill: View {
    let badge: Badge

    var body: some View {
        HStack(spacing: 6) {
            Text(badge.emoji)
                .font(.subheadline)

            Text(badge.title)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        StatisticsResultsView(viewModel: {
            let vm = StatisticsViewModel()
            return vm
        }())
    }
}

