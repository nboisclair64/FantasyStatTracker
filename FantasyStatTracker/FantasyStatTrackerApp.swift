//
//  FantasyStatTrackerApp.swift
//  FantasyStatTracker
//
//  Created by NICHOLAS BOISCLAIR on 2024-03-28.
//

import SwiftUI

@main
struct FantasyStatTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(RetrievePlayerAPIData())
        }
    }
}
