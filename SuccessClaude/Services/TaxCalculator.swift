//
//  TaxCalculator.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

struct TaxCalculator {

    // MARK: - Tax Calculation (Country-Aware)

    static func calculateAfterTaxIncome(
        grossIncome: Double,
        countryCode: String,
        region: Region,
        filingStatus: MaritalStatus
    ) -> AfterTaxIncomeResult {

        switch countryCode {
        case "us":
            guard let usState = USState(rawValue: region.code) else {
                return createEmptyResult(grossIncome: grossIncome, countryCode: countryCode, region: region)
            }
            return calculateUSTax(grossIncome: grossIncome, state: usState, filingStatus: filingStatus)

        case "uk":
            return calculateUKTax(grossIncome: grossIncome, region: region)

        case "ca":
            return calculateCanadianTax(grossIncome: grossIncome, region: region)

        case "au":
            return calculateAustralianTax(grossIncome: grossIncome, region: region)

        case "nz":
            return calculateNewZealandTax(grossIncome: grossIncome, region: region)

        default:
            return createEmptyResult(grossIncome: grossIncome, countryCode: countryCode, region: region)
        }
    }

    // Legacy method for backward compatibility
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

    // MARK: - US Tax Calculation

    private static func calculateUSTax(
        grossIncome: Double,
        state: USState,
        filingStatus: MaritalStatus
    ) -> AfterTaxIncomeResult {
        let federalTax = calculateFederalTax(income: grossIncome, filingStatus: filingStatus)
        let stateTax = calculateStateTax(income: grossIncome, state: state, filingStatus: filingStatus)
        let ficaTax = calculateFICATax(income: grossIncome)

        let totalTax = federalTax + stateTax + ficaTax
        let afterTaxIncome = grossIncome - totalTax
        let effectiveTaxRate = grossIncome > 0 ? (totalTax / grossIncome) * 100 : 0

        return AfterTaxIncomeResult(
            grossIncome: grossIncome,
            countryCode: "us",
            region: Region(code: state.rawValue, name: state.fullName, countryCode: "us"),
            components: [
                TaxComponent(name: "Federal Tax", amount: federalTax, rate: grossIncome > 0 ? (federalTax / grossIncome) * 100 : 0),
                TaxComponent(name: "\(state.fullName) State Tax", amount: stateTax, rate: grossIncome > 0 ? (stateTax / grossIncome) * 100 : 0),
                TaxComponent(name: "FICA (Social Security & Medicare)", amount: ficaTax, rate: grossIncome > 0 ? (ficaTax / grossIncome) * 100 : 0)
            ],
            totalTax: totalTax,
            afterTaxIncome: afterTaxIncome,
            effectiveTaxRate: effectiveTaxRate
        )
    }

    // MARK: - UK Tax Calculation

    private static func calculateUKTax(
        grossIncome: Double,
        region: Region
    ) -> AfterTaxIncomeResult {
        let incomeTax = calculateUKIncomeTax(income: grossIncome)
        let nationalInsurance = calculateUKNationalInsurance(income: grossIncome)

        let totalTax = incomeTax + nationalInsurance
        let afterTaxIncome = grossIncome - totalTax
        let effectiveTaxRate = grossIncome > 0 ? (totalTax / grossIncome) * 100 : 0

        return AfterTaxIncomeResult(
            grossIncome: grossIncome,
            countryCode: "uk",
            region: region,
            components: [
                TaxComponent(name: "Income Tax", amount: incomeTax, rate: grossIncome > 0 ? (incomeTax / grossIncome) * 100 : 0),
                TaxComponent(name: "National Insurance (Class 1)", amount: nationalInsurance, rate: grossIncome > 0 ? (nationalInsurance / grossIncome) * 100 : 0)
            ],
            totalTax: totalTax,
            afterTaxIncome: afterTaxIncome,
            effectiveTaxRate: effectiveTaxRate
        )
    }

