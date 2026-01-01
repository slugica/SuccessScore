//
//  AnimatedNumberView.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import SwiftUI

struct AnimatedNumberView: View {
    let value: Double
    let format: NumberFormat
    let font: Font
    let color: Color
    let duration: Double
    let suffix: String
    let decimalPlaces: Int
    let currencySymbol: String

    @State private var displayValue: Double = 0

    enum NumberFormat {
        case currency
        case percentage
        case ordinal
        case integer
    }

    init(
        value: Double,
        format: NumberFormat = .currency,
        font: Font = .title,
        color: Color = .primary,
        duration: Double = 1.0,
        suffix: String = "",
        decimalPlaces: Int = 1,
        currencySymbol: String = "$"
    ) {
        self.value = value
        self.format = format
        self.font = font
        self.color = color
        self.duration = duration
        self.suffix = suffix
        self.decimalPlaces = decimalPlaces
        self.currencySymbol = currencySymbol
    }

    // Convenience init with country code
    init(
        value: Double,
        format: NumberFormat = .currency,
        font: Font = .title,
        color: Color = .primary,
        duration: Double = 1.0,
        suffix: String = "",
        decimalPlaces: Int = 1,
        countryCode: String
    ) {
        let symbol: String
        switch countryCode.lowercased() {
        case "us":
            symbol = "$"
        case "uk":
            symbol = "£"
        case "ca":
            symbol = "C$"
        case "au":
            symbol = "A$"
        case "nz":
            symbol = "NZ$"
        case "de", "fr", "es":
            symbol = "€"
        default:
            symbol = "$"
        }

        self.init(
            value: value,
            format: format,
            font: font,
            color: color,
            duration: duration,
            suffix: suffix,
            decimalPlaces: decimalPlaces,
            currencySymbol: symbol
        )
    }

    var body: some View {
        Text(formattedValue)
            .font(font)
            .foregroundColor(color)
            .onAppear {
                animateNumber()
            }
            .onChange(of: value) { newValue in
                animateNumber()
            }
    }

    private var formattedValue: String {
        let baseValue: String
        switch format {
        case .currency:
            baseValue = displayValue.asCurrency(symbol: currencySymbol)
        case .percentage:
            baseValue = String(format: "%.\(decimalPlaces)f%%", displayValue)
        case .ordinal:
            baseValue = displayValue.asOrdinalPercentile
        case .integer:
            baseValue = String(format: "%.0f", displayValue)
        }
        return baseValue + suffix
    }

    private func animateNumber() {
        withAnimation(.easeOut(duration: duration)) {
            displayValue = value
        }
    }
}

// MARK: - Progress Bar with Animation

struct AnimatedProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let height: CGFloat
    let color: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let duration: Double

    @State private var displayProgress: Double = 0

    init(
        progress: Double,
        height: CGFloat = 16,
        color: Color = .primaryAccent,
        backgroundColor: Color = Color.gray.opacity(0.2),
        cornerRadius: CGFloat? = nil,
        duration: Double = 1.0
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.color = color
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius ?? (height / 2)
        self.duration = duration
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)

                // Progress
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * displayProgress,
                        height: height
                    )
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: displayProgress)
            }
        }
        .frame(height: height)
        .onAppear {
            withAnimation(.easeOut(duration: duration)) {
                displayProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: duration)) {
                displayProgress = newValue
            }
        }
    }
}

// MARK: - Bounce Animation for Achievements

struct BounceAnimationModifier: ViewModifier {
    @State private var scale: CGFloat = 0.5

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
    }
}

extension View {
    func bounceAnimation() -> some View {
        modifier(BounceAnimationModifier())
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

#Preview {
    VStack(spacing: 30) {
        AnimatedNumberView(
            value: 125000,
            format: .currency,
            font: .system(size: 48, weight: .bold),
            color: .green
        )

        AnimatedNumberView(
            value: 87.5,
            format: .percentage,
            font: .title,
            color: .primaryAccent
        )

        AnimatedProgressBar(
            progress: 0.75,
            height: 20,
            color: .green
        )

        Text("Achievement Unlocked!")
            .font(.title2)
            .fontWeight(.bold)
            .bounceAnimation()

        RoundedRectangle(cornerRadius: 16)
            .fill(Color.blue.gradient)
            .frame(width: 200, height: 100)
            .shimmer()
    }
    .padding()
}
