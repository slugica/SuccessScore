//
//  SuccessScore.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct SuccessScore {
    let score: Double // 0-100 (percentile)

    // MARK: - Tier System

    enum Tier: String {
        case elite = "Elite"
        case upperMiddle = "Upper Middle"
        case middleClass = "Middle Class"
        case lowerMiddle = "Lower Middle"
        case workingPoor = "Working Poor"
        case lowIncome = "Low Income"

        var emoji: String {
            switch self {
            case .elite: return "👑"
            case .upperMiddle: return "⭐"
            case .middleClass: return "💪"
            case .lowerMiddle: return "📊"
            case .workingPoor: return "📉"
            case .lowIncome: return "📉"
            }
        }

        var color: Color {
            switch self {
            case .elite: return Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
            case .upperMiddle: return .green
            case .middleClass: return .blue
            case .lowerMiddle: return .orange
            case .workingPoor: return .purple
            case .lowIncome: return .red
            }
        }

        var gradient: LinearGradient {
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        var description: String {
            switch self {
            case .elite:
                return "Top 10% nationwide"
            case .upperMiddle:
                return "Top 25% nationwide"
            case .middleClass:
                return "Above median income"
            case .lowerMiddle:
                return "Around median income"
            case .workingPoor:
                return "Below average income"
            case .lowIncome:
                return "Bottom quarter income"
            }
        }

        var motivationalMessage: String {
            switch self {
            case .elite:
                return "You're among the best!"
            case .upperMiddle:
                return "Outstanding performance!"
            case .middleClass:
                return "Keep up the great work!"
            case .lowerMiddle:
                return "Room to grow!"
            case .workingPoor:
                return "You're on the right path!"
            case .lowIncome:
                return "Every journey starts here!"
            }
        }
    }

    var tier: Tier {
        switch score {
        case 90...100:
            return .elite
        case 75..<90:
            return .upperMiddle
        case 60..<75:
            return .middleClass
        case 40..<60:
            return .lowerMiddle
        case 25..<40:
            return .workingPoor
        default:
            return .lowIncome
        }
    }

    // MARK: - Display Helpers

    var scoreText: String {
        "\(Int(score))"
    }

    var fullTitle: String {
        "Success Score"
    }

    var tierBadge: String {
        "\(tier.emoji) \(tier.rawValue) Tier"
    }

    var percentileDescription: String {
        if score >= 50 {
            return "Top \(Int(100 - score))% nationwide"
        } else {
            return tier.description
        }
    }

    // MARK: - Progress to Next Tier

    var progressToNextTier: Double? {
        switch tier {
        case .lowIncome:
            return (score - 0) / (25 - 0) // 0-25
        case .workingPoor:
            return (score - 25) / (40 - 25) // 25-40
        case .lowerMiddle:
            return (score - 40) / (60 - 40) // 40-60
        case .middleClass:
            return (score - 60) / (75 - 60) // 60-75
        case .upperMiddle:
            return (score - 75) / (90 - 75) // 75-90
        case .elite:
            return nil // Already at top
        }
    }

    var nextTier: Tier? {
        switch tier {
        case .lowIncome: return .workingPoor
        case .workingPoor: return .lowerMiddle
        case .lowerMiddle: return .middleClass
        case .middleClass: return .upperMiddle
        case .upperMiddle: return .elite
        case .elite: return nil
        }
    }

    var pointsToNextTier: Int? {
        guard let next = nextTier else { return nil }

        let threshold: Double
        switch next {
        case .workingPoor: threshold = 25
        case .lowerMiddle: threshold = 40
        case .middleClass: threshold = 60
        case .upperMiddle: threshold = 75
        case .elite: threshold = 90
        case .lowIncome: threshold = 0
        }

        return Int(ceil(threshold - score))
    }

    var nextTierMessage: String? {
        guard let next = nextTier, let points = pointsToNextTier else {
            return nil
        }
        return "+\(points) points to reach \(next.emoji) \(next.rawValue)"
    }
}
