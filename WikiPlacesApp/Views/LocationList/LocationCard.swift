//
//  LocationCard.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

struct LocationCard: View {
    let location: Location
    let index: Int
    let action: () -> Void

    @State private var appeared = false
    @State private var isTapped = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Body

    var body: some View {
        Button {
            Task { await handleTap() }
        } label: {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(location.displayName)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Text(location.coordinateString)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.background)
                    .shadow(color: .black.opacity(isTapped ? 0.03 : 0.08), radius: isTapped ? 3 : 10, x: 0, y: isTapped ? 1 : 4)
            )
        }
        .buttonStyle(.plain)
        // Scale down on tap - Like button press effect.
        .scaleEffect(reduceMotion ? 1 : (isTapped ? 0.93 : 1))
        .animation(
            reduceMotion ? .none : (isTapped ? .easeIn(duration: 0.08) : .spring(response: 0.4, dampingFraction: 0.5)),
            value: isTapped
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(location.displayName))
        .accessibilityHint(Text("Opens this location in Wikipedia"))
        .accessibilityAddTraits(.isButton)
        // Slide in from the right the moment the card enters the viewport.
        .offset(x: reduceMotion ? 0 : (appeared ? 0 : 400))
        .opacity(appeared ? 1 : 0)
        .onAppear {
            let delay = index < 7 ? Double(index) * 0.1 : 0.0
            Task { @MainActor in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    appeared = true
                }
            }
        }
    }

// MARK: - Actions
    private func handleTap() async {
        guard !isTapped else { return }
        if !reduceMotion {
            isTapped = true
            try? await Task.sleep(for: .milliseconds(120))
            isTapped = false
            try? await Task.sleep(for: .milliseconds(80))
        }
        action()
    }

// MARK: - Styling
    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [.blue, .cyan],
            [.purple, .pink],
            [.orange, .red],
            [.green, .mint],
            [.indigo, .blue],
            [.pink, .orange],
        ]
        // Hash-based index gives each location a consistent colour without storing state
        let index = abs(location.displayName.hashValue) % palettes.count
        return palettes[index]
    }
}

// MARK: - Skeleton
struct LocationCardSkeleton: View {
    @State private var shimmerX: CGFloat = -1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

// MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.primary.opacity(0.08))
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: 96, height: 12)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        )
        .overlay(shimmerOverlay)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                shimmerX = 2
            }
        }
        .accessibilityHidden(true)
    }

// MARK: - Shimmer
    private var shimmerOverlay: some View {
        GeometryReader { proxy in
            LinearGradient(
                colors: [.clear, Color.white.opacity(0.45), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: proxy.size.width * 0.6)
            .offset(x: shimmerX * proxy.size.width)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .allowsHitTesting(false)
    }
}

#Preview {
    LocationCard(location: Location(name: "Unknown Location", latitude: 80.0, longitude: 90.0), index: 0, action: {})
}
