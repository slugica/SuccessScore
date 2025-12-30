//
//  Badge.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct Badge: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let category: BadgeCategory

    enum BadgeCategory {
        case percentile
        case career
        case geographic
        case financial
        case futureProof
    }
}

// MARK: - Badge Earning Logic

extension Badge {
    static func earnedBadges(from snapshot: StatisticsSnapshot, automationRisk: OccupationRisk?) -> [Badge] {
        var badges: [Badge] = []

        let percentile = snapshot.overallPercentile
        let userIncome = snapshot.userProfile.annualIncome
        let stateComparison = snapshot.stateComparison
        let occupationComparison = snapshot.occupationComparison
        let age = snapshot.userProfile.age

        // MARK: - Percentile Badges (always show one)

        if percentile >= 90 {
            badges.append(Badge(emoji: "👑", title: "Elite Earner", category: .percentile))
        } else if percentile >= 75 {
            badges.append(Badge(emoji: "⭐", title: "Top 25%", category: .percentile))
        } else if percentile >= 60 {
            badges.append(Badge(emoji: "💪", title: "Above Average", category: .percentile))
        } else if percentile >= 40 {
            badges.append(Badge(emoji: "📊", title: "Middle Class", category: .percentile))
        } else if percentile >= 25 {
            badges.append(Badge(emoji: "📉", title: "Below Average", category: .percentile))
        } else {
            badges.append(Badge(emoji: "📉", title: "Bottom Quarter", category: .percentile))
        }

        // MARK: - Career Badges

        // Top 10% in occupation
        if occupationComparison.percentile >= 90 {
            badges.append(Badge(emoji: "🏆", title: "Career Champion", category: .career))
        }

        // Early success (under 30 and above median)
        if age < 30 && percentile >= 50 {
            badges.append(Badge(emoji: "🚀", title: "Early Success", category: .career))
        }

        // Experience pays (45+ and above median)
        if age >= 45 && percentile >= 50 {
            badges.append(Badge(emoji: "🎓", title: "Experience Pays", category: .career))
        }

        // MARK: - Geographic Badges

        // State leader or local (always show state badge)
        if stateComparison.percentile >= 90 {
            badges.append(Badge(emoji: "🏅", title: "State Leader", category: .geographic))
        } else {
            // Always show which state you're from
            badges.append(Badge(emoji: "🗺️", title: "\(snapshot.userProfile.state.fullName) Local", category: .geographic))
        }

        // MARK: - Financial Badges

        // Six figure club
        if userIncome >= 100000 {
            badges.append(Badge(emoji: "💎", title: "Six Figure Club", category: .financial))
        }

        // Tax warrior (high earner)
        if let afterTax = snapshot.afterTaxIncome, afterTax.effectiveTaxRate >= 30 {
            badges.append(Badge(emoji: "⚔️", title: "Tax Warrior", category: .financial))
        }

        // MARK: - Future-Proof Badges

        if let risk = automationRisk {
            // Determine dominant threat (AI vs Robots)
            let aiRisk = risk.aiRisk
            let robotRisk = risk.roboticsRisk
            let difference = abs(aiRisk - robotRisk)

            // If one threat is significantly higher (>15% difference), show specific badge
            if difference > 15 {
                if aiRisk > robotRisk {
                    // AI is the dominant threat
                    if aiRisk >= 70 {
                        badges.append(Badge(emoji: "🤖", title: "High AI Risk", category: .futureProof))
                    } else if aiRisk >= 30 {
                        badges.append(Badge(emoji: "🤖", title: "Medium AI Risk", category: .futureProof))
                    } else {
                        badges.append(Badge(emoji: "🤖", title: "AI-Resistant", category: .futureProof))
                    }
                } else {
                    // Robots are the dominant threat
                    if robotRisk >= 70 {
                        badges.append(Badge(emoji: "🦾", title: "High Robot Risk", category: .futureProof))
                    } else if robotRisk >= 30 {
                        badges.append(Badge(emoji: "🦾", title: "Medium Robot Risk", category: .futureProof))
                    } else {
                        badges.append(Badge(emoji: "🦾", title: "Robot-Resistant", category: .futureProof))
                    }
                }
            } else {
                // Threats are similar, use overall risk
                if risk.overallRisk < 30 {
                    badges.append(Badge(emoji: "🛡️", title: "Low Automation Risk", category: .futureProof))
                } else if risk.overallRisk < 70 {
                    badges.append(Badge(emoji: "⚠️", title: "Medium Automation Risk", category: .futureProof))
                } else {
                    badges.append(Badge(emoji: "🔴", title: "High Automation Risk", category: .futureProof))
                }
            }
        }

        return selectTopBadges(from: badges)
    }

    // Select most relevant badges for sharing
    private static func selectTopBadges(from allBadges: [Badge]) -> [Badge] {
        var selected: [Badge] = []

        // 1. ALWAYS: Percentile badge (economic status)
        if let percentileBadge = allBadges.first(where: { $0.category == .percentile }) {
            selected.append(percentileBadge)
        }

        // 2. ALWAYS: Future-proof badge (AI risk)
        if let aiRiskBadge = allBadges.first(where: { $0.category == .futureProof }) {
            selected.append(aiRiskBadge)
        }

        // 3. OPTIONAL: Add career or financial highlights
        let extraBadges = allBadges.filter {
            $0.category == .career || $0.category == .financial
        }

        // Prioritize career over financial, add up to 2
        if let careerBadge = extraBadges.first(where: { $0.category == .career }) {
            selected.append(careerBadge)
        }

        if let financialBadge = extraBadges.first(where: { $0.category == .financial }) {
            selected.append(financialBadge)
        }

        return selected
    }
}
