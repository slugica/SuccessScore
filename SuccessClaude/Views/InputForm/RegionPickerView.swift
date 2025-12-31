//
//  RegionPickerView.swift
//  SuccessClaude
//
//  Created by Claude on 12/30/24.
//

import SwiftUI

struct RegionPickerView: View {
    @Binding var selectedRegion: Region?
    let regions: [Region]
    let regionType: String // "State", "Region", "Province"
    @State private var searchText = ""

    var filteredRegions: [Region] {
        if searchText.isEmpty {
            return regions
        }
        return regions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredRegions) { region in
                    Button(action: {
                        selectedRegion = region
                    }) {
                        HStack {
                            Text(region.name)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedRegion?.code == region.code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search \(regionType.lowercased())s")
            .navigationTitle("Select \(regionType)")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Закрываем клавиатуру с предыдущего экрана
            hideKeyboard()
        }
    }
}

#Preview {
    RegionPickerView(
        selectedRegion: .constant(nil),
        regions: [
            Region(code: "CA", name: "California", countryCode: "us"),
            Region(code: "NY", name: "New York", countryCode: "us"),
            Region(code: "TX", name: "Texas", countryCode: "us")
        ],
        regionType: "State"
    )
}
