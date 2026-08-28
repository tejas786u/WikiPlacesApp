//
//  CustomLocationView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 28/08/26.
//

import SwiftUI

struct CustomLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var viewModel = CustomLocationViewModel()
    @ObservedObject var launcher: LocationsListViewModel
    @FocusState private var focusedField: Field?
    @State private var isOpening = false
    @State private var shakeTrigger: CGFloat = 0

    private enum Field {
        case name, latitude, longitude
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (optional)", text: $viewModel.name)
                        .focused($focusedField, equals: .name)
                        .textInputAutocapitalization(.words)
                        .accessibilityLabel("Location name, optional")
                        .accessibilityHint("Enter the location")
                } header: {
                    Text("Details")
                }

                Section {
                    fieldRow(
                        placeholder: "Latitude (-90 to 90)",
                        text: $viewModel.latitudeText,
                        field: .latitude,
                        error: viewModel.latitudeError,
                        accessibilityLabel: "Latitude",
                        accessibilityHint: "Enter a value between negative 90 and 90"
                    )
                    fieldRow(
                        placeholder: "Longitude (-180 to 180)",
                        text: $viewModel.longitudeText,
                        field: .longitude,
                        error: viewModel.longitudeError,
                        accessibilityLabel: "Longitude",
                        accessibilityHint: "Enter a value between negative 180 and 180"
                    )
                } header: {
                    Text("Coordinates")
                }

                Section {
                    Button {
                        Task { await open() }
                    } label: {
                        HStack {
                            Spacer()
                            if isOpening {
                                ProgressView()
                            } else {
                                Label("Open in Wikipedia", systemImage: "arrow.up.right.square")
                                    .font(.body.weight(.semibold))
                            }
                            Spacer()
                        }
                    }
                    .disabled(isOpening)
                    .modifier(ShakeEffect(animatableData: shakeTrigger))
                }
            }
            .navigationTitle("Custom Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    @ViewBuilder
    private func fieldRow(
        placeholder: String,
        text: Binding<String>,
        field: Field,
        error: String?,
        accessibilityLabel: String,
        accessibilityHint: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: text)
                .keyboardType(.numbersAndPunctuation)
                .focused($focusedField, equals: field)
                .accessibilityLabel(accessibilityLabel)
                .accessibilityHint(accessibilityHint)
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
                    .accessibilityLabel("\(accessibilityLabel) error: \(error)")
            }
        }
        .animation(.default, value: error)
    }

    private func open() async {
        focusedField = nil
        guard let coordinate = viewModel.validatedCoordinate() else {
            if !reduceMotion {
                withAnimation(.default) { shakeTrigger += 1 }
            }
            return
        }
        isOpening = true
        await launcher.open(location: coordinate)
        isOpening = false
        if !launcher.isShowingNotInstalledAlert {
            dismiss()
        }
    }
}

#Preview {
    CustomLocationView(launcher: DependencyInjector().makeLocationsViewModel())
}
