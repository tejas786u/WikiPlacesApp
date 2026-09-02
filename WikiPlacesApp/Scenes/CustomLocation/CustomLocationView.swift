//
//  CustomLocationView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import SwiftUI

struct CustomLocationView: View {
    let interactor: CustomLocationBusinessLogic
    @ObservedObject var presenter: CustomLocationPresenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var name: String = ""
    @State private var latitudeText: String = ""
    @State private var longitudeText: String = ""
    @FocusState private var focusedField: Field?
    @State private var isOpening = false
    @State private var shakeTrigger: CGFloat = 0

// MARK: - Focus Fields
    private enum Field {
        case name, latitude, longitude
    }

// MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (optional)", text: $name)
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
                        text: $latitudeText,
                        field: .latitude,
                        error: presenter.latitudeError,
                        accessibilityLabel: "Latitude",
                        accessibilityHint: "Enter a value between negative 90 and 90"
                    )
                    fieldRow(
                        placeholder: "Longitude (-180 to 180)",
                        text: $longitudeText,
                        field: .longitude,
                        error: presenter.longitudeError,
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
        .alert("Wikipedia App Not Found", isPresented: $presenter.isShowingNotInstalledAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Install the modified Wikipedia app to open locations there.")
        }
    }

// MARK: - Subviews
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

// MARK: - Actions
    private func open() async {
        focusedField = nil
        interactor.validate(request: CustomLocation.Validate.Request(
            name: name,
            latitudeText: latitudeText,
            longitudeText: longitudeText
        ))
        guard presenter.isValid else {
            if !reduceMotion {
                withAnimation(.default) { shakeTrigger += 1 }
            }
            return
        }
        isOpening = true
        await interactor.open(request: CustomLocation.Open.Request())
        isOpening = false
        if !presenter.isShowingNotInstalledAlert {
            dismiss()
        }
    }
}

#Preview {
    CustomLocationSceneBuilder.build(dependencyInjector: DependencyInjector())
}
