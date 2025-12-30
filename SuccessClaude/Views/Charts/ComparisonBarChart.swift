//
//  ComparisonBarChart.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI
import Charts

struct ComparisonBarChart: View {
    let comparisons: [ComparisonResult]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.paddingMedium) {
            Text("Percentile Comparison")
                .font(.headline)

            Chart {
                ForEach(chartData) { data in
                    BarMark(
                        x: .value("Category", data.category),
                        y: .value("Percentile", data.percentile)
                    )
                    .foregroundStyle(data.color)
                    .annotation(position: .top) {
                        Text("\(Int(data.percentile))%")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .frame(height: 250)
            .chartYScale(domain: 0...100)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel {
                        if let category = value.as(String.self) {
                            Text(category)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 25)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let percentile = value.as(Int.self) {
                            Text("\(percentile)%")
                                .font(.caption2)
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: Theme.paddingMedium) {
                ForEach(chartData.prefix(2)) { data in
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(data.color)
                            .frame(width: 12, height: 12)

                        Text(data.category)
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding(Theme.paddingLarge)
        .background(Color.cardBackground)
        .cornerRadius(Theme.cornerRadiusMedium)
        .cardShadow()
    }

    private var chartData: [ChartDataItem] {
        comparisons.enumerated().map { index, comparison in
            let category: String
            switch comparison.category {
            case .state(let name):
                category = "State\n(\(name))"
            case .national:
                category = "National"
            case .occupation(let title):
                category = "Occupation\n(\(title.prefix(15))...)"
            case .peers:
                category = "Peers"
            }

            return ChartDataItem(
                category: category,
                percentile: comparison.percentile,
                color: Color.chartColors[index % Color.chartColors.count]
            )
        }
    }
}

struct ChartDataItem: Identifiable {
    let id = UUID()
    let category: String
    let percentile: Double
    let color: Color
}

#Preview {
    ComparisonBarChart(
        comparisons: [
            ComparisonResult(
                category: .state(stateName: "California"),
                userIncome: 85000,
                medianIncome: 75000,
                meanIncome: 95000,
                top10Threshold: 150000,
                percentile: 67.5,
                percentageDifference: 13.3,
                sampleSize: nil,
                perCapitaIncome: nil,
                householdSize: nil
            ),
            ComparisonResult(
                category: .national,
                userIncome: 85000,
                medianIncome: 64000,
                meanIncome: 81000,
                top10Threshold: 173000,
                percentile: 72.3,
                percentageDifference: 32.8,
                sampleSize: nil,
                perCapitaIncome: nil,
                householdSize: nil
            ),
            ComparisonResult(
                category: .occupation(occupationTitle: "Software Developers"),
                userIncome: 85000,
                medianIncome: 130000,
                meanIncome: 138000,
                top10Threshold: 208000,
                percentile: 32.1,
                percentageDifference: -34.6,
                sampleSize: nil,
                perCapitaIncome: nil,
                householdSize: nil
            ),
            ComparisonResult(
                category: .peers,
                userIncome: 85000,
                medianIncome: 115000,
                meanIncome: 122000,
                top10Threshold: 180000,
                percentile: 38.5,
                percentageDifference: -26.1,
                sampleSize: 4500,
                perCapitaIncome: nil,
                householdSize: nil
            )
        ]
    )
    .padding()
}
