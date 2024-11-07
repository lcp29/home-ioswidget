//
//  HomeEditView.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/5.
//

import SwiftUI

struct HomeEditView: View {
    @ObservedObject var homeStore: HomeStore
    @ObservedObject var homeEditModel: HomeEditModel
    
    let ICON_WIDTH: CGFloat = 22
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    HStack {
                        Image(systemName: "house")
                            .frame(width: ICON_WIDTH)
                        TextField("家庭名称", text: $homeEditModel.editHomeInfo.homeData.name)
                    }
                    HStack {
                        Image(systemName: "link")
                            .frame(width: ICON_WIDTH)
                        TextField("服务器URL", text: $homeEditModel.userInputURL)
                            .onChange(of: homeEditModel.userInputURL) {
                                homeEditModel.userInputURLValid = (URL(string: homeEditModel.userInputURL) != nil)
                                
                            }
                            .textContentType(.URL)
                            .keyboardType(.URL)
                        if !homeEditModel.userInputURLValid {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    HStack {
                        Image(systemName: "lock.fill")
                            .frame(width: ICON_WIDTH)
                        TextField("Token", text: $homeEditModel.editHomeInfo.homeData.bearerToken)
                    }
                }
                Section("数据实体") {
                    HStack {
                        Image(systemName: "thermometer")
                            .frame(width: ICON_WIDTH)
                        TextField("温度计实体", text: $homeEditModel.editHomeInfo.homeData.homeDetail.temp_air_entity)
                    }
                    HStack {
                        Image(systemName: "humidity")
                            .frame(width: ICON_WIDTH)
                        TextField("湿度计实体", text: $homeEditModel.editHomeInfo.homeData.homeDetail.humidity_air_entity)
                    }
                    HStack {
                        Image(systemName: "air.conditioner.horizontal")
                            .frame(width: ICON_WIDTH)
                        TextField("空调实体", text: $homeEditModel.editHomeInfo.homeData.homeDetail.climate_entity)
                    }
                    HStack {
                        Image(systemName: "bolt.fill")
                            .frame(width: ICON_WIDTH)
                        TextField("电量实体", text: $homeEditModel.editHomeInfo.homeData.homeDetail.power_left_entity)
                    }
                    HStack {
                        Image(systemName: "drop.fill")
                            .frame(width: ICON_WIDTH)
                        TextField("水量实体", text: $homeEditModel.editHomeInfo.homeData.homeDetail.water_left_entity)
                    }
                }
            }
            .navigationTitle("编辑")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        homeEditModel.isShowingEditSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        homeEditModel.editHomeInfo.homeData.serverURL = URL(string: homeEditModel.userInputURL)!
                        homeStore.newHome(newInfo: homeEditModel.editHomeInfo)
                        homeEditModel.isShowingEditSheet = false
                    }
                    .disabled(!homeEditModel.userInputURLValid)
                }
            }
        }
    }
}

#Preview {
    HomeListView(homeStore: HomeStore.sampleData, saveAction: {})
}
