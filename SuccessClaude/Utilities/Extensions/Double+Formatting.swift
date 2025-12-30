//
//  Double+Formatting.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

extension Double {
    /// Format as currency (e.g., $75,000)
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }

    /// Format as compact currency (e.g., $75K, $1.2M)
    var asCompactCurrency: String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""

        switch absValue {
        case 1_000_000...:
            return String(format: "%@$%.1fM", sign, absValue / 1_000_000)
        case 1_000...:
            return String(format: "%@$%.0fK", sign, absValue / 1_000)
        default:
            return String(format: "%@$%.0f", sign, absValue)
        }
    }

    /// Format as percentage (e.g., 75.5%)
    var asPercentage: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0%"
    }

    /// Format as signed percentage (e.g., +15.2%, -8.3%)
    var asSignedPercentage: String {
        let sign = self >= 0 ? "+" : ""
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.positivePrefix = "+"
        return formatter.string(from: NSNumber(value: self / 100)) ?? "0%"
    }

    /// Format as decimal (e.g., 1,234.56)
    var asDecimal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "0"
    }

    /// Format as ordinal percentile (e.g., "75th", "92nd")
    var asOrdinalPercentile: String {
        let rounded = Int(self.rounded())
        let suffix: String

        switch rounded % 100 {
        case 11, 12, 13:
            suffix = "th"
        default:
            switch rounded % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }

        return "\(rounded)\(suffix)"
    }

    /// Format income range (e.g., "$50K - $75K")
    static func formatRange(low: Double, high: Double) -> String {
        return "\(low.asCompactCurrency) - \(high.asCompactCurrency)"
    }
}

extension Int {
    /// Format as ordinal (e.g., "1st", "2nd", "3rd")
    var asOrdinal: String {
        let suffix: String

        switch self % 100 {
        case 11, 12, 13:
            suffix = "th"
        default:
            switch self % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }

        return "\(self)\(suffix)"
    }

    /// Format with thousands separator (e.g., "1,234")
    var withCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
