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
        asCurrency(symbol: "$")
    }

    /// Format as currency with custom symbol (e.g., £75,000)
    func asCurrency(symbol: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true

        let formattedNumber = formatter.string(from: NSNumber(value: self)) ?? "0"
        return "\(symbol)\(formattedNumber)"
    }

    /// Format as currency with country-specific symbol (e.g., $75,000, C$75,000, £75,000)
    func asCurrency(countryCode: String) -> String {
        let symbol = Self.currencySymbol(for: countryCode)
        return asCurrency(symbol: symbol)
    }

    /// Format as compact currency (e.g., $75K, $1.2M)
    var asCompactCurrency: String {
        asCompactCurrency(symbol: "$")
    }

    /// Format as compact currency with custom symbol (e.g., £75K, £1.2M)
    func asCompactCurrency(symbol: String) -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""

        switch absValue {
        case 1_000_000...:
            return String(format: "%@%@%.1fM", sign, symbol, absValue / 1_000_000)
        case 1_000...:
            return String(format: "%@%@%.0fK", sign, symbol, absValue / 1_000)
        default:
            return String(format: "%@%@%.0f", sign, symbol, absValue)
        }
    }

    /// Format as compact currency with country-specific symbol (e.g., $75K, C$75K, £75K)
    func asCompactCurrency(countryCode: String) -> String {
        let symbol = Self.currencySymbol(for: countryCode)
        return asCompactCurrency(symbol: symbol)
    }

    /// Get currency symbol for country code
    private static func currencySymbol(for countryCode: String) -> String {
        switch countryCode.lowercased() {
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
        case "de":
            return "€"
        default:
            return "$"
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
