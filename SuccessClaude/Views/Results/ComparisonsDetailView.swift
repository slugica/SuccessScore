//
//  ComparisonsDetailView.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct ComparisonsDetailView: View {
    @ObservedObject var viewModel: StatisticsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.paddingLarge) {
                if let snapshot = viewModel.statisticsSnapshot {
                    // State Comparison
                    ComparisonCardView(comparison: snapshot.stateComparison)

                    // National Comparison
                    ComparisonCardView(comparison: snapshot.nationalComparison)

                    // Occupation Comparison
                    ComparisonCardView(comparison: snapshot.occupationComparison)

                    // Peer Comparison
                    ComparisonCardView(comparison: snapshot.peerComparison)
                }
            }
            .padding()
        }
        .navigationTitle("Detailed Comparisons")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        ComparisonsDetailView(viewModel: StatisticsViewModel())
    }
}
