//
//  UserInputFormView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct UserInputFormView: View {
    @StateObject private var viewModel = UserInputViewModel()
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @State private var navigateToResults = false
    @State private var showOccupationPicker = false
    @FocusState private var isInputFocused: Bool

    @State private var personalIncomeText = ""
    @State private var householdIncomeText = ""
    @State private var hasEditedZipCode = false
    @State private var hasSelectedOccupation = false
    @State private var hasEditedDemographics = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            if viewModel.selectedCountry == nil {
                // Step 1: Country Selection
                countrySelectionView
            } else {
                // Step 2: Main Form
                VStack(spacing: 0) {
                    // Progress bar
                    progressBar

                    ZStack {
                        formContent

                        NavigationLink(destination: StatisticsResultsView(viewModel: statisticsViewModel), isActive: $navigateToResults) {
                            EmptyView()
                        }
                    }
                }
                .navigationTitle("Income Comparison")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Change Country") {
                            viewModel.selectedCountry = nil
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .alert("Data Not Available", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var countrySelectionView: some View {
        ZStack {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                    Text("Loading data...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            } else {
                CountryPickerView(
                    selectedCountry: $viewModel.selectedCountry,
                    countries: viewModel.availableCountries
                )
                .onChange(of: viewModel.selectedCountry) { newCountry in
                    if let country = newCountry {
                        Task {
                            await viewModel.setCountry(country)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Country")
        .navigationBarTitleDisplayMode(.large)
    }

    private var formContent: some View {
        Form {
            locationSection
            demographicsSection
            incomeSection
            occupationSection
            submitButton
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            isInputFocused = false
        }
        .sheet(isPresented: $showOccupationPicker) {
            OccupationPickerView(
                selectedOccupation: $viewModel.userProfile.occupation,
                viewModel: viewModel
            )
        }
        .onChange(of: showOccupationPicker) { isShowing in
            if !isShowing {
                // Sheet закрылся - убираем клавиатуру
                isInputFocused = false
            }
        }
        .onChange(of: viewModel.userProfile.occupation.socCode) { newValue in
            if !newValue.isEmpty {
                hasSelectedOccupation = true
            }
        }
    }

    // MARK: - Sections

    private var locationSection: some View {
        Section {
            if viewModel.userProfile.countryCode == "us" {
                // US: ZIP Code lookup
                TextField("92694", text: $viewModel.userProfile.zipCode)
                    .keyboardType(.numberPad)
                    .onChange(of: viewModel.userProfile.zipCode) { newValue in
                        hasEditedZipCode = true
                        viewModel.updateZIPCode(newValue)
                    }

                if !viewModel.zipCodeLookupMessage.isEmpty {
                    HStack {
                        Image(systemName: viewModel.zipCodeLookupMessage == "ZIP code not found" ? "xmark.circle.fill" : "checkmark.circle.fill")
                            .foregroundColor(viewModel.zipCodeLookupMessage == "ZIP code not found" ? .red : .green)

                        Text(viewModel.zipCodeLookupMessage)
                            .font(.caption)
                            .foregroundColor(viewModel.zipCodeLookupMessage == "ZIP code not found" ? .red : .green)
                    }
                }

                if hasEditedZipCode, viewModel.userProfile.zipCode.count >= 5, let error = viewModel.validationErrors["zipCode"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            } else {
                // UK and other countries: Manual region selection
                NavigationLink {
                    RegionPickerView(
                        selectedRegion: Binding(
                            get: { viewModel.userProfile.region },
                            set: { if let newRegion = $0 { viewModel.userProfile.region = newRegion } }
                        ),
                        regions: viewModel.availableRegions,
                        regionType: viewModel.selectedCountry?.regionType ?? "Region"
                    )
                } label: {
                    HStack {
                        Text(viewModel.selectedCountry?.regionType ?? "Region")
                            .foregroundColor(.primary)
                        Spacer()
                        if viewModel.userProfile.region.code.isEmpty {
                            Text("Select")
                                .foregroundColor(.secondary)
                        } else {
                            Text(viewModel.userProfile.region.name)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                TextField("City", text: $viewModel.userProfile.city)
                    .autocapitalization(.words)
            }
        } header: {
            sectionHeader(
                icon: "mappin.and.ellipse",
                title: "Location",
                isComplete: viewModel.isLocationComplete
            )
        } footer: {
            if viewModel.userProfile.countryCode == "us" {
                Text("Enter your 5-digit ZIP code. City and state will be auto-filled.")
                    .font(.caption)
            } else {
                Text("Select your \(viewModel.selectedCountry?.regionType.lowercased() ?? "region") and enter your city.")
                    .font(.caption)
            }
        }
    }

    private var demographicsSection: some View {
        Section {
            Stepper("Age: \(viewModel.userProfile.age)", value: $viewModel.userProfile.age, in: 18...100)
                .onChange(of: viewModel.userProfile.age) { newValue in
                    hasEditedDemographics = true
                    viewModel.updateAge(newValue)
                }

            if let error = viewModel.validationErrors["age"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Picker("Gender", selection: $viewModel.userProfile.gender) {
                ForEach(Gender.allCases) { gender in
                    Text(gender.localizedName).tag(gender)
                }
            }
            .onChange(of: viewModel.userProfile.gender) { newValue in
                hasEditedDemographics = true
                viewModel.updateGender(newValue)
            }

            if hasEditedDemographics, let error = viewModel.validationErrors["gender"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Picker("Marital Status", selection: $viewModel.userProfile.maritalStatus) {
                ForEach(MaritalStatus.allCases) { status in
                    Text(status.localizedName).tag(status)
                }
            }
            .onChange(of: viewModel.userProfile.maritalStatus) { newValue in
                hasEditedDemographics = true
                viewModel.updateMaritalStatus(newValue)
            }

            if hasEditedDemographics, let error = viewModel.validationErrors["maritalStatus"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        } header: {
            sectionHeader(
                icon: "person.fill",
                title: "Demographics",
                isComplete: hasEditedDemographics && viewModel.isDemographicsComplete
            )
        }
    }

    private var incomeSection: some View {
        Section {
            if viewModel.userProfile.isMarried {
                // Married: Both personal and household income
                VStack(alignment: .leading, spacing: 16) {
                    // Personal Income
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Personal Income")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)

                        HStack {
                            Text("$")
                                .foregroundColor(.textSecondary)

                            TextField("150000", text: $personalIncomeText)
                                .keyboardType(.numberPad)
                                .focused($isInputFocused)
                                .onChange(of: personalIncomeText) { newValue in
                                    if let income = Double(newValue.filter { $0.isNumber }) {
                                        viewModel.userProfile.annualIncome = income
                                    } else {
                                        viewModel.userProfile.annualIncome = 0
                                    }
                                    viewModel.validateForm()
                                }
                        }

                        if viewModel.userProfile.annualIncome > 0 {
                            Text(viewModel.userProfile.annualIncome.asCurrency)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }

                        if !personalIncomeText.isEmpty, let error = viewModel.validationErrors["income"] {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Divider()

                    // Household Income
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Household Income")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)

                        HStack {
                            Text("$")
                                .foregroundColor(.textSecondary)

                            TextField("200000", text: $householdIncomeText)
                                .keyboardType(.numberPad)
                                .focused($isInputFocused)
                                .onChange(of: householdIncomeText) { newValue in
                                    if let income = Double(newValue.filter { $0.isNumber }) {
                                        viewModel.userProfile.householdIncome = income
                                    } else {
                                        viewModel.userProfile.householdIncome = 0
                                    }
                                    viewModel.validateForm()
                                }
                        }

                        if viewModel.userProfile.householdIncome > 0 {
                            Text(viewModel.userProfile.householdIncome.asCurrency)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }

                        if !householdIncomeText.isEmpty, let error = viewModel.validationErrors["householdIncome"] {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    Divider()

                    // Number of Children
                    Stepper("Children: \(viewModel.userProfile.numberOfChildren)", value: $viewModel.userProfile.numberOfChildren, in: 0...20)
                        .onChange(of: viewModel.userProfile.numberOfChildren) { newValue in
                            viewModel.updateNumberOfChildren(newValue)
                        }

                    Text("Household size: \(viewModel.userProfile.householdSize) people (you + spouse + \(viewModel.userProfile.numberOfChildren) children)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    if viewModel.userProfile.householdIncome > 0 && viewModel.userProfile.householdSize > 0 {
                        Text("Per person: \(viewModel.userProfile.perCapitaIncome.asCurrency)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryAccent)
                    }
                }
            } else {
                // Personal Income for single/divorced/widowed
                HStack {
                    Text("$")
                        .foregroundColor(.textSecondary)

                    TextField("75000", text: $personalIncomeText)
                        .keyboardType(.numberPad)
                        .focused($isInputFocused)
                        .onChange(of: personalIncomeText) { newValue in
                            if let income = Double(newValue.filter { $0.isNumber }) {
                                viewModel.userProfile.annualIncome = income
                            } else {
                                viewModel.userProfile.annualIncome = 0
                            }
                            viewModel.validateForm()
                        }
                }

                if viewModel.userProfile.annualIncome > 0 {
                    Text(viewModel.userProfile.annualIncome.asCurrency)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                if !personalIncomeText.isEmpty, let error = viewModel.validationErrors["income"] {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        } header: {
            sectionHeader(
                icon: "dollarsign.circle.fill",
                title: viewModel.userProfile.isMarried ? "Income Information" : "Income",
                isComplete: viewModel.isIncomeComplete
            )
        } footer: {
            if viewModel.userProfile.isMarried {
                Text("Enter your personal income and the combined household income (you + spouse). This helps compare both your profession earnings and family prosperity.")
                    .font(.caption)
            } else {
                Text("Enter your total annual income before taxes")
                    .font(.caption)
            }
        }
    }

    private var occupationSection: some View {
        Section {
            Button(action: {
                isInputFocused = false // Закрываем клавиатуру
                showOccupationPicker = true
            }) {
                HStack {
                    Text("Occupation")
                        .foregroundColor(.textPrimary)

                    Spacer()

                    if viewModel.userProfile.occupation.socCode.isEmpty {
                        Text("Select")
                            .foregroundColor(.textSecondary)
                    } else {
                        Text(viewModel.userProfile.occupation.title)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            .buttonStyle(.plain)

            if hasSelectedOccupation, let error = viewModel.validationErrors["occupation"] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        } header: {
            sectionHeader(
                icon: "briefcase.fill",
                title: "Occupation",
                isComplete: hasSelectedOccupation && viewModel.isOccupationComplete
            )
        }
    }

    private var submitButton: some View {
        Section {
            Button(action: submitForm) {
                HStack {
                    Spacer()

                    if statisticsViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Show Statistics")
                            .fontWeight(.semibold)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .disabled(!viewModel.isFormValid || statisticsViewModel.isLoading)
            .listRowBackground(
                viewModel.isFormValid ?
                    Color.primaryAccent : Color.gray.opacity(0.3)
            )
            .foregroundColor(.white)
        }
    }

    // MARK: - Progress Bar

    private var completedSections: Int {
        var count = 0
        if viewModel.isLocationComplete { count += 1 }
        if hasEditedDemographics && viewModel.isDemographicsComplete { count += 1 }
        if viewModel.isIncomeComplete { count += 1 }
        if hasSelectedOccupation && viewModel.isOccupationComplete { count += 1 }
        return count
    }

    private var formProgress: Double {
        Double(completedSections) / Double(viewModel.totalSections)
    }

    private var formProgressPercentage: Int {
        Int(formProgress * 100)
    }

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(completedSections) of \(viewModel.totalSections) completed")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)

                Spacer()

                Text("\(formProgressPercentage)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryAccent)
            }
            .padding(.horizontal)

            AnimatedProgressBar(
                progress: formProgress,
                height: 4,
                color: .primaryAccent,
                backgroundColor: Color.gray.opacity(0.2),
                cornerRadius: 2,
                duration: 0.3
            )
        }
        .padding(.bottom, 8)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Section Headers

    private func sectionHeader(icon: String, title: String, isComplete: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(isComplete ? .green : .primaryAccent)

            Text(title)

            if isComplete {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .foregroundColor(.green)
            }
        }
    }

    // MARK: - Actions

    private func submitForm() {
        Task {
            await statisticsViewModel.calculateStatistics(for: viewModel.userProfile)
            if statisticsViewModel.hasResults {
                navigateToResults = true
            } else if let error = statisticsViewModel.error {
                // Show error message
                if error.localizedDescription.contains("State data not available") {
                    errorMessage = "Sorry, data for \(viewModel.userProfile.state.fullName) is not available yet. Please try CA, NY, TX, FL, or WA."
                } else {
                    errorMessage = error.localizedDescription
                }
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    UserInputFormView()
}
