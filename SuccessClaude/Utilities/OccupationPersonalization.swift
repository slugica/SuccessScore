//
//  OccupationPersonalization.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

struct OccupationPersonalization {

    // MARK: - Emoji Mapping

    static func getEmoji(for category: String) -> String {
        // Map BLS OEWS categories to emojis
        let categoryLower = category.lowercased()

        if categoryLower.contains("computer") || categoryLower.contains("software") || categoryLower.contains("mathematical") {
            return "👨‍💻"
        } else if categoryLower.contains("healthcare") || categoryLower.contains("medical") || categoryLower.contains("physician") || categoryLower.contains("nurse") {
            return "👨‍⚕️"
        } else if categoryLower.contains("construction") || categoryLower.contains("extraction") {
            return "👷‍♂️"
        } else if categoryLower.contains("food") || categoryLower.contains("chef") || categoryLower.contains("cook") {
            return "👨‍🍳"
        } else if categoryLower.contains("education") || categoryLower.contains("teacher") || categoryLower.contains("training") {
            return "👨‍🏫"
        } else if categoryLower.contains("business") || categoryLower.contains("financial") || categoryLower.contains("management") {
            return "💼"
        } else if categoryLower.contains("legal") || categoryLower.contains("lawyer") {
            return "⚖️"
        } else if categoryLower.contains("arts") || categoryLower.contains("design") || categoryLower.contains("entertainment") || categoryLower.contains("media") {
            return "🎨"
        } else if categoryLower.contains("sales") {
            return "🤝"
        } else if categoryLower.contains("protective service") || categoryLower.contains("police") || categoryLower.contains("firefighter") {
            return "👮‍♂️"
        } else if categoryLower.contains("transportation") || categoryLower.contains("driver") {
            return "🚗"
        } else if categoryLower.contains("production") || categoryLower.contains("manufacturing") {
            return "🏭"
        } else if categoryLower.contains("architecture") || categoryLower.contains("engineering") {
            return "🏗️"
        } else if categoryLower.contains("science") || categoryLower.contains("life") || categoryLower.contains("physical") {
            return "🔬"
        } else if categoryLower.contains("community") || categoryLower.contains("social service") {
            return "🤲"
        } else if categoryLower.contains("office") || categoryLower.contains("administrative") {
            return "📋"
        } else if categoryLower.contains("installation") || categoryLower.contains("maintenance") || categoryLower.contains("repair") {
            return "🔧"
        } else if categoryLower.contains("farming") || categoryLower.contains("fishing") || categoryLower.contains("forestry") {
            return "🌾"
        } else if categoryLower.contains("personal care") || categoryLower.contains("service") {
            return "💆‍♂️"
        } else if categoryLower.contains("building") || categoryLower.contains("cleaning") {
            return "🧹"
        } else {
            return "💼" // Default
        }
    }

    // MARK: - SF Symbol Mapping (alternative/backup)

    static func getSFSymbol(for category: String) -> String {
        let categoryLower = category.lowercased()

        if categoryLower.contains("computer") || categoryLower.contains("software") || categoryLower.contains("mathematical") {
            return "laptopcomputer"
        } else if categoryLower.contains("healthcare") || categoryLower.contains("medical") {
            return "cross.case.fill"
        } else if categoryLower.contains("construction") {
            return "hammer.fill"
        } else if categoryLower.contains("food") {
            return "fork.knife"
        } else if categoryLower.contains("education") || categoryLower.contains("teacher") {
            return "book.fill"
        } else if categoryLower.contains("business") || categoryLower.contains("financial") {
            return "chart.line.uptrend.xyaxis"
        } else if categoryLower.contains("legal") {
            return "scale.3d"
        } else if categoryLower.contains("arts") || categoryLower.contains("design") {
            return "paintpalette.fill"
        } else if categoryLower.contains("sales") {
            return "cart.fill"
        } else if categoryLower.contains("protective service") {
            return "shield.fill"
        } else if categoryLower.contains("transportation") {
            return "car.fill"
        } else if categoryLower.contains("production") {
            return "gearshape.fill"
        } else if categoryLower.contains("architecture") || categoryLower.contains("engineering") {
            return "building.2.fill"
        } else if categoryLower.contains("science") {
            return "testtube.2"
        } else {
            return "briefcase.fill"
        }
    }

