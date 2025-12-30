//
//  GenderComparisonView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct GenderComparisonView: View {
    let genderComparison: GenderComparison

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundColor(.primaryAccent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Gender Comparison")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text(genderComparison.category)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            if genderComparison.hasData {
                VStack(spacing: 16) {
                    // Gender comparison bars
                    if let maleMedian = genderComparison.maleMedian {
                        GenderBarView(
                            gender: "Male",
                            median: maleMedian,
                            maxMedian: max(maleMedian, genderComparison.femaleMedian ?? 0),
                            isUserGender: genderComparison.userGender == .male,
                            userIncome: genderComparison.userIncome
                        )
                    }

                    if let femaleMedian = genderComparison.femaleMedian {
                        GenderBarView(
                            gender: "Female",
                            median: femaleMedian,
                            maxMedian: max(genderComparison.maleMedian ?? 0, femaleMedian),
                            isUserGender: genderComparison.userGender == .female,
                            userIncome: genderComparison.userIncome
                        )
                    }

                    // Pay gap
                    if let payGap = genderComparison.payGap {
                        Divider()

                        HStack {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gender Pay Gap")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textSecondary)

                                Text("\(String(format: "%.1f", payGap))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }

                            Spacer()

                            Text("Women earn \(String(format: "%.1f", 100 - payGap))% of men's income")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
            } else {
                Text("Gender comparison data not available for this category")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct GenderBarView: View {
    let gender: String
    let median: Double
    let maxMedian: Double
    let isUserGender: Bool
    let userIncome: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(gender)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUserGender ? .primaryAccent : .textSecondary)

                if isUserGender {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }

                Spacer()

                Text(median.asCurrency)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    // Median bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isUserGender ? Color.primaryAccent : Color.gray)
                        .frame(
                            width: geometry.size.width * (median / maxMedian),
                            height: 12
                        )

                    // User income marker (if this is their gender)
                    if isUserGender && userIncome > 0 {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .offset(x: geometry.size.width * min(userIncome / maxMedian, 1) - 4)
                    }
                }
            }
            .frame(height: 12)

            if isUserGender && userIncome > 0 {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)

                    Text("Your income: \(userIncome.asCurrency)")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GenderComparisonView(
            genderComparison: GenderComparison(
                category: "California",
                maleMedian: 95000,
                femaleMedian: 78000,
                userGender: .male,
                userIncome: 110000,
                payGap: 17.9
            )
        )

        GenderComparisonView(
            genderComparison: GenderComparison(
                category: "Software Developers",
                maleMedian: nil,
                femaleMedian: nil,
                userGender: .female,
                userIncome: 130000,
                payGap: nil
            )
        )
    }
    .padding()
}
