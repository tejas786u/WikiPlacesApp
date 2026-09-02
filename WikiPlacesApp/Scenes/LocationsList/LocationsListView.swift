//
//  LocationsListView.swift
//  WikiPlacesApp
//
//  Created by Tejas Patel on 02/09/26.
//

import SwiftUI

struct LocationsListView: View {
    let interactor: LocationsListBusinessLogic
    @ObservedObject var presenter: LocationsListPresenter

    var body: some View {
        ScrollView {
            ListContentView(interactor: interactor, presenter: presenter)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
        }
        .background(BackgroundGradient())
        .task {
            await interactor.loadIfNeeded()
        }
    }
}

#Preview {
    let scene = LocationsListSceneBuilder.build(dependencyInjector: DependencyInjector())
    LocationsListView(interactor: scene.interactor, presenter: scene.presenter)
}
