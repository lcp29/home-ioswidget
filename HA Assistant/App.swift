//
//  App.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/4.
//

import SwiftUI

@main
struct Dorm_AssistantApp: App {
    @StateObject private var homeStore = HomeStore()
    
    var body: some Scene {
        WindowGroup {
            HomeListView(homeStore: homeStore, saveAction: {
                Task {
                    do {
                        try await homeStore.save(homeInfos: homeStore.homeInfos)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            })
                .task {
                    do{
                        try await homeStore.load()
                    } catch {
                        do {
                            try await homeStore.save(homeInfos: homeStore.homeInfos)
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
        }
    }
}
