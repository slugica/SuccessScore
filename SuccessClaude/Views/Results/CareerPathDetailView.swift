//
//  CareerPathDetailView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct CareerPathDetailView: View {
    let snapshot: StatisticsSnapshot

    private var currencySymbol: String {
        let countryCode = snapshot.userProfile.countryCode
        switch countryCode {
        case "us":
            return "$"
        case "ca":
            return "C$"
        case "uk":
            return "£"
        default:
            return "$"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                // Path to Top 10% in Region
                if let pathState = snapshot.pathToTop10State {
                    PathToTop10View(pathToTop10: pathState, title: "Path to Top 10% in Region", currencySymbol: currencySymbol)
                }

                // Path to Top 10% in Profession
                if let pathOccupation = snapshot.pathToTop10Occupation {
                    PathToTop10View(pathToTop10: pathOccupation, title: "Path to Top 10% in Profession", currencySymbol: currencySymbol)
                }

                // Career Forecast
                if let careerForecast = snapshot.careerForecast {
                    CareerForecastView(careerForecast: careerForecast, currencySymbol: currencySymbol)
                }
            }
            .padding()
        }
        .navigationTitle("Career Path")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
