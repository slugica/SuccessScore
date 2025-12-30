//
//  StateRankingView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct StateRankingView: View {
    let stateRanking: StateRanking

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundColor(.primaryAccent)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Best States for Your Profession")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text(stateRanking.occupation)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()
            }

            // User's state rank
            if let userRank = stateRanking.userStateRank {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(userRank <= 10 ? .yellow : .gray)

                    Text("\(stateRanking.userState) ranks #\(userRank)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(userRank <= 10 ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                )
            }

            // Top states list
            VStack(spacing: 0) {
                ForEach(stateRanking.topStates, id: \.stateCode) { stateInfo in
                    StateRankRow(
                        stateInfo: stateInfo,
                        isUserState: stateInfo.stateCode == stateRanking.userState || stateInfo.stateName == stateRanking.userState
                    )

                    if stateInfo.rank < stateRanking.topStates.count {
                        Divider()
                            .padding(.leading, 40)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
            )

            Text("Top 5 states ranked by median income")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct StateRankRow: View {
    let stateInfo: StateIncomeInfo
    let isUserState: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Rank medal
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Text("#\(stateInfo.rank)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(rankColor)
            }

            // State name
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(stateInfo.stateName)
                        .font(.subheadline)
                        .fontWeight(isUserState ? .bold : .medium)
                        .foregroundColor(.textPrimary)

                    if isUserState {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Text(stateInfo.stateCode)
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Median income
            Text(stateInfo.median.asCurrency)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(isUserState ? .primaryAccent : .textPrimary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            isUserState ?
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primaryAccent.opacity(0.1))
                : nil
        )
    }

    private var rankColor: Color {
        switch stateInfo.rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .primaryAccent
        }
    }
}

#Preview {
    StateRankingView(
        stateRanking: StateRanking(
            occupation: "Software Developers",
            topStates: [
                StateIncomeInfo(stateName: "Washington", stateCode: "WA", median: 165000, rank: 1),
                StateIncomeInfo(stateName: "California", stateCode: "CA", median: 152000, rank: 2),
                StateIncomeInfo(stateName: "New York", stateCode: "NY", median: 145000, rank: 3),
                StateIncomeInfo(stateName: "Massachusetts", stateCode: "MA", median: 142000, rank: 4),
                StateIncomeInfo(stateName: "Virginia", stateCode: "VA", median: 138000, rank: 5)
            ],
            userStateRank: 2,
            userState: "California"
        )
    )
    .padding()
}