    private static func calculateUKIncomeTax(income: Double) -> Double {
        // UK Income Tax 2024/25 tax year
        let personalAllowance = 12_570.0
        let basicRateLimit = 50_270.0
        let higherRateLimit = 125_140.0

        let basicRate = 0.20
        let higherRate = 0.40
        let additionalRate = 0.45

        // Calculate taxable income
        let taxableIncome = max(0, income - personalAllowance)

        if taxableIncome == 0 {
            return 0
        }

        var tax = 0.0

        // Basic rate: £12,571 - £50,270 (20%)
        if taxableIncome <= basicRateLimit - personalAllowance {
            tax = taxableIncome * basicRate
        }
        // Higher rate: £50,271 - £125,140 (40%)
        else if income <= higherRateLimit {
            let basicRateTax = (basicRateLimit - personalAllowance) * basicRate
            let higherRateTax = (taxableIncome - (basicRateLimit - personalAllowance)) * higherRate
            tax = basicRateTax + higherRateTax
        }
        // Additional rate: £125,140+ (45%)
        else {
            let basicRateTax = (basicRateLimit - personalAllowance) * basicRate
            let higherRateTax = (higherRateLimit - basicRateLimit) * higherRate
            let additionalRateTax = (income - higherRateLimit) * additionalRate
            tax = basicRateTax + higherRateTax + additionalRateTax
        }

        return tax
    }

    private static func calculateUKNationalInsurance(income: Double) -> Double {
        // UK National Insurance Class 1 (employee) 2024/25
        let lowerEarningsLimit = 12_570.0
        let upperEarningsLimit = 50_270.0

        let standardRate = 0.12  // 12% on £12,571 - £50,270
        let additionalRate = 0.02  // 2% on £50,270+

        if income <= lowerEarningsLimit {
            return 0
        }

        var ni = 0.0

        if income <= upperEarningsLimit {
            // Standard rate only
            ni = (income - lowerEarningsLimit) * standardRate
        } else {
            // Standard rate up to upper limit + additional rate above
            let standardNI = (upperEarningsLimit - lowerEarningsLimit) * standardRate
            let additionalNI = (income - upperEarningsLimit) * additionalRate
            ni = standardNI + additionalNI
        }

        return ni
    }

    // MARK: - Canadian Tax Calculation

    private static func calculateCanadianTax(
        grossIncome: Double,
        region: Region
    ) -> AfterTaxIncomeResult {
        let federalTax = calculateCanadianFederalTax(income: grossIncome)
        let provincialTax = calculateProvincialTax(income: grossIncome, provinceCode: region.code)
        let cpp = calculateCPP(income: grossIncome)
        let ei = calculateEI(income: grossIncome)

        let totalTax = federalTax + provincialTax + cpp + ei
        let afterTaxIncome = grossIncome - totalTax
        let effectiveTaxRate = grossIncome > 0 ? (totalTax / grossIncome) * 100 : 0

        return AfterTaxIncomeResult(
            grossIncome: grossIncome,
            countryCode: "ca",
            region: region,
            components: [
                TaxComponent(name: "Federal Tax", amount: federalTax, rate: grossIncome > 0 ? (federalTax / grossIncome) * 100 : 0),
                TaxComponent(name: "\(region.name) Provincial Tax", amount: provincialTax, rate: grossIncome > 0 ? (provincialTax / grossIncome) * 100 : 0),
                TaxComponent(name: "CPP (Canada Pension Plan)", amount: cpp, rate: grossIncome > 0 ? (cpp / grossIncome) * 100 : 0),
                TaxComponent(name: "EI (Employment Insurance)", amount: ei, rate: grossIncome > 0 ? (ei / grossIncome) * 100 : 0)
            ],
            totalTax: totalTax,
            afterTaxIncome: afterTaxIncome,
            effectiveTaxRate: effectiveTaxRate
        )
    }