    // MARK: - Personalized Messages

    static func getPersonalizedMessage(percentile: Double, category: String, occupationTitle: String) -> String {
        let categoryLower = category.lowercased()
        let roundedPercentile = Int(percentile)

        // Determine achievement level
        let isTopTier = percentile >= 90
        let isAboveAverage = percentile >= 60

        // Category-specific phrases
        if categoryLower.contains("computer") || categoryLower.contains("software") {
            if isTopTier {
                return "Outstanding among tech professionals"
            } else if isAboveAverage {
                return "Strong performer in the tech industry"
            } else {
                return "Growing in the tech sector"
            }
        } else if categoryLower.contains("healthcare") || categoryLower.contains("medical") {
            if isTopTier {
                return "Top earner in healthcare"
            } else if isAboveAverage {
                return "Solid healthcare professional"
            } else {
                return "Building your healthcare career"
            }
        } else if categoryLower.contains("education") || categoryLower.contains("teacher") {
            if isTopTier {
                return "Leading educator compensation"
            } else if isAboveAverage {
                return "Above average for educators"
            } else {
                return "Dedicated to education"
            }
        } else if categoryLower.contains("construction") {
            if isTopTier {
                return "Master of your trade"
            } else if isAboveAverage {
                return "Skilled tradesperson"
            } else {
                return "Building your future"
            }
        } else if categoryLower.contains("business") || categoryLower.contains("management") {
            if isTopTier {
                return "Executive-level earnings"
            } else if isAboveAverage {
                return "Successful business professional"
            } else {
                return "Advancing in business"
            }
        } else if categoryLower.contains("food") {
            if isTopTier {
                return "Top chef earnings"
            } else if isAboveAverage {
                return "Thriving culinary professional"
            } else {
                return "Cooking up success"
            }
        } else if categoryLower.contains("legal") {
            if isTopTier {
                return "Elite legal earnings"
            } else if isAboveAverage {
                return "Successful legal career"
            } else {
                return "Building your practice"
            }
        } else if categoryLower.contains("arts") || categoryLower.contains("design") {
            if isTopTier {
                return "Top creative earner"
            } else if isAboveAverage {
                return "Thriving creative professional"
            } else {
                return "Creating your success"
            }
        } else if categoryLower.contains("sales") {
            if isTopTier {
                return "Sales superstar"
            } else if isAboveAverage {
                return "High-performing sales pro"
            } else {
                return "Growing your pipeline"
            }
        } else if categoryLower.contains("science") {
            if isTopTier {
                return "Leading scientific researcher"
            } else if isAboveAverage {
                return "Accomplished scientist"
            } else {
                return "Advancing scientific knowledge"
            }
        } else if categoryLower.contains("engineering") {
            if isTopTier {
                return "Elite engineering talent"
            } else if isAboveAverage {
                return "Strong engineering career"
            } else {
                return "Building solutions"
            }
        } else {
            // Generic messages
            if isTopTier {
                return "Top earner in your field"
            } else if isAboveAverage {
                return "Above average in your profession"
            } else {
                return "Building your career path"
            }
        }
    }

    // MARK: - Congratulatory Title

    static func getCongratulatoryTitle(percentile: Double) -> String {
        if percentile >= 95 {
            return "🎉 Exceptional!"
        } else if percentile >= 90 {
            return "🌟 Outstanding!"
        } else if percentile >= 75 {
            return "💪 Great Job!"
        } else if percentile >= 60 {
            return "👍 Doing Well!"
        } else if percentile >= 50 {
            return "📈 Keep Growing!"
        } else {
            return "🚀 On Your Way!"
        }
    }
}
