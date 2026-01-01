//
//  AfterTaxDetailView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct AfterTaxDetailView: View {
    let afterTaxIncome: AfterTaxIncomeResult
    let userProfile: UserProfile

    private var currencySymbol: String {
        switch userProfile.countryCode {
        case "us":
            return "$"
        case "uk":
            return "£"
        case "ca":
            return "C$"
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

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                // Use country-aware AfterTaxComparisonViewV2
                AfterTaxComparisonViewV2(
                    afterTaxIncome: afterTaxIncome,
                    currencySymbol: currencySymbol
                )
            }
            .padding()
        }
        .navigationTitle("After-Tax Income")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        AfterTaxDetailView(
            afterTaxIncome: AfterTaxIncomeResult(
                grossIncome: 100000,
                countryCode: "us",
                region: Region(code: "CA", name: "California", countryCode: "us"),
                components: [
                    TaxComponent(name: "Federal Tax", amount: 15000, rate: 15.0),
                    TaxComponent(name: "California State Tax", amount: 5000, rate: 5.0),
                    TaxComponent(name: "FICA", amount: 7650, rate: 7.65)
                ],
                totalTax: 27650,
                afterTaxIncome: 72350,
                effectiveTaxRate: 27.65
            ),
            userProfile: UserProfile()
        )
    }
}
