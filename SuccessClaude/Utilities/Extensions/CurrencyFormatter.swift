//
//  CurrencyFormatter.swift
//  SuccessClaude
//
//  Created by Claude on 12/30/24.
//

import Foundation

extension Double {
    func formatted(currency: String, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0

        switch currency {
        case "USD":
            formatter.currencyCode = "USD"
            formatter.currencySymbol = "$"
        case "GBP":
            formatter.currencyCode = "GBP"
            formatter.currencySymbol = "£"
        case "CAD":
            formatter.currencyCode = "CAD"
            formatter.currencySymbol = "C$"
        case "AUD":
            formatter.currencyCode = "AUD"
            formatter.currencySymbol = "A$"
        case "EUR":
            formatter.currencyCode = "EUR"
            formatter.currencySymbol = "€"
        default:
            formatter.currencyCode = currency
        }

        return formatter.string(from: NSNumber(value: self)) ?? "\(currency) \(Int(self))"
    }

    func currencySymbol(for countryCode: String) -> String {
        switch countryCode {
        case "us": return "$"
        case "ca": return "C$"
        case "canada": return "C$"
        case "uk": return "£"
        case "au": return "A$"
        case "australia": return "A$"
        default: return "$"
        }
    }
}

extension String {
    func currencySymbol(for countryCode: String) -> String {
        switch countryCode {
        case "us": return "$"
        case "ca": return "C$"
        case "canada": return "C$"
        case "uk": return "£"
        case "au": return "A$"
        case "australia": return "A$"
        default: return "$"
        }
    }
}
