//
//  KMBApp.swift
//  KMB
//
//  Created by Bryce Ellis on 7/4/25.
//

import SwiftUI

@main
struct KMBApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
