//
//  AfterTaxDetailView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct AfterTaxDetailView: View {
    let afterTaxIncome: AfterTaxIncome
    let userProfile: UserProfile

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                // Reuse existing AfterTaxComparisonView
                AfterTaxComparisonView(afterTaxIncome: afterTaxIncome)
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
            afterTaxIncome: AfterTaxIncome(
                grossIncome: 100000,
                federalTax: 15000,
                stateTax: 5000,
                ficaTax: 7650,
                totalTax: 27650,
                afterTaxIncome: 72350,
                effectiveTaxRate: 27.65,
                state: .california
            ),
            userProfile: UserProfile()
        )
    }
}
