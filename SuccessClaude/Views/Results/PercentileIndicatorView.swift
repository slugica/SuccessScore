//
//  PercentileIndicatorView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct PercentileIndicatorView: View {
    let percentile: Double
    var color: Color? = nil // Optional color override
    @State private var animatedPercentile: Double = 0

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 12)
                .frame(width: 120, height: 120)

            // Progress circle
            Circle()
                .trim(from: 0, to: animatedPercentile / 100)
                .stroke(
                    indicatorColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))

            // Center content
            VStack(spacing: 4) {
                Text("\(Int(animatedPercentile))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(indicatorColor)

                Text("percentile")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animatedPercentile = percentile
            }
        }
    }

    private var indicatorColor: Color {
        color ?? Color.percentileColor(for: percentile)
    }
}

#Preview {
    VStack(spacing: 32) {
        PercentileIndicatorView(percentile: 25)
        PercentileIndicatorView(percentile: 50)
        PercentileIndicatorView(percentile: 75)
        PercentileIndicatorView(percentile: 92)
    }
    .padding()
}
