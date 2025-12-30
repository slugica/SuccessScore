//
//  CareerPathDetailView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct CareerPathDetailView: View {
    let snapshot: StatisticsSnapshot

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                // Path to Top 10% in State
                if let pathState = snapshot.pathToTop10State {
                    PathToTop10View(pathToTop10: pathState, title: "Path to Top 10% in State")
                }

                // Path to Top 10% in Profession
                if let pathOccupation = snapshot.pathToTop10Occupation {
                    PathToTop10View(pathToTop10: pathOccupation, title: "Path to Top 10% in Profession")
                }

                // Career Forecast
                if let careerForecast = snapshot.careerForecast {
                    CareerForecastView(careerForecast: careerForecast)
                }
            }
            .padding()
        }
        .navigationTitle("Career Path")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
