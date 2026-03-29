//
//  DocAskApp.swift
//  DocAsk
//
//  Created by Yemi Gabriel on 27/03/2026.
//

import SwiftUI

@main
struct DocAskApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: container.makeDocAskViewModel())
        }
    }
}
