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
            ], spacing: 16) {
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
            VStack(spacing: 12) {
                Text(country.flag)
                    .font(.system(size: 60))

                Text(country.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                VStack(spacing: 4) {
                    Text("\(country.occupationCount) occupations")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(country.regionCount) \(country.regionType.lowercased())s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
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