    private static func calculateCanadianFederalTax(income: Double) -> Double {
        // Canadian Federal Tax Brackets 2024
        let basicPersonalAmount = 15_000.0
        let taxableIncome = max(0, income - basicPersonalAmount)

        if taxableIncome == 0 {
            return 0
        }

        var tax = 0.0

        // Federal tax brackets 2024
        // 15% on first $55,867
        // 20.5% on next $55,867 ($55,867 - $111,733)
        // 26% on next $49,443 ($111,733 - $173,205)
        // 29% on next $73,608 ($173,205 - $246,752)
        // 33% on income over $246,752

        if taxableIncome <= 55_867 {
            tax = taxableIncome * 0.15
        } else if taxableIncome <= 111_733 {
            let bracket1 = 55_867 * 0.15
            let bracket2 = (taxableIncome - 55_867) * 0.205
            tax = bracket1 + bracket2
        } else if taxableIncome <= 173_205 {
            let bracket1 = 55_867 * 0.15
            let bracket2 = 55_866 * 0.205
            let bracket3 = (taxableIncome - 111_733) * 0.26
            tax = bracket1 + bracket2 + bracket3
        } else if taxableIncome <= 246_752 {
            let bracket1 = 55_867 * 0.15
            let bracket2 = 55_866 * 0.205
            let bracket3 = 61_472 * 0.26
            let bracket4 = (taxableIncome - 173_205) * 0.29
            tax = bracket1 + bracket2 + bracket3 + bracket4
        } else {
            let bracket1 = 55_867 * 0.15
            let bracket2 = 55_866 * 0.205
            let bracket3 = 61_472 * 0.26
            let bracket4 = 73_547 * 0.29
            let bracket5 = (taxableIncome - 246_752) * 0.33
            tax = bracket1 + bracket2 + bracket3 + bracket4 + bracket5
        }

        return tax
    }

    private static func calculateProvincialTax(income: Double, provinceCode: String) -> Double {
        // Provincial tax rates 2024 (simplified)
        let rate = getProvincialTaxRate(provinceCode: provinceCode, income: income)

        // Apply basic personal amount deduction (varies by province)
        let basicAmount = getProvincialBasicAmount(provinceCode: provinceCode)
        let taxableIncome = max(0, income - basicAmount)

        return taxableIncome * rate
    }

    private static func getProvincialTaxRate(provinceCode: String, income: Double) -> Double {
        // Provincial tax rates 2024 (simplified effective rates)
        switch provinceCode.uppercased() {
        case "AB": // Alberta
            if income <= 142_292 {
                return 0.10
            } else if income <= 170_751 {
                return 0.12
            } else if income <= 227_668 {
                return 0.13
            } else if income <= 341_502 {
                return 0.14
            } else {
                return 0.15
            }

        case "BC": // British Columbia
            if income <= 47_937 {
                return 0.0506
            } else if income <= 95_875 {
                return 0.077
            } else if income <= 110_076 {
                return 0.105
            } else if income <= 133_664 {
                return 0.1229
            } else if income <= 181_232 {
                return 0.147
            } else if income <= 252_752 {
                return 0.168
            } else {
                return 0.205
            }

        case "MB": // Manitoba
            if income <= 47_000 {
                return 0.108
            } else if income <= 100_000 {
                return 0.1275
            } else {
                return 0.174
            }

        case "NB": // New Brunswick
            if income <= 49_958 {
                return 0.094
            } else if income <= 99_916 {
                return 0.14
            } else if income <= 185_064 {
                return 0.16
            } else {
                return 0.195
            }

        case "NL": // Newfoundland and Labrador
            if income <= 43_198 {
                return 0.087
            } else if income <= 86_395 {
                return 0.145
            } else if income <= 154_244 {
                return 0.158
            } else if income <= 215_943 {
                return 0.178
            } else {
                return 0.208
            }

        case "NS": // Nova Scotia
            if income <= 29_590 {
                return 0.0879
            } else if income <= 59_180 {
                return 0.1495
            } else if income <= 93_000 {
                return 0.1667
            } else if income <= 150_000 {
                return 0.175
            } else {
                return 0.21
            }

        case "NT": // Northwest Territories
            if income <= 50_597 {
                return 0.059
            } else if income <= 101_198 {
                return 0.086
            } else if income <= 164_525 {
                return 0.122
            } else {
                return 0.1405
            }

        case "NU": // Nunavut
            if income <= 53_268 {
                return 0.04
            } else if income <= 106_537 {
                return 0.07
            } else if income <= 173_205 {
                return 0.09
            } else {
                return 0.115
            }

        case "ON": // Ontario
            if income <= 51_446 {
                return 0.0505
            } else if income <= 102_894 {
                return 0.0915
            } else if income <= 150_000 {
                return 0.1116
            } else if income <= 220_000 {
                return 0.1216
            } else {
                return 0.1316
            }

        case "PE": // Prince Edward Island
            if income <= 32_656 {
                return 0.098
            } else if income <= 64_313 {
                return 0.138
            } else if income <= 105_000 {
                return 0.167
            } else {
                return 0.187
            }

        case "QC": // Quebec
            if income <= 51_780 {
                return 0.14
            } else if income <= 103_545 {
                return 0.19
            } else if income <= 126_000 {
                return 0.24
            } else {
                return 0.2575
            }

        case "SK": // Saskatchewan
            if income <= 52_057 {
                return 0.105
            } else if income <= 148_734 {
                return 0.125
            } else {
                return 0.145
            }

        case "YT": // Yukon
            if income <= 55_867 {
                return 0.064
            } else if income <= 111_733 {
                return 0.09
            } else if income <= 173_205 {
                return 0.109
            } else if income <= 500_000 {
                return 0.128
            } else {
                return 0.15
            }

        default:
            return 0.10 // Default fallback
        }
    }

