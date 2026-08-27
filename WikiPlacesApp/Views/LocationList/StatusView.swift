//
//  StatusView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

private struct StatusView<Actions: View>: View {
    let systemImage: String
    let tint: Color
    let title: String
    let message: String
    @ViewBuilder let actions: Actions

    @State private var appear = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(tint)
                .scaleEffect(appear ? 1 : 0.6)
                .opacity(appear ? 1 : 0)

            Text(title)
                .font(.system(.title3, design: .rounded, weight: .semibold))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            actions
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                appear = true
            }
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        StatusView(
            systemImage: "wifi.exclamationmark",
            tint: .orange,
            title: "Something went wrong",
            message: message
        ) {
            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .accessibilityElement(children: .combine)
    }
}

struct EmptyLocationsView: View {
    let retry: () -> Void

    var body: some View {
        StatusView(
            systemImage: "mappin.slash",
            tint: .secondary,
            title: "No Locations Found",
            message: "The locations feed didn't return anything to show right now."
        ) {
            Button("Refresh", action: retry)
                .buttonStyle(.bordered)
                .controlSize(.large)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ErrorStateView(message: "Failed to load locations.") {}
}
