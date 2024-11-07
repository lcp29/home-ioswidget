//
//  HomeCardView.swift
//  Dorm Assistant
//
//  Created by 李昌埔 on 2024/11/5.
//

import SwiftUI

struct HomeCardView: View {
    @ObservedObject var homeStore: HomeStore
    @ObservedObject var homeInfo: HomeInfo
    @ObservedObject var homeEditModel: HomeEditModel
    
    var body: some View {
        Button(action: {
            homeStore.select(target: homeInfo)
        }) {
            HStack {
                Image(systemName: homeInfo.homeData.current ? "checkmark.circle.fill" : "circle")
                VStack(alignment: .leading) {
                    Text(homeInfo.homeData.name)
                        .font(.headline)
                    Text(homeInfo.homeData.serverURL.absoluteString)
                        .font(.footnote)
                }
                .frame(alignment: .leading)
            }
            .padding([.vertical], 2)
        }
        //.buttonStyle(.plain)
        .foregroundStyle(Color.text)
        .swipeActions {
            Button(action: {
                let current = homeInfo.homeData.current
                homeStore.homeInfos.removeValue(forKey: homeInfo.id)
                if current && !homeStore.homeInfos.isEmpty{
                    homeStore.select(target: homeStore.homeInfos.values.first!)
                }
            }) {
                Image(systemName: "trash")
            }
            .tint(.red)
            Button(action: {
                homeEditModel.openEdit(editInfo: homeInfo)
            }) {
                Image(systemName: "square.and.pencil")
            }
            .tint(.blue)
        }
    }
}