    private static func getProvincialBasicAmount(provinceCode: String) -> Double {
        // Provincial basic personal amounts 2024
        switch provinceCode.uppercased() {
        case "AB": return 21_885
        case "BC": return 12_580
        case "MB": return 15_000
        case "NB": return 13_044
        case "NL": return 10_382
        case "NS": return 8_744
        case "NT": return 16_593
        case "NU": return 18_767
        case "ON": return 11_865
        case "PE": return 13_500
        case "QC": return 17_183
        case "SK": return 17_661
        case "YT": return 15_000
        default: return 15_000
        }
    }

    private static func calculateCPP(income: Double) -> Double {
        // CPP 2024: 5.95% on income between $3,500 and $68,500
        let exemption = 3_500.0
        let maximum = 68_500.0
        let rate = 0.0595

        if income <= exemption {
            return 0
        }

        let contributoryIncome = min(income, maximum) - exemption
        return contributoryIncome * rate
    }

    private static func calculateEI(income: Double) -> Double {
        // EI 2024: 1.66% on income up to $63,200
        let maximum = 63_200.0
        let rate = 0.0166

        let insurableIncome = min(income, maximum)
        return insurableIncome * rate
    }

    // MARK: - Australian Tax Calculation

    private static func calculateAustralianTax(
        grossIncome: Double,
        region: Region
    ) -> AfterTaxIncomeResult {
        let federalTax = calculateAustralianFederalTax(income: grossIncome)
        let medicareLevy = calculateMedicareLevy(income: grossIncome)

        let totalTax = federalTax + medicareLevy
        let afterTaxIncome = grossIncome - totalTax
        let effectiveTaxRate = grossIncome > 0 ? (totalTax / grossIncome) * 100 : 0

        return AfterTaxIncomeResult(
            grossIncome: grossIncome,
            countryCode: "au",
            region: region,
            components: [
                TaxComponent(name: "Federal Tax", amount: federalTax, rate: grossIncome > 0 ? (federalTax / grossIncome) * 100 : 0),
                TaxComponent(name: "Medicare Levy", amount: medicareLevy, rate: grossIncome > 0 ? (medicareLevy / grossIncome) * 100 : 0)
            ],
            totalTax: totalTax,
            afterTaxIncome: afterTaxIncome,
            effectiveTaxRate: effectiveTaxRate
        )
    }

    private static func calculateAustralianFederalTax(income: Double) -> Double {
        // Australian Federal Tax Brackets 2024-25
        // $0 - $18,200: 0% (tax-free threshold)
        // $18,201 - $45,000: 16% on income over $18,200
        // $45,001 - $135,000: $4,288 + 30% on income over $45,000
        // $135,001 - $190,000: $31,288 + 37% on income over $135,000
        // $190,001+: $51,638 + 45% on income over $190,000

        if income <= 18_200 {
            return 0
        } else if income <= 45_000 {
            return (income - 18_200) * 0.16
        } else if income <= 135_000 {
            let bracket1 = (45_000 - 18_200) * 0.16
            let bracket2 = (income - 45_000) * 0.30
            return bracket1 + bracket2
        } else if income <= 190_000 {
            let bracket1 = (45_000 - 18_200) * 0.16
            let bracket2 = (135_000 - 45_000) * 0.30
            let bracket3 = (income - 135_000) * 0.37
            return bracket1 + bracket2 + bracket3
        } else {
            let bracket1 = (45_000 - 18_200) * 0.16
            let bracket2 = (135_000 - 45_000) * 0.30
            let bracket3 = (190_000 - 135_000) * 0.37
            let bracket4 = (income - 190_000) * 0.45
            return bracket1 + bracket2 + bracket3 + bracket4
        }
    }

