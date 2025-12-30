//
//  OccupationPickerView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct OccupationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedOccupation: OccupationCategory
    @ObservedObject var viewModel: UserInputViewModel

    @State private var searchText = ""
    @State private var expandedCategories: Set<String> = []

    var body: some View {
        NavigationStack {
            List {
                if filteredOccupations.isEmpty {
                    Section {
                        Text("No occupations found")
                            .foregroundColor(.textSecondary)
                    }
                } else {
                    ForEach(sortedCategories, id: \.self) { category in
                        Section {
                            if expandedCategories.contains(category) {
                                ForEach(occupationsForCategory(category), id: \.socCode) { occupation in
                                    Button(action: {
                                        selectedOccupation = occupation
                                        viewModel.updateOccupation(occupation)
                                        dismiss()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(occupation.title)
                                                    .foregroundColor(.textPrimary)

                                                Text(occupation.socCode)
                                                    .font(.caption)
                                                    .foregroundColor(.textSecondary)
                                            }

                                            Spacer()

                                            if selectedOccupation.socCode == occupation.socCode {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.primaryAccent)
                                            }
                                        }
                                    }
                                }
                            }
                        } header: {
                            Button(action: {
                                if expandedCategories.contains(category) {
                                    expandedCategories.remove(category)
                                } else {
                                    expandedCategories.insert(category)
                                }
                            }) {
                                HStack {
                                    Text(category)
                                        .font(.headline)

                                    Spacer()

                                    Image(systemName: expandedCategories.contains(category) ? "chevron.down" : "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.textPrimary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search occupations")
            .navigationTitle("Select Occupation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                // Auto-expand categories when searching
                if !newValue.isEmpty {
                    expandedCategories = Set(sortedCategories)
                } else {
                    // Clear expanded categories when search is cleared
                    expandedCategories.removeAll()
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredOccupations: [OccupationCategory] {
        if searchText.isEmpty {
            return viewModel.availableOccupations
        } else {
            return viewModel.availableOccupations.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText) ||
                $0.socCode.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var sortedCategories: [String] {
        let categories = Set(filteredOccupations.map { $0.category })
        return categories.sorted()
    }

    private func occupationsForCategory(_ category: String) -> [OccupationCategory] {
        filteredOccupations
            .filter { $0.category == category }
            .sorted { $0.title < $1.title }
    }
}

#Preview {
    OccupationPickerView(
        selectedOccupation: .constant(OccupationCategory(socCode: "", title: "", category: "")),
        viewModel: UserInputViewModel()
    )
}
