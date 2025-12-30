//
//  IncomeDistributionChart.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI
import Charts

struct IncomeDistributionChart: View {
    let userIncome: Double
    let medianIncome: Double
    let meanIncome: Double

    @State private var distributionData: [DistributionPoint] = []

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            Text("Income Distribution")
                .font(.headline)

            Chart {
                // Distribution curve (approximation)
                ForEach(distributionData) { point in
                    LineMark(
                        x: .value("Income", point.income),
                        y: .value("Frequency", point.frequency)
                    )
                    .foregroundStyle(Color.blue.opacity(0.3))
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Income", point.income),
                        y: .value("Frequency", point.frequency)
                    )
                    .foregroundStyle(Color.blue.opacity(0.1))
                    .interpolationMethod(.catmullRom)
                }

                // User income marker
                RuleMark(x: .value("Your Income", userIncome))
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .annotation(position: .top) {
                        Text("You")
                            .font(.caption)
                            .padding(4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }

                // Median marker
                RuleMark(x: .value("Median", medianIncome))
                    .foregroundStyle(Color.orange.opacity(0.7))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let income = value.as(Double.self) {
                            Text(income.asCompactCurrency)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel("")
                }
            }
        }
        .padding(Theme.paddingLarge)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .cardShadow()
        .onAppear {
            generateDistributionData()
        }
    }

    // MARK: - Generate Distribution Data

    private func generateDistributionData() {
        // Generate a normal distribution approximation
        let mean = meanIncome
        let median = medianIncome
        let stdDev = (mean - median) * 1.5

        var points: [DistributionPoint] = []
        let minIncome = max(0, median - stdDev * 3)
        let maxIncome = median + stdDev * 4
        let step = (maxIncome - minIncome) / 50

        for i in 0...50 {
            let income = minIncome + (step * Double(i))
            let frequency = normalDistribution(x: income, mean: mean, stdDev: stdDev)
            points.append(DistributionPoint(income: income, frequency: frequency))
        }

        distributionData = points
    }

    private func normalDistribution(x: Double, mean: Double, stdDev: Double) -> Double {
        let exponent = -pow(x - mean, 2) / (2 * pow(stdDev, 2))
        return exp(exponent) / (stdDev * sqrt(2 * .pi))
    }
}

struct DistributionPoint: Identifiable {
    let id = UUID()
    let income: Double
    let frequency: Double
}

#Preview {
    IncomeDistributionChart(
        userIncome: 85000,
        medianIncome: 75000,
        meanIncome: 95000
    )
    .padding()
}
