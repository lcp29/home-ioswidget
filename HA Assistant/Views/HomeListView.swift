//
//  HomeListView.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/4.
//

import SwiftUI

struct HomeListView: View {
    @ObservedObject var homeStore: HomeStore
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject var homeEditModel: HomeEditModel
    @ObservedObject var homeStateModel: HomeStateModel
    
    init(homeStore: HomeStore, saveAction: @escaping () -> Void) {
        self.homeStore = homeStore
        self.homeEditModel = HomeEditModel()
        self.homeStateModel = HomeStateModel(homeStore)
        self.saveAction = saveAction
    }
    
    let saveAction: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("状态")) {
                        HomeStateView(homeStore: homeStore, homeStateModel: homeStateModel)
                    }
                    Section(header: Text("所有家庭")) {
                        ForEach(Array($homeStore.homeInfos.values)) { $homeInfo in
                            HomeCardView(homeStore: homeStore, homeInfo: homeInfo, homeEditModel: homeEditModel)
                        }
                        Button(action: {
                            homeEditModel.openNew()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("添加新家庭")
                            }
                        }
                    }
                }
                .sheet(isPresented: $homeEditModel.isShowingEditSheet) {
                    HomeEditView(homeStore: homeStore, homeEditModel: homeEditModel)
                }
            }
            .navigationTitle("HA助手")
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive { saveAction() }
        }
    }
}

#Preview {
    HomeListView(homeStore: HomeStore.sampleData, saveAction: {})
}
