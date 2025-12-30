//
//  UserInputViewModel.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class UserInputViewModel: ObservableObject {
    @Published var userProfile = UserProfile()
    @Published var selectedCountry: Country?
    @Published var isFormValid = false
    @Published var validationErrors: [String: String] = [:]
    @Published var isLoading = false
    @Published var zipCodeLookupMessage: String = ""

    private let dataLoader: DataLoader
    private let zipCodeService: ZIPCodeService

    init(dataLoader: DataLoader = .shared, zipCodeService: ZIPCodeService = .shared) {
        self.dataLoader = dataLoader
        self.zipCodeService = zipCodeService
    }

    // MARK: - Country Management

    var availableCountries: [Country] {
        dataLoader.getAvailableCountries()
    }

    func setCountry(_ country: Country) async {
        selectedCountry = country
        userProfile.countryCode = country.code

        // Load country data if not already loaded
        if !dataLoader.isCountryDataLoaded(country.code) {
            isLoading = true
            do {
                try await dataLoader.loadCountryData(countryCode: country.code)
                dataLoader.setCurrentCountry(country.code)
            } catch {
                print("Error loading country data: \(error)")
            }
            isLoading = false
        } else {
            dataLoader.setCurrentCountry(country.code)
        }
    }

    // MARK: - Data Access

    var availableStates: [USState] {
        USState.allCases
    }

    var availableRegions: [Region] {
        dataLoader.getAllRegions(countryCode: userProfile.countryCode).map { regionData in
            Region(code: regionData.code, name: regionData.name, countryCode: regionData.countryCode ?? userProfile.countryCode)
        }
    }

    var availableOccupations: [OccupationCategory] {
        dataLoader.getAllOccupations(countryCode: userProfile.countryCode).map { occupation in
            OccupationCategory(
                socCode: occupation.socCode,
                title: occupation.title,
                category: occupation.category,
                countryCode: userProfile.countryCode
            )
        }
    }

    var occupationsByCategory: [String: [OccupationCategory]] {
        Dictionary(grouping: availableOccupations) { $0.category }
    }

    var occupationCategories: [String] {
        Array(occupationsByCategory.keys).sorted()
    }

    // MARK: - Validation

    func validateForm() {
        validationErrors.removeAll()

        // Validate ZIP code
        if userProfile.zipCode.trimmingCharacters(in: .whitespaces).isEmpty {
            validationErrors["zipCode"] = NSLocalizedString("error.zipCode.required", value: "ZIP code is required", comment: "")
        } else if !zipCodeService.isValidZIPCode(userProfile.zipCode) {
            validationErrors["zipCode"] = NSLocalizedString("error.zipCode.invalid", value: "Invalid ZIP code or not in our database", comment: "")
        }

        // Validate age
        if userProfile.age < 18 || userProfile.age > 100 {
            validationErrors["age"] = NSLocalizedString("error.age.range", value: "Age must be between 18 and 100", comment: "")
        }

        // Validate gender
        if userProfile.gender == .notSelected {
            validationErrors["gender"] = NSLocalizedString("error.gender.required", value: "Please select your gender", comment: "")
        }

        // Validate marital status
        if userProfile.maritalStatus == .notSelected {
            validationErrors["maritalStatus"] = NSLocalizedString("error.maritalStatus.required", value: "Please select your marital status", comment: "")
        }

        // Validate income based on marital status
        if userProfile.isMarried {
            // For married: validate BOTH personal and household income
            if userProfile.annualIncome <= 0 {
                validationErrors["income"] = NSLocalizedString("error.income.required", value: "Your personal income must be greater than 0", comment: "")
            } else if userProfile.annualIncome > 10_000_000 {
                validationErrors["income"] = NSLocalizedString("error.income.max", value: "Personal income seems unusually high", comment: "")
            }

            if userProfile.householdIncome <= 0 {
                validationErrors["householdIncome"] = NSLocalizedString("error.householdIncome.required", value: "Household income must be greater than 0", comment: "")
            } else if userProfile.householdIncome > 20_000_000 {
                validationErrors["householdIncome"] = NSLocalizedString("error.householdIncome.max", value: "Household income seems unusually high", comment: "")
            }
        } else {
            // For single/divorced/widowed: validate personal income only
            if userProfile.annualIncome <= 0 {
                validationErrors["income"] = NSLocalizedString("error.income.required", value: "Annual income must be greater than 0", comment: "")
            } else if userProfile.annualIncome > 10_000_000 {
                validationErrors["income"] = NSLocalizedString("error.income.max", value: "Annual income seems unusually high", comment: "")
            }
        }

        // Validate occupation
        if userProfile.occupation.socCode.isEmpty {
            validationErrors["occupation"] = NSLocalizedString("error.occupation.required", value: "Occupation is required", comment: "")
        }

        isFormValid = validationErrors.isEmpty
    }

    // MARK: - Form Helpers

    func updateZIPCode(_ zipCode: String) {
        userProfile.zipCode = zipCode
        zipCodeLookupMessage = ""

        // Auto-lookup city and state when ZIP code is 5 digits
        if zipCode.count == 5 {
            if let location = zipCodeService.lookup(zipCode: zipCode) {
                userProfile.city = location.city
                userProfile.state = location.state
                zipCodeLookupMessage = "\(location.city), \(location.state.rawValue)"
            } else {
                zipCodeLookupMessage = "ZIP code not found"
            }
        }

        validateForm()
    }

    func updateIncome(from text: String) {
        // Remove non-numeric characters except decimal point
        let filtered = text.filter { $0.isNumber || $0 == "." }
        if let value = Double(filtered) {
            userProfile.annualIncome = value
        } else if filtered.isEmpty {
            userProfile.annualIncome = 0
        }
        validateForm()
    }

    func updateAge(_ age: Int) {
        userProfile.age = max(18, min(100, age))
        validateForm()
    }

    func updateGender(_ gender: Gender) {
        userProfile.gender = gender
        validateForm()
    }

    func updateMaritalStatus(_ status: MaritalStatus) {
        userProfile.maritalStatus = status

        // Reset household fields when changing to not married
        if !userProfile.isMarried {
            userProfile.householdIncome = 0
            userProfile.numberOfChildren = 0
        } else {
            // When switching to married, set household income to at least personal income if not set
            if userProfile.householdIncome == 0 && userProfile.annualIncome > 0 {
                userProfile.householdIncome = userProfile.annualIncome
            }
        }

        validateForm()
    }

    func updateOccupation(_ occupation: OccupationCategory) {
        userProfile.occupation = occupation
        validateForm()
    }

    func updateHouseholdIncome(from text: String) {
        let filtered = text.filter { $0.isNumber || $0 == "." }
        if let value = Double(filtered) {
            userProfile.householdIncome = value
        } else if filtered.isEmpty {
            userProfile.householdIncome = 0
        }
        validateForm()
    }

    func updateNumberOfChildren(_ count: Int) {
        userProfile.numberOfChildren = max(0, min(20, count))
        validateForm()
    }

    // MARK: - Data Loading

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let loadAllData = dataLoader.loadAllData()
            async let loadZIPData = zipCodeService.loadData()

            try await loadAllData
            try await loadZIPData
        } catch {
            print("Failed to load data: \(error)")
        }
    }

    // MARK: - Progress Tracking

    var isLocationComplete: Bool {
        !userProfile.zipCode.isEmpty &&
        zipCodeService.isValidZIPCode(userProfile.zipCode)
    }

    var isDemographicsComplete: Bool {
        userProfile.age >= 18 &&
        userProfile.age <= 100 &&
        userProfile.gender != .notSelected &&
        userProfile.maritalStatus != .notSelected
    }

    var isIncomeComplete: Bool {
        if userProfile.isMarried {
            return userProfile.annualIncome > 0 &&
                   userProfile.householdIncome > 0 &&
                   userProfile.annualIncome <= 10_000_000 &&
                   userProfile.householdIncome <= 20_000_000
        } else {
            return userProfile.annualIncome > 0 &&
                   userProfile.annualIncome <= 10_000_000
        }
    }

    var isOccupationComplete: Bool {
        userProfile.occupation != nil
    }

    var completedSections: Int {
        var count = 0
        if isLocationComplete { count += 1 }
        if isDemographicsComplete { count += 1 }
        if isIncomeComplete { count += 1 }
        if isOccupationComplete { count += 1 }
        return count
    }

    var totalSections: Int { 4 }

    var formProgress: Double {
        Double(completedSections) / Double(totalSections)
    }

    var formProgressPercentage: Int {
        Int(formProgress * 100)
    }

    // MARK: - Reset

    func resetForm() {
        userProfile = UserProfile()
        validationErrors.removeAll()
        isFormValid = false
    }
}
