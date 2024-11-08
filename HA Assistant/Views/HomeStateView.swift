//
//  HomeStateView.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/5.
//

import SwiftUI

struct HomeStateView: View {
    @ObservedObject var homeStore: HomeStore
    @ObservedObject var homeStateModel: HomeStateModel
    
    var body: some View {
        if (homeStore.homeInfos.count == 0) {
            Text("当前没有家庭")
                .foregroundStyle(.gray)
        } else {
            Button(action: {
                homeStateModel.refresh()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("刷新当前家庭")
                    if homeStateModel.updating {
                        Spacer()
                        ProgressView()
                    } else if homeStore.selected!.homeData.lastError {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .alert(isPresented: $homeStateModel.popupError) {
                Alert(title: Text("错误"), message: Text(homeStateModel.popupMessage), dismissButton: .default(Text("确认")))
            }
            Button(action: {
                homeStateModel.acOn()
            }) {
                HStack {
                    Image(systemName: "power.circle.fill")
                    Text("开启空调")
                    if homeStateModel.acTurningOn {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            Button(action: {
                homeStateModel.acOff()
            }) {
                HStack {
                    Image(systemName: "power.circle.fill")
                    Text("关闭空调")
                    if homeStateModel.acTurningOff {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            HStack {
                Text("名称").font(.headline)
                Spacer()
                Text(homeStore.selected!.homeData.name)
            }
            HStack {
                Text("URL").font(.headline)
                Spacer()
                Text(homeStore.selected!.homeData.serverURL.absoluteString)
            }
            HStack {
                Text("温度").font(.headline)
                Spacer()
                if homeStore.selected!.homeData.homeDetail.temp_air != nil {
                    Text(homeStore.selected!.homeData.homeDetail.temp_air!.description + " °C")
                } else { Text("-") }
                
            }
            HStack {
                Text("湿度").font(.headline)
                Spacer()
                if homeStore.selected!.homeData.homeDetail.humidity_air != nil {
                    Text(homeStore.selected!.homeData.homeDetail.humidity_air!.description + " %")
                } else { Text("-") }
            }
            HStack {
                Text("空调").font(.headline)
                Spacer()
                if (homeStore.selected!.homeData.homeDetail.ac_status == nil) {
                    Text("-")
                } else if (homeStore.selected!.homeData.homeDetail.ac_status == "off") {
                    Text("关")
                } else {
                    Text(homeStore.selected!.homeData.homeDetail.temp_ac!.description + " °C")
                }
            }
            HStack {
                Text("剩余电量").font(.headline)
                Spacer()
                if homeStore.selected!.homeData.homeDetail.power_left != nil {
                    Text(homeStore.selected!.homeData.homeDetail.power_left!.description + " kWh")
                } else { Text("-") }
            }
            HStack {
                Text("剩余水量").font(.headline)
                Spacer()
                if homeStore.selected!.homeData.homeDetail.water_left != nil {
                    Text(homeStore.selected!.homeData.homeDetail.water_left!.description + " m³")
                } else { Text("-") }
            }
        }
    }
}

#Preview {
    HomeListView(homeStore: HomeStore.sampleData, saveAction: {})
}

