//
//  TaxCalculator.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

struct TaxCalculator {

    // MARK: - Tax Calculation

    static func calculateAfterTaxIncome(
        grossIncome: Double,
        state: USState,
        filingStatus: MaritalStatus
    ) -> AfterTaxIncome {

        let federalTax = calculateFederalTax(income: grossIncome, filingStatus: filingStatus)
        let stateTax = calculateStateTax(income: grossIncome, state: state, filingStatus: filingStatus)
        let ficaTax = calculateFICATax(income: grossIncome)

        let totalTax = federalTax + stateTax + ficaTax
        let afterTaxIncome = grossIncome - totalTax
        let effectiveTaxRate = grossIncome > 0 ? (totalTax / grossIncome) * 100 : 0

        return AfterTaxIncome(
            grossIncome: grossIncome,
            federalTax: federalTax,
            stateTax: stateTax,
            ficaTax: ficaTax,
            totalTax: totalTax,
            afterTaxIncome: afterTaxIncome,
            effectiveTaxRate: effectiveTaxRate,
            state: state
        )
    }

    // MARK: - Federal Tax (2024 Tax Brackets)

    private static func calculateFederalTax(income: Double, filingStatus: MaritalStatus) -> Double {
        let brackets: [(threshold: Double, rate: Double, base: Double)]

        if filingStatus == .married {
            // Married Filing Jointly 2024
            brackets = [
                (0, 0.10, 0),
                (22_000, 0.12, 2_200),
                (89_075, 0.22, 10_249),
                (190_750, 0.24, 32_617),
                (364_200, 0.32, 74_208),
                (462_500, 0.35, 105_664),
                (693_750, 0.37, 186_601)
            ]
        } else {
            // Single 2024
            brackets = [
                (0, 0.10, 0),
                (11_000, 0.12, 1_100),
                (44_725, 0.22, 5_147),
                (95_375, 0.24, 16_290),
                (182_100, 0.32, 37_104),
                (231_250, 0.35, 52_832),
                (578_125, 0.37, 174_238)
            ]
        }

        let standardDeduction = filingStatus == .married ? 29_200.0 : 14_600.0
        let taxableIncome = max(0, income - standardDeduction)

        var tax = 0.0
        for i in 0..<brackets.count {
            let bracket = brackets[i]
            if taxableIncome > bracket.threshold {
                if i < brackets.count - 1 {
                    let nextThreshold = brackets[i + 1].threshold
                    if taxableIncome > nextThreshold {
                        continue
                    } else {
                        tax = bracket.base + (taxableIncome - bracket.threshold) * bracket.rate
                        break
                    }
                } else {
                    tax = bracket.base + (taxableIncome - bracket.threshold) * bracket.rate
                    break
                }
            }
        }

        return tax
    }

    // MARK: - State Tax

    private static func calculateStateTax(income: Double, state: USState, filingStatus: MaritalStatus) -> Double {
        let rate = getStateTaxRate(state: state, income: income, filingStatus: filingStatus)
        return income * rate
    }

    private static func getStateTaxRate(state: USState, income: Double, filingStatus: MaritalStatus) -> Double {
        // Simplified state tax rates (2024 approximations)
        // For progressive states, using effective rate for median income ranges
        switch state {
        // No state income tax
        case .alaska, .florida, .nevada, .southDakota, .tennessee, .texas, .washington, .wyoming:
            return 0.0

        // Flat tax states
        case .colorado: return 0.044
        case .illinois: return 0.0495
        case .indiana: return 0.0315
        case .kentucky: return 0.045
        case .massachusetts: return 0.05
        case .michigan: return 0.0425
        case .newHampshire: return 0.0 // Only dividends/interest
        case .northCarolina: return 0.0475
        case .pennsylvania: return 0.0307
        case .utah: return 0.0485

        // Progressive tax states (simplified - using effective rate for $50k-150k range)
        case .alabama: return 0.04
        case .arizona: return income > 100_000 ? 0.045 : 0.035
        case .arkansas: return income > 100_000 ? 0.055 : 0.04
        case .california:
            if income > 150_000 { return 0.093 }
            else if income > 100_000 { return 0.08 }
            else if income > 75_000 { return 0.065 }
            else { return 0.04 }
        case .connecticut: return income > 100_000 ? 0.065 : 0.05
        case .delaware: return income > 100_000 ? 0.066 : 0.055
        case .georgia: return income > 100_000 ? 0.0575 : 0.05
        case .hawaii: return income > 100_000 ? 0.09 : 0.07
        case .idaho: return income > 100_000 ? 0.058 : 0.05
        case .iowa: return income > 100_000 ? 0.06 : 0.048
        case .kansas: return income > 100_000 ? 0.057 : 0.046
        case .louisiana: return 0.04
        case .maine: return income > 100_000 ? 0.075 : 0.06
        case .maryland: return income > 100_000 ? 0.0575 : 0.0475
        case .minnesota: return income > 100_000 ? 0.0985 : 0.07
        case .mississippi: return 0.05
        case .missouri: return 0.048
        case .montana: return income > 100_000 ? 0.0675 : 0.055
        case .nebraska: return income > 100_000 ? 0.0684 : 0.05
        case .newJersey: return income > 100_000 ? 0.0897 : 0.065
        case .newMexico: return income > 100_000 ? 0.059 : 0.045
        case .newYork:
            if income > 150_000 { return 0.0882 }
            else if income > 100_000 { return 0.065 }
            else { return 0.055 }
        case .northDakota: return 0.029
        case .ohio: return 0.038
        case .oklahoma: return 0.0475
        case .oregon: return income > 100_000 ? 0.099 : 0.075
        case .rhodeIsland: return income > 100_000 ? 0.0599 : 0.0475
        case .southCarolina: return income > 100_000 ? 0.065 : 0.055
        case .vermont: return income > 100_000 ? 0.0875 : 0.065
        case .virginia: return income > 100_000 ? 0.0575 : 0.05
        case .westVirginia: return income > 100_000 ? 0.065 : 0.055
        case .wisconsin: return income > 100_000 ? 0.0765 : 0.06
        case .districtOfColumbia: return income > 100_000 ? 0.0895 : 0.07
        }
    }

    // MARK: - FICA Tax (Social Security + Medicare)

    private static func calculateFICATax(income: Double) -> Double {
        let socialSecurityWageBase = 168_600.0 // 2024 limit
        let socialSecurityRate = 0.062
        let medicareRate = 0.0145
        let additionalMedicareThreshold = 200_000.0
        let additionalMedicareRate = 0.009

        // Social Security (capped)
        let socialSecurityTax = min(income, socialSecurityWageBase) * socialSecurityRate

        // Medicare (uncapped)
        var medicareTax = income * medicareRate

        // Additional Medicare tax for high earners
        if income > additionalMedicareThreshold {
            medicareTax += (income - additionalMedicareThreshold) * additionalMedicareRate
        }

        return socialSecurityTax + medicareTax
    }
}

// MARK: - Models

struct AfterTaxIncome {
    let grossIncome: Double
    let federalTax: Double
    let stateTax: Double
    let ficaTax: Double
    let totalTax: Double
    let afterTaxIncome: Double
    let effectiveTaxRate: Double
    let state: USState

    var stateTaxRate: Double {
        grossIncome > 0 ? (stateTax / grossIncome) * 100 : 0
    }

    var federalTaxRate: Double {
        grossIncome > 0 ? (federalTax / grossIncome) * 100 : 0
    }
}
