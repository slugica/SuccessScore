//
//  Color+Theme.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors

    static let primaryAccent = Color.blue

    static let successGreen = Color.green
    static let warningRed = Color.red
    static let neutralGray = Color.gray

    // MARK: - Background Colors

    static let cardBackground = Color(.systemGray6)
    static let secondaryBackground = Color(.systemGray5)
    static let tertiaryBackground = Color(.systemBackground)

    // MARK: - Text Colors

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Semantic Colors (for income comparisons)

    /// Color for above-median income (success)
    static let aboveMedian = Color.green.opacity(0.85)

    /// Color for below-median income (warning)
    static let belowMedian = Color.red.opacity(0.85)

    /// Color for at median income (neutral)
    static let atMedian = Color.orange.opacity(0.85)

    /// Gradient for positive comparison
    static var positiveGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Gradient for negative comparison
    static var negativeGradient: LinearGradient {
        LinearGradient(
            colors: [Color.red.opacity(0.3), Color.red.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Gradient for neutral comparison
    static var neutralGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Chart Colors

    static let chartPrimary = Color.blue
    static let chartSecondary = Color.purple
    static let chartTertiary = Color.orange
    static let chartAccent = Color.green

    /// Color palette for charts
    static var chartColors: [Color] {
        [.blue, .purple, .orange, .green, .pink, .indigo]
    }

    // MARK: - Percentile Colors

    /// Get color based on percentile (gradient from red to green)
    static func percentileColor(for percentile: Double) -> Color {
        switch percentile {
        case 0..<25:
            return .red.opacity(0.8)
        case 25..<50:
            return .orange.opacity(0.8)
        case 50..<75:
            return .blue.opacity(0.8)
        case 75..<90:
            return .green.opacity(0.8)
        default:
            return .green
        }
    }

    /// Get color for comparison result (above/below median)
    static func comparisonColor(isAboveMedian: Bool) -> Color {
        isAboveMedian ? .aboveMedian : .belowMedian
    }
}

// MARK: - Shadow Modifiers

extension View {
    /// Apply card shadow (subtle elevation)
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    /// Apply elevated shadow (more pronounced)
    func elevatedShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Theme Constants

struct Theme {
    // MARK: - Spacing

    static let paddingSmall: CGFloat = 8
    static let paddingMedium: CGFloat = 12
    static let paddingLarge: CGFloat = 16
    static let paddingXLarge: CGFloat = 24

    // MARK: - Corner Radius

    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16

    // MARK: - Icon Sizes

    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 24
    static let iconLarge: CGFloat = 32
    static let iconXLarge: CGFloat = 48
}
