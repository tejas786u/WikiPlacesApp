//
//  BackgroundGradient.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 27/08/26.
//

import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemGroupedBackground), Color.accentColor.opacity(0.08)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundGradient()
}
