//
//  CountryPickerView.swift
//  SuccessClaude
//
//  Created by Claude on 12/30/24.
//

import SwiftUI

struct CountryPickerView: View {
    @Binding var selectedCountry: Country?
    let countries: [Country]

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Your Country")
                .font(.title2)
                .fontWeight(.bold)

            Text("Choose where you live to get accurate income comparisons")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(countries) { country in
                    CountryCard(
                        country: country,
                        isSelected: selectedCountry?.code == country.code,
                        action: {
                            print("🎯 Country card tapped: \(country.code) - \(country.name)")
                            selectedCountry = country
                            print("🎯 selectedCountry updated to: \(selectedCountry?.code ?? "nil")")
                        }
                    )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
    }
}

struct CountryCard: View {
    let country: Country
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(country.flag)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text("\(country.occupationCount) jobs")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? Color.blue.opacity(0.2) : Color.black.opacity(0.03), radius: isSelected ? 4 : 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CountryPickerView(
        selectedCountry: .constant(nil),
        countries: [
            Country(code: "us", name: "United States", flag: "🇺🇸", currency: "USD", currencySymbol: "$", occupationSystem: "SOC 2018", regionType: "State", regionCount: 51, occupationCount: 822, hasData: true, isActive: true),
            Country(code: "uk", name: "United Kingdom", flag: "🇬🇧", currency: "GBP", currencySymbol: "£", occupationSystem: "SOC 2020", regionType: "Region", regionCount: 12, occupationCount: 279, hasData: true, isActive: true)
        ]
    )
}