    private static func calculateMedicareLevy(income: Double) -> Double {
        // Medicare Levy 2024-25: 2% of taxable income
        // Low income threshold: $26,000 (singles), $41,089 (families)
        // For simplicity, we'll apply the 2% levy to all income
        return income * 0.02
    }

    // MARK: - New Zealand Tax Calculation

    private static func calculateNewZealandTax(
        grossIncome: Double,
        region: Region
    ) -> AfterTaxIncomeResult {
        let incomeTax = calculateNZIncomeTax(income: grossIncome)
        let accLevy = calculateNZACCLevy(income: grossIncome)

        let totalTax = incomeTax + accLevy
        let afterTaxIncome = grossIncome - totalTax
        let effectiveTaxRate = grossIncome > 0 ? (totalTax / grossIncome) * 100 : 0

        return AfterTaxIncomeResult(
            grossIncome: grossIncome,
            countryCode: "nz",
            region: region,
            components: [
                TaxComponent(name: "PAYE Income Tax", amount: incomeTax, rate: grossIncome > 0 ? (incomeTax / grossIncome) * 100 : 0),
                TaxComponent(name: "ACC Earner Levy", amount: accLevy, rate: grossIncome > 0 ? (accLevy / grossIncome) * 100 : 0)
            ],
            totalTax: totalTax,
            afterTaxIncome: afterTaxIncome,
            effectiveTaxRate: effectiveTaxRate
        )
    }

    private static func calculateNZIncomeTax(income: Double) -> Double {
        // New Zealand PAYE Tax Brackets 2024-25
        // $0 - $14,000: 10.5%
        // $14,001 - $48,000: 17.5%
        // $48,001 - $70,000: 30%
        // $70,001 - $180,000: 33%
        // $180,001+: 39%

        if income <= 14_000 {
            return income * 0.105
        } else if income <= 48_000 {
            let bracket1 = 14_000 * 0.105
            let bracket2 = (income - 14_000) * 0.175
            return bracket1 + bracket2
        } else if income <= 70_000 {
            let bracket1 = 14_000 * 0.105
            let bracket2 = (48_000 - 14_000) * 0.175
            let bracket3 = (income - 48_000) * 0.30
            return bracket1 + bracket2 + bracket3
        } else if income <= 180_000 {
            let bracket1 = 14_000 * 0.105
            let bracket2 = (48_000 - 14_000) * 0.175
            let bracket3 = (70_000 - 48_000) * 0.30
            let bracket4 = (income - 70_000) * 0.33
            return bracket1 + bracket2 + bracket3 + bracket4
        } else {
            let bracket1 = 14_000 * 0.105
            let bracket2 = (48_000 - 14_000) * 0.175
            let bracket3 = (70_000 - 48_000) * 0.30
            let bracket4 = (180_000 - 70_000) * 0.33
            let bracket5 = (income - 180_000) * 0.39
            return bracket1 + bracket2 + bracket3 + bracket4 + bracket5
        }
    }

    private static func calculateNZACCLevy(income: Double) -> Double {
        // ACC Earner Levy 2024-25: 1.39% on earnings up to $142,283
        let maxEarnings = 142_283.0
        let rate = 0.0139

        let leviableIncome = min(income, maxEarnings)
        return leviableIncome * rate
    }

    // MARK: - Helper

    private static func createEmptyResult(grossIncome: Double, countryCode: String, region: Region) -> AfterTaxIncomeResult {
        return AfterTaxIncomeResult(
            grossIncome: grossIncome,
            countryCode: countryCode,
            region: region,
            components: [],
            totalTax: 0,
            afterTaxIncome: grossIncome,
            effectiveTaxRate: 0
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

// Legacy US-only model for backward compatibility
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

// Universal country-aware model
struct AfterTaxIncomeResult {
    let grossIncome: Double
    let countryCode: String
    let region: Region
    let components: [TaxComponent]
    let totalTax: Double
    let afterTaxIncome: Double
    let effectiveTaxRate: Double

    var componentsSummary: String {
        components.map { "\($0.name): \(String(format: "%.1f%%", $0.rate))" }.joined(separator: ", ")
    }
}

struct TaxComponent {
    let name: String
    let amount: Double
    let rate: Double  // Percentage
}
