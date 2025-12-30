//
//  SimilarOccupationsView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct SimilarOccupationsView: View {
    let similarOccupations: [SimilarOccupation]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "briefcase.fill")
                    .font(.title2)
                    .foregroundColor(.primaryAccent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Similar Occupations")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text("Top-paying jobs in your category")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            if similarOccupations.isEmpty {
                Text("No similar occupations found")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(similarOccupations.enumerated()), id: \.element.socCode) { index, occupation in
                        SimilarOccupationRow(occupation: occupation, rank: index + 1)
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
}

struct SimilarOccupationRow: View {
    let occupation: SimilarOccupation
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank number
            Text("\(rank)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.textSecondary)
                .frame(width: 20)

            // Occupation info
            VStack(alignment: .leading, spacing: 4) {
                Text(occupation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)

                Text(occupation.socCode)
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
            }

            Spacer()

            // Median and difference
            VStack(alignment: .trailing, spacing: 4) {
                Text(occupation.median.asCurrency)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: occupation.percentageDifference >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                        .foregroundColor(occupation.percentageDifference >= 0 ? .green : .red)

                    Text("\(String(format: "%+.1f", occupation.percentageDifference))%")
                        .font(.caption)
                        .foregroundColor(occupation.percentageDifference >= 0 ? .green : .red)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

#Preview {
    SimilarOccupationsView(
        similarOccupations: [
            SimilarOccupation(
                title: "Software Architects",
                socCode: "15-1252",
                median: 145000,
                percentageDifference: 15.2
            ),
            SimilarOccupation(
                title: "Data Scientists",
                socCode: "15-2051",
                median: 138000,
                percentageDifference: 8.5
            ),
            SimilarOccupation(
                title: "DevOps Engineers",
                socCode: "15-1254",
                median: 135000,
                percentageDifference: 5.1
            ),
            SimilarOccupation(
                title: "Full Stack Developers",
                socCode: "15-1256",
                median: 120000,
                percentageDifference: -4.2
            ),
            SimilarOccupation(
                title: "Web Developers",
                socCode: "15-1257",
                median: 95000,
                percentageDifference: -15.8
            )
        ]
    )
    .padding()
}
