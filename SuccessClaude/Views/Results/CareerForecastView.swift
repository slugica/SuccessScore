//
//  CareerForecastView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI
import Charts

struct CareerForecastView: View {
    let careerForecast: CareerForecast
    var currencySymbol: String = "$"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.primaryAccent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Career Forecast")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text("Income growth by age in your profession")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // Peak age info
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)

                Text("Peak earnings at age \(careerForecast.peakAge): \(careerForecast.peakIncome.asCurrency(symbol: currencySymbol))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.yellow.opacity(0.1))
            )

            // Chart
            Chart {
                ForEach(Array(careerForecast.ageGroups.enumerated()), id: \.offset) { index, ageGroup in
                    LineMark(
                        x: .value("Age", index),
                        y: .value("Median", ageGroup.median)
                    )
                    .foregroundStyle(Color.primaryAccent)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    AreaMark(
                        x: .value("Age", index),
                        yStart: .value("Mean", 0),
                        yEnd: .value("Mean", ageGroup.median)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primaryAccent.opacity(0.3), Color.primaryAccent.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    PointMark(
                        x: .value("Age", index),
                        y: .value("Median", ageGroup.median)
                    )
                    .foregroundStyle(Color.primaryAccent)
                    .symbol(.circle)
                    .symbolSize(isCurrentAgeGroup(ageGroup) ? 120 : 60)
                }

                // Highlight current age group vertical line
                if let currentGroup = getCurrentAgeGroup() {
                    if let currentIndex = careerForecast.ageGroups.firstIndex(where: { $0.ageRange == currentGroup.ageRange }) {
                        RuleMark(x: .value("Current", currentIndex))
                            .foregroundStyle(Color.green)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                            .annotation(position: .top, alignment: .center) {
                                Text("You")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.green.opacity(0.2))
                                    )
                            }

                        // User's actual income point
                        PointMark(
                            x: .value("Age", currentIndex),
                            y: .value("Your Income", careerForecast.userIncome)
                        )
                        .foregroundStyle(Color.green)
                        .symbol(.circle)
                        .symbolSize(200)
                        .annotation(position: .trailing, alignment: .center) {
                            Text(careerForecast.userIncome.asCurrency(symbol: currencySymbol))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.green)
                                )
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: Array(0..<careerForecast.ageGroups.count).map { $0 }) { value in
                    if let index = value.as(Int.self),
                       index >= 0,
                       index < careerForecast.ageGroups.count {
                        AxisValueLabel {
                            Text(careerForecast.ageGroups[index].ageRange)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let median = value.as(Double.self) {
                            Text(formatShortCurrency(median))
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 220)

            // Age group details
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(careerForecast.ageGroups, id: \.ageRange) { ageGroup in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ageGroup.ageRange)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isCurrentAgeGroup(ageGroup) ? .green : .textSecondary)

                            Text(ageGroup.median.asCurrency(symbol: currencySymbol))
                                .font(.caption2)
                                .foregroundColor(.textPrimary)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isCurrentAgeGroup(ageGroup) ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isCurrentAgeGroup(ageGroup) ? Color.green : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }

    private func isCurrentAgeGroup(_ ageGroup: AgeGroupIncome) -> Bool {
        let currentAgeRange = getAgeRangeKey(for: careerForecast.currentAge)
        return ageGroup.ageRange == currentAgeRange
    }

    private func getCurrentAgeGroup() -> AgeGroupIncome? {
        let currentAgeRange = getAgeRangeKey(for: careerForecast.currentAge)
        return careerForecast.ageGroups.first { $0.ageRange == currentAgeRange }
    }

    private func getAgeRangeKey(for age: Int) -> String {
        switch age {
        case 16...19: return "16-19"
        case 20...24: return "20-24"
        case 25...34: return "25-34"
        case 35...44: return "35-44"
        case 45...54: return "45-54"
        case 55...64: return "55-64"
        default: return "65+"
        }
    }

    private func formatShortCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "\(currencySymbol)%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "\(currencySymbol)%.0fK", value / 1_000)
        } else {
            return String(format: "\(currencySymbol)%.0f", value)
        }
    }
}

#Preview {
    CareerForecastView(
        careerForecast: CareerForecast(
            currentAge: 32,
            userIncome: 170000,
            ageGroups: [
                AgeGroupIncome(ageRange: "20-24", median: 65000, mean: 70000),
                AgeGroupIncome(ageRange: "25-34", median: 95000, mean: 102000),
                AgeGroupIncome(ageRange: "35-44", median: 130000, mean: 145000),
                AgeGroupIncome(ageRange: "45-54", median: 150000, mean: 170000),
                AgeGroupIncome(ageRange: "55-64", median: 145000, mean: 165000)
            ],
            peakAge: "45-54",
            peakIncome: 150000
        )
    )
    .padding()
}
