//
//  InsightCard.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct InsightCard<PreviewContent: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let accentColor: Color
    let previewContent: PreviewContent

    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        accentColor: Color,
        @ViewBuilder previewContent: () -> PreviewContent
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.accentColor = accentColor
        self.previewContent = previewContent()
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(iconColor)
                .frame(width: 70, height: 70)
                .background(iconColor.opacity(0.1))
                .clipShape(Circle())

            // Content
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                // Preview content
                previewContent

                Text("Tap for detailed analysis")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.textSecondary)
                .opacity(0.5)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(Theme.cornerRadiusLarge)
        .cardShadow()
    }
}

#Preview {
    VStack(spacing: 12) {
        InsightCard(
            icon: "dollarsign.circle.fill",
            iconColor: .green,
            title: "After Tax",
            subtitle: "$68,450",
            accentColor: .green
        ) {
            Text("Preview content here")
                .font(.caption)
        }

        InsightCard(
            icon: "chart.bar.fill",
            iconColor: .blue,
            title: "Comparisons",
            subtitle: "Top 15%",
            accentColor: .blue
        ) {
            Text("More preview content")
                .font(.caption)
        }
    }
    .padding()
}
